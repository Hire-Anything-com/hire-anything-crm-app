import 'package:dio/dio.dart';
import 'package:hireanythingbooking/core/constants/app_constants.dart';
import 'package:hireanythingbooking/core/errors/exceptions.dart';
import 'package:hireanythingbooking/core/utils/debug_logger.dart';
import 'package:hireanythingbooking/core/utils/typedefs.dart';
import 'package:hireanythingbooking/feature/login/data/models/login_model.dart';

/// Abstract data source for login operations
abstract class LoginRemoteDataSource {
  /// Performs login API call
  Future<LoginResponseModel> login({
    required String email,
    required String password,
  });

  /// Refreshes access token using refresh token
  Future<String> refreshAccessToken(String refreshToken);

  /// Calls the logout API
  Future<void> logout(String accessToken);
}

/// Implementation of login remote data source
class LoginRemoteDataSourceImpl implements LoginRemoteDataSource {
  LoginRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<LoginResponseModel> login({
    required String email,
    required String password,
  }) async {
    DebugLogger.remote('Login request initiated for email: $email');
    try {
      final response = await _dio.post<dynamic>(
        AppConstants.loginEndpoint,
        data: {'email': email, 'password': password},
      );

      DebugLogger.remote(
        'Login response received — status: ${response.statusCode}',
      );
      DebugLogger.remote('Login response body: ${response.data}');

      // 200 — Login successful, returns tokens and user
      if (response.statusCode == 200 || response.statusCode == 201) {
        final apiResponse = response.data;
        if (apiResponse is Map<String, dynamic> &&
            apiResponse['success'] == true &&
            apiResponse['data'] != null) {
          DebugLogger.remote('Login API success — parsing response');
          return LoginResponseModel.fromJson(
            (apiResponse['data'] as DataMap?)?.cast<String, dynamic>() ??
                <String, dynamic>{},
          );
        }
      }

      // 401 — Invalid credentials
      if (response.statusCode == 401) {
        final msg = _extractMessage(response.data) ?? 'Invalid credentials';
        DebugLogger.error('REMOTE', 'Login 401 — $msg');
        throw ServerException(message: msg, statusCode: 401);
      }

      // 429 — Too many attempts
      if (response.statusCode == 429) {
        final msg =
            _extractMessage(response.data) ??
            'Too many attempts. Please try again later.';
        DebugLogger.error('REMOTE', 'Login 429 — $msg');
        throw ServerException(message: msg, statusCode: 429);
      }

      // Other unexpected status codes
      DebugLogger.error(
        'REMOTE',
        'Login failed — status: ${response.statusCode}',
      );
      throw ServerException(
        message: _extractMessage(response.data) ?? 'Login failed',
        statusCode: response.statusCode,
      );
    } on ServerException {
      rethrow;
    } on DioException catch (e) {
      DebugLogger.error('REMOTE', 'DioException during login: ${e.type}');
      throw _handleDioException(e);
    } catch (e) {
      DebugLogger.error('REMOTE', 'Unexpected error during login: $e');
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<String> refreshAccessToken(String refreshToken) async {
    DebugLogger.remote('Token refresh request initiated');
    try {
      final response = await _dio.post<dynamic>(
        AppConstants.refreshTokenEndpoint,
        data: {'refreshToken': refreshToken},
      );

      DebugLogger.remote(
        'Token refresh response — status: ${response.statusCode}',
      );
      DebugLogger.remote('Token refresh response body: ${response.data}');

      // 200 — New tokens issued
      if (response.statusCode == 200) {
        final apiResponse = response.data;
        if (apiResponse is Map<String, dynamic> &&
            apiResponse['success'] == true &&
            apiResponse['data'] != null) {
          final data = apiResponse['data'] as DataMap?;
          final newAccessToken = (data?['accessToken'] as String?) ?? '';
          if (newAccessToken.isNotEmpty) {
            DebugLogger.remote('Token refresh successful');
            return newAccessToken;
          }
        }
      }

      // 401 — Invalid, expired, or reused refresh token
      if (response.statusCode == 401) {
        final msg =
            _extractMessage(response.data) ??
            'Session expired. Please login again.';
        DebugLogger.error('REMOTE', 'Token refresh 401 — $msg');
        throw ServerException(message: msg, statusCode: 401);
      }

      // Other unexpected status codes
      DebugLogger.error(
        'REMOTE',
        'Token refresh failed — status: ${response.statusCode}',
      );
      throw ServerException(
        message: _extractMessage(response.data) ?? 'Token refresh failed',
        statusCode: response.statusCode,
      );
    } on ServerException {
      rethrow;
    } on DioException catch (e) {
      DebugLogger.error(
        'REMOTE',
        'DioException during token refresh: ${e.type}',
      );
      throw _handleDioException(e);
    } catch (e) {
      DebugLogger.error('REMOTE', 'Unexpected error during token refresh: $e');
      throw ServerException(message: e.toString());
    }
  }

  /// Extracts a human-readable message from a response body.
  /// Handles both JSON (`{"message": "..."}`) and plain string responses.
  String? _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      final msg = data['message'];
      if (msg is String) return msg;
    }
    if (data is String && data.isNotEmpty) return data;
    return null;
  }

