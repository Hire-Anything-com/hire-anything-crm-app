import 'package:hireanythingbooking/core/errors/failure.dart';
import 'package:hireanythingbooking/core/utils/typedefs.dart';
import 'package:hireanythingbooking/feature/login/domain/entities/login_entity.dart';

/// Abstract repository for login operations
abstract class LoginRepository {
  /// Authenticates user with email and password
  /// Returns [LoginResponseEntity] on success or [Failure] on error
  ResultFuture<LoginResponseEntity> login({
    required String email,
    required String password,
  });

  /// Refreshes the access token using refresh token
  ResultFuture<String> refreshAccessToken();

  /// Logs out the user (clears stored tokens)
  ResultFuture<void> logout();
}
