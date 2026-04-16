import 'package:hireanythingbooking/core/utils/typedefs.dart';
import 'package:hireanythingbooking/feature/login/domain/entities/login_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'login_model.g.dart';

/// Model for user data
@JsonSerializable()
class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.name,
    required super.role,
    super.businessId,
  });

  /// Creates a [UserModel] from JSON
  factory UserModel.fromJson(DataMap json) => _$UserModelFromJson(json);

  /// Converts [UserModel] to JSON
  DataMap toJson() => _$UserModelToJson(this);

  /// Creates a [UserModel] from a [UserEntity]
  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      email: entity.email,
      name: entity.name,
      role: entity.role,
      businessId: entity.businessId,
    );
  }
}

/// Model for login response data
@JsonSerializable()
class LoginResponseModel extends LoginResponseEntity {
  const LoginResponseModel({
    required super.user,
    required super.accessToken,
    required super.refreshToken,
    required super.message,
  });

  /// Creates a [LoginResponseModel] from JSON
  factory LoginResponseModel.fromJson(DataMap json) {
    return LoginResponseModel(
      user: UserModel.fromJson(json['user'] as DataMap),
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      message: json['message'] as String? ?? 'Login successful',
    );
  }

  /// Converts [LoginResponseModel] to JSON
  DataMap toJson() => _$LoginResponseModelToJson(this);
}

/// Model for API response wrapper
class ApiResponseModel<T> {
  const ApiResponseModel({
    required this.success,
    required this.data,
    this.message,
  });

  final bool success;
  final T data;
  final String? message;

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
}
