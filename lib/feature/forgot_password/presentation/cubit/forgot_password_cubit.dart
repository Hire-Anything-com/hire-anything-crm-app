import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hireanythingbooking/core/constants/app_constants.dart';
import 'package:hireanythingbooking/core/constants/app_strings.dart';
import 'package:hireanythingbooking/core/utils/debug_logger.dart';
import 'package:hireanythingbooking/core/utils/validation_utils.dart';
import 'package:hireanythingbooking/feature/forgot_password/domain/usecases/forgot_password_usecase.dart';

part 'forgot_password_state.dart';

class ForgotPasswordCubit extends Cubit<ForgotPasswordState> {
  ForgotPasswordCubit({
    required ForgotPasswordUseCase forgotPasswordUseCase,
    required ResetPasswordUseCase resetPasswordUseCase,
    required String email,
  }) : _forgotPasswordUseCase = forgotPasswordUseCase,
       _resetPasswordUseCase = resetPasswordUseCase,
       _email = email,
       super(const ForgotPasswordState()) {
    DebugLogger.auth('ForgotPasswordCubit created for email: $email');
  }

  final ForgotPasswordUseCase _forgotPasswordUseCase;
  final ResetPasswordUseCase _resetPasswordUseCase;
  final String _email;

  final pageController = PageController();
  final otpController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final passwordFormKey = GlobalKey<FormState>();

  /// The email for which reset is being processed
  String get email => _email;

  void onOtpChanged(String value) {
    emit(state.copyWith(isOtpValid: value.length == AppConstants.otpLength));
  }

  void toggleNewPasswordVisibility() {
    emit(state.copyWith(isNewPasswordVisible: !state.isNewPasswordVisible));
  }

  void toggleConfirmPasswordVisibility() {
    emit(
      state.copyWith(isConfirmPasswordVisible: !state.isConfirmPasswordVisible),
    );
  }

  void onPasswordFieldChanged() {
    final newPassword = newPasswordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();
    final isValid =
        ValidationUtils.validatePasswordSecurity(newPassword) == null &&
        confirmPassword.isNotEmpty &&
        newPassword == confirmPassword;
    emit(state.copyWith(isPasswordFormValid: isValid));
  }

  String? validateNewPassword(String? value) {
    return ValidationUtils.validatePasswordSecurity(value);
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return '${AppStrings.confirmPassword} is required';
    }
    if (value != newPasswordController.text.trim()) {
      return AppStrings.passwordsDoNotMatch;
    }
    return null;
  }

  /// Sends forgot password OTP to the user's email
  Future<void> sendOtp() async {
    DebugLogger.auth('Sending OTP to email: $_email');
    emit(state.copyWith(isLoading: true));

    final result = await _forgotPasswordUseCase(email: _email);

    result.fold(
      (failure) {
        DebugLogger.error(
          'CUBIT',
          'Forgot password failed: ${failure.message}',
        );
        emit(state.copyWith(isLoading: false, errorMessage: failure.message));
      },
      (message) {
        DebugLogger.auth('OTP sent successfully — $message');
        emit(state.copyWith(isLoading: false, successMessage: message));
      },
    );
  }

  /// Verifies the OTP and slides to the change password screen
  Future<void> verifyOtp() async {
    final otp = otpController.text.trim();

    if (otp.length != AppConstants.otpLength) {
      emit(state.copyWith(errorMessage: AppStrings.invalidOtp));
      return;
    }

    emit(state.copyWith(isLoading: false));

    // Slide to change password screen
    await pageController.nextPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  /// Resets the password using the OTP and new password
  Future<void> changePassword() async {
    if (!passwordFormKey.currentState!.validate()) return;

    final otp = otpController.text.trim();
    final newPassword = newPasswordController.text.trim();

    DebugLogger.auth('Resetting password for email: $_email');
    emit(state.copyWith(isLoading: true));

    final result = await _resetPasswordUseCase(
      email: _email,
      otp: otp,
      newPassword: newPassword,
    );

    result.fold(
      (failure) {
        DebugLogger.error('CUBIT', 'Reset password failed: ${failure.message}');
        emit(state.copyWith(isLoading: false, errorMessage: failure.message));
      },
      (message) {
        DebugLogger.auth('Password reset successful — $message');
        emit(state.copyWith(isLoading: false, successMessage: message));
      },
    );
  }

  @override
  Future<void> close() {
    pageController.dispose();
    otpController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    return super.close();
  }
}
