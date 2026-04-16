import 'package:dio/dio.dart';
import 'package:hireanythingbooking/core/constants/app_constants.dart';
import 'package:hireanythingbooking/core/errors/exceptions.dart';
import 'package:hireanythingbooking/core/utils/debug_logger.dart';

/// Abstract data source for forgot password operations
abstract class ForgotPasswordRemoteDataSource {
  /// Sends OTP to user's email
  Future<String> forgotPassword({required String email});

  /// Resets password using OTP
  Future<String> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  });
}

/// Implementation of forgot password remote data source
class ForgotPasswordRemoteDataSourceImpl
    implements ForgotPasswordRemoteDataSource {
  ForgotPasswordRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<String> forgotPassword({required String email}) async {
    DebugLogger.remote('Forgot password request initiated for email: $email');
    try {
      final response = await _dio.post<dynamic>(
        AppConstants.forgotPasswordEndpoint,
        data: {'email': email},
      );

      DebugLogger.remote(
        'Forgot password response — status: ${response.statusCode}',
      );
      DebugLogger.remote('Forgot password response body: ${response.data}');

      // 200 — OTP sent successfully
      if (response.statusCode == 200) {
        final apiResponse = response.data;
        if (apiResponse is Map<String, dynamic> &&
            apiResponse['success'] == true) {
          final message =
              _extractMessage(apiResponse) ?? 'OTP sent successfully';
          DebugLogger.remote('Forgot password success — $message');
          return message;
        }
      }

      // 429 — Too many attempts
      if (response.statusCode == 429) {
        final msg =
            _extractMessage(response.data) ??
            'Too many attempts. Please try again later.';
        DebugLogger.error('REMOTE', 'Forgot password 429 — $msg');
        throw ServerException(message: msg, statusCode: 429);
      }

      // Other unexpected status codes
      DebugLogger.error(
        'REMOTE',
        'Forgot password failed — status: ${response.statusCode}',
      );
      throw ServerException(
        message: _extractMessage(response.data) ?? 'Failed to send OTP',
        statusCode: response.statusCode,
      );
    } on ServerException {
      rethrow;
    } on DioException catch (e) {
      DebugLogger.error(
        'REMOTE',
        'DioException during forgot password: ${e.type}',
      );
      throw _handleDioException(e);
    } catch (e) {
      DebugLogger.error(
        'REMOTE',
        'Unexpected error during forgot password: $e',
      );
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<String> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    DebugLogger.remote('Reset password request initiated for email: $email');
    try {
      final response = await _dio.post<dynamic>(
        AppConstants.resetPasswordEndpoint,
        data: {'email': email, 'otp': otp, 'newPassword': newPassword},
      );

      DebugLogger.remote(
        'Reset password response — status: ${response.statusCode}',
      );
      DebugLogger.remote('Reset password response body: ${response.data}');

      // 200 — Password reset successfully
      if (response.statusCode == 200) {
        final apiResponse = response.data;
        if (apiResponse is Map<String, dynamic> &&
            apiResponse['success'] == true) {
          final message =
              _extractMessage(apiResponse) ?? 'Password reset successfully';
          DebugLogger.remote('Reset password success — $message');
          return message;
        }
      }

      // 400 — Invalid or expired OTP
      if (response.statusCode == 400) {
        final msg = _extractMessage(response.data) ?? 'Invalid or expired OTP';
        DebugLogger.error('REMOTE', 'Reset password 400 — $msg');
        throw ServerException(message: msg, statusCode: 400);
      }

      // 429 — Too many attempts
      if (response.statusCode == 429) {
        final msg =
            _extractMessage(response.data) ??
            'Too many attempts. Please try again later.';
        DebugLogger.error('REMOTE', 'Reset password 429 — $msg');
        throw ServerException(message: msg, statusCode: 429);
      }

      // Other unexpected status codes
      DebugLogger.error(
        'REMOTE',
        'Reset password failed — status: ${response.statusCode}',
      );
      throw ServerException(
        message: _extractMessage(response.data) ?? 'Password reset failed',
        statusCode: response.statusCode,
      );
    } on ServerException {
      rethrow;
    } on DioException catch (e) {
      DebugLogger.error(
        'REMOTE',
        'DioException during reset password: ${e.type}',
      );
      throw _handleDioException(e);
    } catch (e) {
      DebugLogger.error('REMOTE', 'Unexpected error during reset password: $e');
      throw ServerException(message: e.toString());
    }
  }

  /// Extracts a human-readable message from a response body.
  String? _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      final msg = data['message'];
      if (msg is String) return msg;
    }
    if (data is String && data.isNotEmpty) return data;
    return null;
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
    if (statusCode == 400) {
      return ServerException(
        message: responseMsg ?? 'Invalid or expired OTP',
        statusCode: 400,
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
        message = responseMsg ?? 'Network error. Please check your connection.';
    }

    return ServerException(message: message, statusCode: statusCode);
  }
}
