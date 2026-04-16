import 'package:flutter/material.dart';
import 'package:hireanythingbooking/core/constants/app_spacing.dart';
import 'package:hireanythingbooking/core/constants/app_strings.dart';
import 'package:hireanythingbooking/core/theme/app_colors.dart';
import 'package:hireanythingbooking/core/theme/app_typography.dart';

/// Header widget with icon, title, and subtitle for OTP screen
class OtpHeader extends StatelessWidget {
  final double screenHeight;

  const OtpHeader({super.key, required this.screenHeight});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Icon
        Padding(
          padding: const EdgeInsets.all(8),
          child: Center(
            child: Container(
              padding: AppSpacing.p24,
              decoration: BoxDecoration(
                color: AppColors.blueLighten5,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withAlpha(15),
                    blurRadius: 30,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Icon(
                Icons.mail_outline_rounded,
                size: 48,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
        SizedBox(height: screenHeight * 0.04),
        // Title
        Text(
          AppStrings.otpVerification,
          style: AppTypography.headlineLarge.copyWith(
            color: AppColors.grey900,
            letterSpacing: -0.5,
          ),
          textAlign: TextAlign.center,
        ),
        AppSpacing.h12,
        // Subtitle
        Text(
          AppStrings.checkYourMail,
          style: AppTypography.bodyMedium.copyWith(color: AppColors.grey500),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: screenHeight * 0.05),
      ],
    );
  }
}
