part of 'login_cubit.dart';

/// States for login cubit
class LoginState extends Equatable {
  const LoginState({
    this.isLoading = false,
    this.isPasswordVisible = false,
    this.isFormValid = false,
    this.errorMessage,
    this.loginResponse,
    this.isLoginSuccess = false,
  });

  final bool isLoading;
  final bool isPasswordVisible;
  final bool isFormValid;
  final String? errorMessage;
  final LoginResponseEntity? loginResponse;
  final bool isLoginSuccess;

  LoginState copyWith({
    bool? isLoading,
    bool? isPasswordVisible,
    bool? isFormValid,
    String? errorMessage,
    LoginResponseEntity? loginResponse,
    bool? isLoginSuccess,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      isFormValid: isFormValid ?? this.isFormValid,
      errorMessage: errorMessage,
      loginResponse: loginResponse ?? this.loginResponse,
      isLoginSuccess: isLoginSuccess ?? this.isLoginSuccess,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    isPasswordVisible,
    isFormValid,
    errorMessage,
    loginResponse,
    isLoginSuccess,
  ];
}
