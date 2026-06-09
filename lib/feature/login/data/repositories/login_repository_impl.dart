import 'package:dartz/dartz.dart';
import 'package:hireanythingbooking/core/errors/exceptions.dart';
import 'package:hireanythingbooking/core/errors/failure.dart';
import 'package:hireanythingbooking/core/utils/debug_logger.dart';
import 'package:hireanythingbooking/core/utils/typedefs.dart';
import 'package:hireanythingbooking/feature/login/data/datasources/login_local_datasource.dart';
import 'package:hireanythingbooking/feature/login/data/datasources/login_remote_datasource.dart';
import 'package:hireanythingbooking/feature/login/domain/entities/login_entity.dart';
import 'package:hireanythingbooking/feature/login/domain/repositories/login_repository.dart';

/// Implementation of login repository
class LoginRepositoryImpl implements LoginRepository {
  LoginRepositoryImpl({
    required LoginRemoteDataSource remoteDataSource,
    required LoginLocalDataSource localDataSource,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource;

  final LoginRemoteDataSource _remoteDataSource;
  final LoginLocalDataSource _localDataSource;

  @override
  ResultFuture<LoginResponseEntity> login({
    required String email,
    required String password,
  }) async {
    DebugLogger.repository('Login initiated for email: $email');
    try {
      final response = await _remoteDataSource.login(
        email: email,
        password: password,
      );

      DebugLogger.repository(
        'Login successful — user: ${response.user.name}'
        ' (${response.user.role})',
      );

      // Save tokens locally
      await _localDataSource.saveTokens(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
      );

      // Save user profile locally
      try {
        await _localDataSource.saveUserProfile({
          'id': response.user.id,
          'email': response.user.email,
          'name': response.user.name,
          'role': response.user.role,
          'businessId': response.user.businessId,
        });
        DebugLogger.repository('User profile persisted after login');
      } on Exception catch (e) {
        DebugLogger.error('REPOSITORY', 'Failed to persist user profile: $e');
      }

      DebugLogger.repository('Tokens persisted after login');
      return Right(response);
    } on ServerException catch (e) {
      DebugLogger.error(
        'REPOSITORY',
        'ServerException during login: ${e.message}'
            ' (status: ${e.statusCode})',
      );
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on Exception catch (e) {
      DebugLogger.error('REPOSITORY', 'Unexpected error during login: $e');
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<String> refreshAccessToken() async {
    DebugLogger.repository('Token refresh initiated');
    try {
      final refreshToken = await _localDataSource.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        DebugLogger.error('REPOSITORY', 'Refresh token not found in storage');
        return const Left(ServerFailure(message: 'Refresh token not found'));
      }

      final newAccessToken = await _remoteDataSource.refreshAccessToken(
        refreshToken,
      );

      // Update the access token locally
      await _localDataSource.updateAccessToken(newAccessToken);

      DebugLogger.repository('Token refresh completed successfully');
      return Right(newAccessToken);
    } on ServerException catch (e) {
      DebugLogger.error(
        'REPOSITORY',
        'ServerException during token refresh: ${e.message}',
      );
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on Exception catch (e) {
      DebugLogger.error(
        'REPOSITORY',
        'Unexpected error during token refresh: $e',
      );
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<void> logout() async {
    DebugLogger.repository('Logout initiated');
    try {
      // Get access token to send with logout API
      final accessToken = await _localDataSource.getAccessToken();
      if (accessToken != null && accessToken.isNotEmpty) {
        try {
          await _remoteDataSource.logout(accessToken);
          DebugLogger.repository('Logout API call successful');
        } on Exception catch (e) {
          // Log but don't fail — still clear tokens locally
          DebugLogger.error(
            'REPOSITORY',
            'Logout API failed (clearing tokens anyway): $e',
          );
        }
      }

      await _localDataSource.clearTokens();
      await _localDataSource.clearUserProfile();
      DebugLogger.repository('Logout completed — tokens cleared');
      return const Right(null);
    } on Exception catch (e) {
      DebugLogger.error('REPOSITORY', 'Error during logout: $e');
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
