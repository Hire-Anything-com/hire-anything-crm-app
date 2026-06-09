import 'package:flutter/material.dart';
import 'package:hireanythingbooking/core/common/widgets/app_card.dart';
import 'package:hireanythingbooking/core/constants/app_spacing.dart';
import 'package:hireanythingbooking/feature/forgot_password/presentation/cubit/forgot_password_cubit.dart';
import 'package:hireanythingbooking/feature/forgot_password/presentation/pages/widgets/change_password_confirm_field.dart';
import 'package:hireanythingbooking/feature/forgot_password/presentation/pages/widgets/change_password_new_field.dart';
import 'package:hireanythingbooking/feature/forgot_password/presentation/pages/widgets/change_password_submit_button.dart';

/// Form card containing new password, confirm password, and submit button
class ChangePasswordFormCard extends StatelessWidget {
  const ChangePasswordFormCard({
    required this.cubit,
    required this.onSubmit,
    super.key,
  });
  final ForgotPasswordCubit cubit;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ChangePasswordNewField(
            controller: cubit.newPasswordController,
            validator: cubit.validateNewPassword,
            onChanged: (_) => cubit.onPasswordFieldChanged(),
            onToggleVisibility: cubit.toggleNewPasswordVisibility,
          ),
          AppSpacing.h24,
          ChangePasswordConfirmField(
            controller: cubit.confirmPasswordController,
            validator: cubit.validateConfirmPassword,
            onChanged: (_) => cubit.onPasswordFieldChanged(),
            onToggleVisibility: cubit.toggleConfirmPasswordVisibility,
          ),
          AppSpacing.h24,
          ChangePasswordSubmitButton(onPressed: onSubmit),
        ],
      ),
    );
  }
}
