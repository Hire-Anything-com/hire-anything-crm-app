import 'package:hireanythingbooking/core/utils/debug_logger.dart';
import 'package:hireanythingbooking/core/utils/typedefs.dart';
import 'package:hireanythingbooking/feature/login/domain/entities/login_entity.dart';
import 'package:hireanythingbooking/feature/login/domain/repositories/login_repository.dart';

/// Usecase for user login
class LoginUseCase {
  LoginUseCase(this._repository);

  final LoginRepository _repository;

  /// Executes the login operation
  ResultFuture<LoginResponseEntity> call({
    required String email,
    required String password,
  }) {
    DebugLogger.log('🔑', 'USECASE', 'LoginUseCase called for: $email');
    return _repository.login(email: email, password: password);
  }
}

/// Usecase for refreshing access token
class RefreshTokenUseCase {
  RefreshTokenUseCase(this._repository);

  final LoginRepository _repository;

  /// Executes the token refresh operation
  ResultFuture<String> call() {
    DebugLogger.log('🔄', 'USECASE', 'RefreshTokenUseCase called');
    return _repository.refreshAccessToken();
  }
}

/// Usecase for logout
class LogoutUseCase {
  LogoutUseCase(this._repository);

  final LoginRepository _repository;

  /// Executes the logout operation
  ResultFuture<void> call() {
    DebugLogger.log('🚪', 'USECASE', 'LogoutUseCase called');
    return _repository.logout();
  }
}
