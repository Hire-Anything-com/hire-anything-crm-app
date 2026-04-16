import 'package:dartz/dartz.dart';
import 'package:hireanythingbooking/core/errors/exceptions.dart';
import 'package:hireanythingbooking/core/errors/failure.dart';
import 'package:hireanythingbooking/core/utils/debug_logger.dart';
import 'package:hireanythingbooking/core/utils/typedefs.dart';
import 'package:hireanythingbooking/feature/forgot_password/data/datasources/forgot_password_remote_datasource.dart';
import 'package:hireanythingbooking/feature/forgot_password/domain/repositories/forgot_password_repository.dart';

/// Implementation of forgot password repository
class ForgotPasswordRepositoryImpl implements ForgotPasswordRepository {
  ForgotPasswordRepositoryImpl({
    required ForgotPasswordRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final ForgotPasswordRemoteDataSource _remoteDataSource;

  @override
  ResultFuture<String> forgotPassword({required String email}) async {
    DebugLogger.repository('Forgot password initiated for email: $email');
    try {
      final message = await _remoteDataSource.forgotPassword(email: email);
      DebugLogger.repository('Forgot password successful — $message');
      return Right(message);
    } on ServerException catch (e) {
      DebugLogger.error(
        'REPOSITORY',
        'ServerException during forgot password: ${e.message}'
            ' (status: ${e.statusCode})',
      );
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      DebugLogger.error(
        'REPOSITORY',
        'Unexpected error during forgot password: $e',
      );
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<String> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    DebugLogger.repository('Reset password initiated for email: $email');
    try {
      final message = await _remoteDataSource.resetPassword(
        email: email,
        otp: otp,
        newPassword: newPassword,
      );
      DebugLogger.repository('Reset password successful — $message');
      return Right(message);
    } on ServerException catch (e) {
      DebugLogger.error(
        'REPOSITORY',
        'ServerException during reset password: ${e.message}'
            ' (status: ${e.statusCode})',
      );
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      DebugLogger.error(
        'REPOSITORY',
        'Unexpected error during reset password: $e',
      );
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
