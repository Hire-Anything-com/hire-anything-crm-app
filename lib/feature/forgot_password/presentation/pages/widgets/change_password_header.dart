import 'package:flutter/material.dart';
import 'package:hireanythingbooking/core/constants/app_spacing.dart';
import 'package:hireanythingbooking/core/constants/app_strings.dart';
import 'package:hireanythingbooking/core/theme/app_colors.dart';
import 'package:hireanythingbooking/core/theme/app_typography.dart';

/// Header widget with icon, title, and subtitle for change password screen
class ChangePasswordHeader extends StatelessWidget {
  final double screenHeight;

  const ChangePasswordHeader({super.key, required this.screenHeight});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Icon
        Center(
          child: Container(
            padding: AppSpacing.p24,
            decoration: const BoxDecoration(
              color: AppColors.blueLighten5,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lock_reset_rounded,
              size: 48,
              color: AppColors.primary,
            ),
          ),
        ),
        SizedBox(height: screenHeight * 0.04),
        // Title
        Text(
          AppStrings.resetPassword,
          style: AppTypography.headlineLarge.copyWith(
            color: AppColors.grey900,
            letterSpacing: -0.5,
          ),
          textAlign: TextAlign.center,
        ),
        AppSpacing.h12,
        // Subtitle
        Text(
          AppStrings.createNewPassword,
          style: AppTypography.bodyMedium.copyWith(color: AppColors.grey500),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: screenHeight * 0.05),
      ],
    );
  }
}
