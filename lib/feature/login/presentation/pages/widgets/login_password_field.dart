import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hireanythingbooking/core/common/widgets/app_text_field.dart';
import 'package:hireanythingbooking/core/constants/app_icons.dart';
import 'package:hireanythingbooking/core/constants/app_spacing.dart';
import 'package:hireanythingbooking/core/constants/app_strings.dart';
import 'package:hireanythingbooking/core/theme/app_colors.dart';
import 'package:hireanythingbooking/core/theme/app_typography.dart';
import 'package:hireanythingbooking/feature/login/presentation/cubit/login_cubit.dart';
import 'package:hugeicons/hugeicons.dart';

/// Password input field widget with visibility toggle
class LoginPasswordField extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;
  final VoidCallback onToggleVisibility;

  const LoginPasswordField({
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
          AppStrings.password,
          style: AppTypography.labelMedium.copyWith(
            color: AppColors.grey700,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
        AppSpacing.h8,
        // Password Field
        BlocBuilder<LoginCubit, LoginState>(
          buildWhen: (prev, curr) =>
              prev.isPasswordVisible != curr.isPasswordVisible,
          builder: (context, state) {
            return AppTextField(
              controller: controller,
              hintText: AppStrings.enterYourPassword,
              obscureText: !state.isPasswordVisible,
              textInputAction: TextInputAction.done,
              validator: validator,
              onChanged: onChanged,
              prefixIcon: AppIcons.icon(
                AppIcons.lock,
                color: AppColors.grey500,
                size: 20,
              ),
              suffixIcon: AppIcons.icon(
                state.isPasswordVisible
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
