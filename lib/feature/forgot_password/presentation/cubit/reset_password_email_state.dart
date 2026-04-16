part of 'reset_password_email_cubit.dart';

class ResetPasswordEmailState extends Equatable {
  const ResetPasswordEmailState({
    this.isLoading = false,
    this.isFormValid = false,
    this.errorMessage,
    this.successMessage,
  });

  final bool isLoading;
  final bool isFormValid;
  final String? errorMessage;
  final String? successMessage;

  ResetPasswordEmailState copyWith({
    bool? isLoading,
    bool? isFormValid,
    String? errorMessage,
    String? successMessage,
  }) {
    return ResetPasswordEmailState(
      isLoading: isLoading ?? this.isLoading,
      isFormValid: isFormValid ?? this.isFormValid,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    isFormValid,
    errorMessage,
    successMessage,
  ];
}
