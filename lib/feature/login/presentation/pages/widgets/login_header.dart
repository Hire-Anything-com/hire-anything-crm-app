import 'package:flutter/material.dart';
import 'package:hireanythingbooking/core/constants/app_assets.dart';
import 'package:hireanythingbooking/core/constants/app_spacing.dart';
import 'package:hireanythingbooking/core/theme/app_colors.dart';
import 'package:hireanythingbooking/core/theme/app_typography.dart';

/// Header widget with logo, title, and subtitle
class LoginHeader extends StatelessWidget {
  const LoginHeader({
    required this.screenWidth,
    required this.screenHeight,
    super.key,
  });
  final double screenWidth;
  final double screenHeight;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: screenHeight * 0.02),
        // Logo
        Center(
          child: Container(
            padding: AppSpacing.p16,
            decoration: BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withAlpha(25),
                  blurRadius: 50,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Image.asset(
              AppAssets.logo,
              width: screenWidth * 0.2,
              height: screenWidth * 0.2,
              fit: BoxFit.contain,
            ),
          ),
        ),
        SizedBox(height: screenHeight * 0.025),
        // Title
        Text(
          'Partner Login',
          style: AppTypography.headlineLarge.copyWith(
            color: AppColors.grey900,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
          textAlign: TextAlign.center,
        ),
        AppSpacing.h4,
        // Subtitle
        Text(
          'Manage your assigned tasks',
          style: AppTypography.bodyMedium.copyWith(
            fontSize: 15,
            color: const Color(0xFF8A8A8A),
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: screenHeight * 0.035),
      ],
    );
  }
}
