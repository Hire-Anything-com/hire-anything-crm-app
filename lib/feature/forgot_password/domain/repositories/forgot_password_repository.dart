import 'package:hireanythingbooking/core/errors/failure.dart';
import 'package:hireanythingbooking/core/utils/typedefs.dart';

/// Abstract repository for forgot password operations
abstract class ForgotPasswordRepository {
  /// Sends OTP to the user's email
  /// Returns success message on success or [Failure] on error
  ResultFuture<String> forgotPassword({required String email});

  /// Resets the password using OTP
  /// Returns success message on success or [Failure] on error
  ResultFuture<String> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  });
}
