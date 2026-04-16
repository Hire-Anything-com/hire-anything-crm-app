import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hireanythingbooking/core/routes/routes.dart';
import 'package:hireanythingbooking/core/utils/debug_logger.dart';
import 'package:hireanythingbooking/core/utils/validation_utils.dart';
import 'package:hireanythingbooking/feature/forgot_password/domain/usecases/forgot_password_usecase.dart';

part 'reset_password_email_state.dart';

class ResetPasswordEmailCubit extends Cubit<ResetPasswordEmailState> {
  ResetPasswordEmailCubit({
    required ForgotPasswordUseCase forgotPasswordUseCase,
  }) : _forgotPasswordUseCase = forgotPasswordUseCase,
       super(const ResetPasswordEmailState());

  final ForgotPasswordUseCase _forgotPasswordUseCase;

  final emailController = TextEditingController();
  final emailFocusNode = FocusNode();
  final formKey = GlobalKey<FormState>();

  void onEmailChanged(String value) {
    final isValid = ValidationUtils.validateLoginEmail(value.trim()) == null;
    emit(state.copyWith(isFormValid: isValid));
  }

  String? validateEmail(String? value) {
    return ValidationUtils.validateLoginEmail(value);
  }

  Future<void> sendOtp(BuildContext context) async {
    if (!formKey.currentState!.validate()) return;

    final email = emailController.text.trim();
    DebugLogger.auth('Sending OTP to email: $email');
    emit(state.copyWith(isLoading: true));

    final result = await _forgotPasswordUseCase(email: email);

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

        // Navigate to OTP / forgot password page
        if (!context.mounted) return;
        context.push(
          Uri(
            path: AppRoutes.forgotPassword,
            queryParameters: {'email': email},
          ).toString(),
        );
      },
    );
  }

  @override
  Future<void> close() {
    emailFocusNode.dispose();
    emailController.dispose();
    return super.close();
  }
}
