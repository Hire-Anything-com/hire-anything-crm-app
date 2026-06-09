import 'package:hireanythingbooking/core/utils/typedefs.dart';
import 'package:hireanythingbooking/feature/login/domain/entities/login_entity.dart';

/// Plain JSON model for user data (manual serialization)
class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.name,
    required super.role,
    super.businessId,
  });

  factory UserModel.fromJson(DataMap json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      role: json['role'] as String,
      businessId: json['businessId'] as String?,
    );
  }
  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      email: entity.email,
      name: entity.name,
      role: entity.role,
      businessId: entity.businessId,
    );
  }

  DataMap toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
      'businessId': businessId,
    };
  }
}

/// Plain JSON model for login response data
class LoginResponseModel extends LoginResponseEntity {
  const LoginResponseModel({
    required super.user,
    required super.accessToken,
    required super.refreshToken,
    required super.message,
  });

  factory LoginResponseModel.fromJson(DataMap json) {
    return LoginResponseModel(
      user: UserModel.fromJson(json['user'] as DataMap),
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      message: json['message'] as String? ?? 'Login successful',
    );
  }

  DataMap toJson() {
    return {
      'user': (user as UserModel).toJson(),
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'message': message,
    };
  }
}

/// Model for API response wrapper
class ApiResponseModel<T> {
  const ApiResponseModel({
    required this.success,
    required this.data,
    this.message,
  });

  /// Creates an [ApiResponseModel] from JSON
  factory ApiResponseModel.fromJson(
    DataMap json,
    T Function(dynamic) fromJsonT,
  ) {
    return ApiResponseModel(
      success: json['success'] as bool,
      data: fromJsonT(json['data']),
      message: json['message'] as String?,
    );
  }

  final bool success;
  final T data;
  final String? message;
}
