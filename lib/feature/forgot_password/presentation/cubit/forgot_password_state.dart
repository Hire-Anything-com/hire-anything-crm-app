part of 'forgot_password_cubit.dart';

class ForgotPasswordState extends Equatable {
  const ForgotPasswordState({
    this.isLoading = false,
    this.isOtpValid = false,
    this.isPasswordFormValid = false,
    this.isNewPasswordVisible = false,
    this.isConfirmPasswordVisible = false,
    this.errorMessage,
    this.successMessage,
  });

  final bool isLoading;
  final bool isOtpValid;
  final bool isPasswordFormValid;
  final bool isNewPasswordVisible;
  final bool isConfirmPasswordVisible;
  final String? errorMessage;
  final String? successMessage;

  ForgotPasswordState copyWith({
    bool? isLoading,
    bool? isOtpValid,
    bool? isPasswordFormValid,
    bool? isNewPasswordVisible,
    bool? isConfirmPasswordVisible,
    String? errorMessage,
    String? successMessage,
  }) {
    return ForgotPasswordState(
      isLoading: isLoading ?? this.isLoading,
      isOtpValid: isOtpValid ?? this.isOtpValid,
      isPasswordFormValid: isPasswordFormValid ?? this.isPasswordFormValid,
      isNewPasswordVisible: isNewPasswordVisible ?? this.isNewPasswordVisible,
      isConfirmPasswordVisible:
          isConfirmPasswordVisible ?? this.isConfirmPasswordVisible,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    isOtpValid,
    isPasswordFormValid,
    isNewPasswordVisible,
    isConfirmPasswordVisible,
    errorMessage,
    successMessage,
  ];
}
