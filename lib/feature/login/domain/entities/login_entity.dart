import 'package:equatable/equatable.dart';

/// Represents a user entity in the domain layer
class UserEntity extends Equatable {
  const UserEntity({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.businessId,
  });

  final String id;
  final String email;
  final String name;
  final String role;
  final String? businessId;

  @override
  List<Object?> get props => [id, email, name, role, businessId];
}

/// Represents login credentials
class LoginRequestEntity extends Equatable {
  const LoginRequestEntity({required this.email, required this.password});

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

/// Represents the login response with authentication data
class LoginResponseEntity extends Equatable {
  const LoginResponseEntity({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
    required this.message,
  });

  final UserEntity user;
  final String accessToken;
  final String refreshToken;
  final String message;

  @override
  List<Object?> get props => [user, accessToken, refreshToken, message];
}
