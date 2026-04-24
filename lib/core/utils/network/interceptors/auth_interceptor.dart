import 'package:dio/dio.dart';
import 'package:hireanythingbooking/core/utils/debug_logger.dart';

/// Interceptor for handling authentication tokens in HTTP requests.
///
/// Attaches the Bearer token to every outgoing request and automatically
/// retries requests that receive a 401 response after refreshing the token.
/// Uses [onTokenRefresh] to obtain a new access token; on failure the
/// original 401 response is forwarded to the caller.
///
/// Note: This interceptor is intentionally NOT added to the Dio instance
/// used by the forgot-password feature (those endpoints are public).
class AuthInterceptor extends Interceptor {
  AuthInterceptor({required this.getAccessToken, required this.onTokenRefresh});

  /// Returns the current access token from secure storage.
  final Future<String?> Function() getAccessToken;

  /// Called when a 401 is received. Should refresh the token and return
  /// `true` on success, `false` on failure.
  final Future<bool> Function() onTokenRefresh;

  /// Guards against concurrent refresh calls and infinite retry loops.
  bool _isRefreshing = false;

  // ─── Request ──────────────────────────────────────────────────────────────

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    DebugLogger.log('🌐', 'INTERCEPTOR', '→ ${options.method} ${options.path}');
    final token = await getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
      DebugLogger.log('🔐', 'INTERCEPTOR', 'Access token attached');
    } else {
      DebugLogger.log(
        '⚠️',
        'INTERCEPTOR',
        'No access token — request sent without auth',
      );
    }
    return handler.next(options);
  }

  // ─── Response ─────────────────────────────────────────────────────────────

  @override
  Future<void> onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) async {
    DebugLogger.log(
      '📥',
      'INTERCEPTOR',
      '← ${response.statusCode} ${response.requestOptions.path}',
    );
    DebugLogger.log('📄', 'INTERCEPTOR', 'Response body: ${response.data}');

    // validateStatus: (_) => true means 401s arrive here, not in onError.
    if (response.statusCode == 401 &&
        response.requestOptions.extra['_isRetry'] != true &&
        !_isRefreshing) {
      DebugLogger.log(
        '🔄',
        'INTERCEPTOR',
        '401 received — attempting token refresh',
      );

      _isRefreshing = true;
      final refreshed = await onTokenRefresh();
      _isRefreshing = false;

      if (refreshed) {
        DebugLogger.log(
          '✅',
          'INTERCEPTOR',
          'Token refreshed — retrying original request',
        );
        try {
          final retried = await _retry(response.requestOptions);
          return handler.resolve(retried);
        } on DioException catch (e) {
          DebugLogger.error(
            'INTERCEPTOR',
            'Retry after refresh failed: ${e.message}',
          );
          // Return the retried response even if it's still a 401
          return handler.resolve(e.response ?? response);
        }
      } else {
        DebugLogger.error(
          'INTERCEPTOR',
          'Token refresh failed — forwarding 401 to caller',
        );
      }
    }

    return handler.next(response);
  }

  // ─── Error ────────────────────────────────────────────────────────────────

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    DebugLogger.error(
      'INTERCEPTOR',
      '← ${err.response?.statusCode ?? 'UNKNOWN'}'
          ' ${err.requestOptions.path} — ${err.type}',
    );
    return handler.next(err);
  }

  // ─── Retry helper ─────────────────────────────────────────────────────────

  /// Retries [requestOptions] with the freshly-stored access token.
  /// Uses a new bare Dio instance (no interceptors) to avoid infinite loops.
  Future<Response<dynamic>> _retry(RequestOptions requestOptions) async {
    final token = await getAccessToken();

    final headers = Map<String, dynamic>.from(requestOptions.headers);
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
      DebugLogger.log(
        '🔐',
        'INTERCEPTOR',
        'New access token attached for retry',
      );
    }

    // Mark as retry so a second 401 is not re-retried.
    final extra = Map<String, dynamic>.from(requestOptions.extra)
      ..['_isRetry'] = true;

    final retryDio = Dio(
      BaseOptions(
        baseUrl: requestOptions.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        validateStatus: (_) => true,
      ),
    );

    return retryDio.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: Options(
        method: requestOptions.method,
        headers: headers,
        contentType: requestOptions.contentType,
        responseType: requestOptions.responseType,
        extra: extra,
      ),
    );
  }
}
