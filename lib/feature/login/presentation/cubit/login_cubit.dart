import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hireanythingbooking/core/routes/routes.dart';
import 'package:hireanythingbooking/core/utils/debug_logger.dart';
import 'package:hireanythingbooking/core/utils/validation_utils.dart';
import 'package:hireanythingbooking/feature/login/domain/domain.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit({
    required LoginUseCase loginUseCase,
    required LogoutUseCase logoutUseCase,
  }) : _loginUseCase = loginUseCase,
       _logoutUseCase = logoutUseCase,
       super(const LoginState()) {
    emailFocusNode.addListener(_onEmailFocusChanged);
    _initializeDebugValues();
  }

  final LoginUseCase _loginUseCase;
  final LogoutUseCase _logoutUseCase;

  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final emailFocusNode = FocusNode();

  void _onEmailFocusChanged() {
    if (!emailFocusNode.hasFocus && emailController.text.isNotEmpty) {
      emailController.selection = const TextSelection.collapsed(offset: 0);
    }
  }

  /// Initialize debug values for testing in debug mode
  void _initializeDebugValues() {
    if (kDebugMode) {
      emailController.text = 'Khanfeshan2324@gmail.com';
      passwordController.text = 'Test@123';
      DebugLogger.auth('Debug mode: Pre-filled email and password');
    }
  }

  void togglePasswordVisibility() {
    emit(state.copyWith(isPasswordVisible: !state.isPasswordVisible));
  }

  void onFieldChanged() {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final isValid = ValidationUtils.isLoginFormValid(email, password);
    emit(state.copyWith(isFormValid: isValid));
  }

  String? validateEmail(String? value) {
    return ValidationUtils.validateLoginEmail(value);
  }

  String? validatePassword(String? value) {
    return ValidationUtils.validateLoginPassword(value);
  }

  /// Performs login API call
  Future<void> login(BuildContext context) async {
    if (!formKey.currentState!.validate()) {
      DebugLogger.auth('Login form validation failed');
      return;
    }

    DebugLogger.auth('Login form validated — initiating login');
    emit(state.copyWith(isLoading: true, errorMessage: null));

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    final result = await _loginUseCase(email: email, password: password);

    result.fold(
      (failure) {
        DebugLogger.error(
          'AUTH',
          'Login failed: ${failure.message}'
              ' (status: ${failure.statusCode})',
        );
        emit(state.copyWith(isLoading: false, errorMessage: failure.message));
      },
      (loginResponse) {
        DebugLogger.auth(
          'Login successful — user: ${loginResponse.user.name}'
          ' (${loginResponse.user.role})',
        );
        emit(
          state.copyWith(
            isLoading: false,
            loginResponse: loginResponse,
            isLoginSuccess: true,
          ),
        );

        // Navigate to dashboard
        if (context.mounted) {
          DebugLogger.auth('Navigating to dashboard');
          context.pushReplacement(AppRoutes.dashboard);
        }
      },
    );
  }

  /// Performs logout
  Future<void> logout(BuildContext context) async {
    DebugLogger.auth('Logout initiated');
    emit(state.copyWith(isLoading: true));

    final result = await _logoutUseCase();

    result.fold(
      (failure) {
        DebugLogger.error('AUTH', 'Logout error: ${failure.message}');
        if (!isClosed) emit(state.copyWith(isLoading: false));
      },
      (_) {
        DebugLogger.auth('Logout successful — tokens cleared');
        if (!isClosed) emit(state.copyWith(isLoading: false));
      },
    );

    if (context.mounted) {
      DebugLogger.auth('Navigating to login screen');
      context.pushReplacement(AppRoutes.login);
    }
  }

  void navigateToForgotPassword(BuildContext context) {
    context.push(AppRoutes.resetPasswordEmail);
  }

  @override
  Future<void> close() {
    emailFocusNode.removeListener(_onEmailFocusChanged);
    emailFocusNode.dispose();
    emailController.dispose();
    passwordController.dispose();
    return super.close();
  }
}
