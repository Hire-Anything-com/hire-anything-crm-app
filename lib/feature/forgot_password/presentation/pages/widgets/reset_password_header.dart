import 'package:flutter/material.dart';
import 'package:hireanythingbooking/core/constants/app_spacing.dart';
import 'package:hireanythingbooking/core/constants/app_strings.dart';
import 'package:hireanythingbooking/core/theme/app_colors.dart';
import 'package:hireanythingbooking/core/theme/app_typography.dart';

/// Header widget with icon, title, and subtitle for reset password email page
class ResetPasswordHeader extends StatelessWidget {
  final double screenHeight;

  const ResetPasswordHeader({super.key, required this.screenHeight});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: screenHeight * 0.02),
        // Icon
        Center(
          child: Container(
            padding: AppSpacing.p24,
            decoration: BoxDecoration(
              color: AppColors.blueLighten5,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withAlpha(25),
                  blurRadius: 50,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.lock_reset_rounded,
              size: 48,
              color: AppColors.primary,
            ),
          ),
        ),
        SizedBox(height: screenHeight * 0.025),
        // Title
        Text(
          AppStrings.resetPasswordTitle,
          style: AppTypography.headlineLarge.copyWith(
            color: AppColors.grey900,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
          textAlign: TextAlign.center,
        ),
        AppSpacing.h8,
        // Subtitle
        Text(
          AppStrings.resetPasswordSubtitle,
          style: AppTypography.bodyMedium.copyWith(
            fontSize: 15,
            color: AppColors.grey500,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: screenHeight * 0.035),
      ],
    );
  }
}
