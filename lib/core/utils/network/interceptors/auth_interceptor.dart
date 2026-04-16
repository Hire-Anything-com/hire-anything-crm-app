import 'package:dio/dio.dart';
import 'package:hireanythingbooking/core/utils/debug_logger.dart';

/// Interceptor for handling authentication tokens in HTTP requests
class AuthInterceptor extends Interceptor {
  AuthInterceptor({required this.getAccessToken, required this.onTokenRefresh});

  /// Callback to get the current access token (async function)
  final Future<String?> Function() getAccessToken;

  /// Callback to refresh the access token
  final Future<bool> Function() onTokenRefresh;

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
    return handler.next(response);
  }

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
    // Handle 401 Unauthorized - attempt token refresh
    if (err.response?.statusCode == 401) {
      DebugLogger.log(
        '🔄',
        'INTERCEPTOR',
        '401 received — attempting token refresh',
      );
      final isRefreshed = await onTokenRefresh.call();
      if (isRefreshed) {
        DebugLogger.log(
          '✅',
          'INTERCEPTOR',
          'Token refreshed — retrying original request',
        );
        // Retry the original request with new token
        try {
          return handler.resolve(await _retry(err.requestOptions));
        } catch (e) {
          DebugLogger.error('INTERCEPTOR', 'Retry after refresh failed: $e');
          return handler.next(err);
        }
      } else {
        DebugLogger.error(
          'INTERCEPTOR',
          'Token refresh failed — passing error through',
        );
      }
    }
    return handler.next(err);
  }

  /// Retries the request with new token
  Future<Response<dynamic>> _retry(RequestOptions requestOptions) async {
    final options = Options(
      method: requestOptions.method,
      headers: requestOptions.headers,
    );
    return Dio().request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }
}
