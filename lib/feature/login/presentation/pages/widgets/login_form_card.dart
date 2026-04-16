import 'package:flutter/material.dart';
import 'package:hireanythingbooking/core/common/widgets/app_card.dart';
import 'package:hireanythingbooking/core/constants/app_spacing.dart';
import 'package:hireanythingbooking/feature/login/presentation/cubit/login_cubit.dart';
import 'package:hireanythingbooking/feature/login/presentation/pages/widgets/login_email_field.dart';
import 'package:hireanythingbooking/feature/login/presentation/pages/widgets/login_password_field.dart';
import 'package:hireanythingbooking/feature/login/presentation/pages/widgets/login_forgot_password_link.dart';
import 'package:hireanythingbooking/feature/login/presentation/pages/widgets/login_submit_button.dart';

/// Login form card containing email, password, and submit button
class LoginFormCard extends StatelessWidget {
  final LoginCubit cubit;
  final VoidCallback onSubmit;
  final VoidCallback onForgotPassword;

  const LoginFormCard({
    super.key,
    required this.cubit,
    required this.onSubmit,
    required this.onForgotPassword,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Email Field
          LoginEmailField(
            controller: cubit.emailController,
            focusNode: cubit.emailFocusNode,
            validator: cubit.validateEmail,
            onChanged: (_) => cubit.onFieldChanged(),
          ),
          AppSpacing.h24,

          // Password Field
          LoginPasswordField(
            controller: cubit.passwordController,
            validator: cubit.validatePassword,
            onChanged: (_) => cubit.onFieldChanged(),
            onToggleVisibility: cubit.togglePasswordVisibility,
          ),
          AppSpacing.h12,

          // Forgot Password Link
          LoginForgotPasswordLink(onTap: onForgotPassword),
          AppSpacing.h24,

          // Submit Button
          LoginSubmitButton(onPressed: onSubmit),
        ],
      ),
    );
  }
}
