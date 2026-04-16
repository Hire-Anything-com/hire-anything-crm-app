import 'package:dio/dio.dart';
import 'package:hireanythingbooking/core/utils/network/interceptors/auth_interceptor.dart';

/// Configuration for the Dio HTTP client
class DioClient {
  static final _instance = Dio();

  /// Provides a configured Dio instance with interceptors
  static Dio get instance {
    return _instance;
  }

  /// Initializes the Dio client with base configuration and interceptors
  static Future<void> initialize({
    required String baseUrl,
    Duration connectTimeout = const Duration(seconds: 30),
    Duration receiveTimeout = const Duration(seconds: 30),
    required Future<String?> Function() getAccessToken,
    required Future<bool> Function() onTokenRefresh,
  }) async {
    _instance
      ..options = BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: connectTimeout,
        receiveTimeout: receiveTimeout,
        contentType: Headers.jsonContentType,
        responseType: ResponseType.json,
        validateStatus: (status) => true, // Don't throw on any status code
      )
      ..interceptors.clear()
      ..interceptors.addAll([
        AuthInterceptor(
          getAccessToken: getAccessToken,
          onTokenRefresh: onTokenRefresh,
        ),
      ]);
  }

  /// Clears all interceptors (useful for testing)
  static void clearInterceptors() {
    _instance.interceptors.clear();
  }
}
