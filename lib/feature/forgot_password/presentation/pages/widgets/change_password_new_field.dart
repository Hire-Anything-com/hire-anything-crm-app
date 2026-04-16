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

/// New password input field with visibility toggle
class ChangePasswordNewField extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final VoidCallback onToggleVisibility;

  const ChangePasswordNewField({
    super.key,
    required this.controller,
    this.validator,
    this.onChanged,
    required this.onToggleVisibility,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Label
        Text(
          AppStrings.newPassword,
          style: AppTypography.labelLarge.copyWith(color: AppColors.grey800),
        ),
        AppSpacing.h8,
        // Field
        BlocBuilder<ForgotPasswordCubit, ForgotPasswordState>(
          buildWhen: (prev, curr) =>
              prev.isNewPasswordVisible != curr.isNewPasswordVisible,
          builder: (context, state) {
            return AppTextField(
              controller: controller,
              hintText: AppStrings.enterNewPassword,
              obscureText: !state.isNewPasswordVisible,
              validator: validator,
              onChanged: onChanged,
              prefixIcon: AppIcons.icon(
                AppIcons.lock,
                color: AppColors.grey500,
                size: 20,
              ),
              suffixIcon: AppIcons.icon(
                state.isNewPasswordVisible
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
