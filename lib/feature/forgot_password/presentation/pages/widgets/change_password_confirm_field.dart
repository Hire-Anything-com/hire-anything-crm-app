import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hireanythingbooking/core/common/widgets/app_text_field.dart';
import 'package:hireanythingbooking/core/constants/app_icons.dart';
import 'package:hireanythingbooking/core/constants/app_spacing.dart';
import 'package:hireanythingbooking/core/constants/app_strings.dart';
import 'package:hireanythingbooking/core/theme/app_colors.dart';
import 'package:hireanythingbooking/core/theme/app_typography.dart';
import 'package:hireanythingbooking/feature/forgot_password/presentation/cubit/forgot_password_cubit.dart';
import 'package:hugeicons/hugeicons.dart';

/// Confirm password input field with visibility toggle
class ChangePasswordConfirmField extends StatelessWidget {
  const ChangePasswordConfirmField({
    required this.controller,
    required this.onToggleVisibility,
    super.key,
    this.validator,
    this.onChanged,
  });
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final VoidCallback onToggleVisibility;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Label
        Text(
          AppStrings.confirmPassword,
          style: AppTypography.labelLarge.copyWith(color: AppColors.grey800),
        ),
        AppSpacing.h8,
        // Field
        BlocBuilder<ForgotPasswordCubit, ForgotPasswordState>(
          buildWhen: (prev, curr) =>
              prev.isConfirmPasswordVisible != curr.isConfirmPasswordVisible,
          builder: (context, state) {
            return AppTextField(
              controller: controller,
              hintText: AppStrings.confirmNewPassword,
              obscureText: !state.isConfirmPasswordVisible,
              textInputAction: TextInputAction.done,
              validator: validator,
              onChanged: onChanged,
              prefixIcon: AppIcons.icon(
                AppIcons.lock,
                color: AppColors.grey500,
                size: 20,
              ),
              suffixIcon: AppIcons.icon(
                state.isConfirmPasswordVisible
                    ? HugeIcons.strokeRoundedView
                    : HugeIcons.strokeRoundedViewOff,
                color: AppColors.grey500,
                size: 20,
              ),
              onSuffixTap: onToggleVisibility,
            );
          },
        ),
      ],
    );
  }
}
