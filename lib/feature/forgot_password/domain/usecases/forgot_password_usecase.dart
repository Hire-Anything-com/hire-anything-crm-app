import 'package:hireanythingbooking/core/utils/debug_logger.dart';
import 'package:hireanythingbooking/core/utils/typedefs.dart';
import 'package:hireanythingbooking/feature/forgot_password/domain/repositories/forgot_password_repository.dart';

/// Usecase for sending forgot password OTP
class ForgotPasswordUseCase {
  ForgotPasswordUseCase(this._repository);

  final ForgotPasswordRepository _repository;

  /// Executes the forgot password operation
  ResultFuture<String> call({required String email}) {
    DebugLogger.log(
      '🔑',
      'USECASE',
      'ForgotPasswordUseCase called for: $email',
    );
    return _repository.forgotPassword(email: email);
  }
}

/// Usecase for resetting password with OTP
class ResetPasswordUseCase {
  ResetPasswordUseCase(this._repository);

  final ForgotPasswordRepository _repository;

  /// Executes the reset password operation
  ResultFuture<String> call({
    required String email,
    required String otp,
    required String newPassword,
  }) {
    DebugLogger.log('🔄', 'USECASE', 'ResetPasswordUseCase called for: $email');
    return _repository.resetPassword(
      email: email,
      otp: otp,
      newPassword: newPassword,
    );
  }
}
