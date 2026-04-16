import 'package:flutter/material.dart';
import 'package:hireanythingbooking/core/constants/app_spacing.dart';
import 'package:hireanythingbooking/core/constants/app_strings.dart';
import 'package:hireanythingbooking/core/theme/app_colors.dart';
import 'package:hireanythingbooking/core/theme/app_typography.dart';

/// Forgot password link widget
class LoginForgotPasswordLink extends StatelessWidget {
  final VoidCallback onTap;

  const LoginForgotPasswordLink({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: AppSpacing.p4,
          child: Text(
            AppStrings.forgotPassword,
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