  @override
  Future<void> logout(String accessToken) async {
    DebugLogger.remote('Logout API request initiated');
    try {
      final response = await _dio.post<dynamic>(
        AppConstants.logoutEndpoint,
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );

      DebugLogger.remote('Logout response — status: ${response.statusCode}');
      DebugLogger.remote('Logout response body: ${response.data}');

      if (response.statusCode == 200) {
        DebugLogger.remote('Logout API success');
        return;
      }

      throw ServerException(
        message: _extractMessage(response.data) ?? 'Logout failed',
        statusCode: response.statusCode,
      );
    } on ServerException {
      rethrow;
    } on DioException catch (e) {
      DebugLogger.error('REMOTE', 'DioException during logout: ${e.type}');
      throw _handleDioException(e);
    } catch (e) {
      DebugLogger.error('REMOTE', 'Unexpected error during logout: $e');
      throw ServerException(message: e.toString());
    }
  }

  /// Handles DioException and converts to ServerException
  ServerException _handleDioException(DioException exception) {
    final statusCode = exception.response?.statusCode;
    final responseMsg = _extractMessage(exception.response?.data);

    DebugLogger.error(
      'REMOTE',
      'DioException details — type: ${exception.type}, '
          'status: $statusCode, response: ${exception.response?.data}',
    );

    // Status-code-aware handling first
    if (statusCode == 401) {
      return ServerException(
        message: responseMsg ?? 'Invalid credentials',
        statusCode: 401,
      );
    }
    if (statusCode == 429) {
      return ServerException(
        message: responseMsg ?? 'Too many attempts. Please try again later.',
        statusCode: 429,
      );
    }

    // Fall back to DioExceptionType-based handling
    String message;
    switch (exception.type) {
      case DioExceptionType.connectionTimeout:
        message = 'Connection timeout. Please check your internet connection.';
      case DioExceptionType.receiveTimeout:
        message = 'Response timeout. Please try again.';
      case DioExceptionType.sendTimeout:
        message = 'Request timeout. Please try again.';
      case DioExceptionType.badResponse:
        message = responseMsg ?? 'An error occurred from server';
      case DioExceptionType.cancel:
        message = 'Request cancelled';
      case DioExceptionType.connectionError:
        message = 'Unable to connect. Please check your internet connection.';
      case DioExceptionType.badCertificate:
        message = 'Security certificate error. Please try again later.';
      case DioExceptionType.unknown:
        // If we have a response, it's likely a parsing issue — use the
        // response message. Otherwise it's a genuine network error.
        message = responseMsg ?? 'Network error. Please check your connection.';
    }

    return ServerException(message: message, statusCode: statusCode);
  }
}
