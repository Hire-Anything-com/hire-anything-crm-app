import 'package:flutter/material.dart';
import 'package:hireanythingbooking/core/constants/app_constants.dart';
import 'package:hireanythingbooking/core/constants/app_strings.dart';
import 'package:hireanythingbooking/core/theme/app_colors.dart';
import 'package:hireanythingbooking/core/theme/app_typography.dart';
import 'package:pinput/pinput.dart';

/// PIN input widget for OTP entry
class OtpPinInput extends StatelessWidget {
  const OtpPinInput({
    required this.controller,
    required this.onChanged,
    super.key,
  });
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 48,
      height: 56,
      textStyle: AppTypography.headlineSmall.copyWith(color: AppColors.grey900),
      decoration: BoxDecoration(
        color: AppColors.fieldBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.fieldBorder),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        color: AppColors.fieldBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.fieldBorderFocused, width: 2),
      ),
    );

    final errorPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        color: AppColors.fieldBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error, width: 1.5),
      ),
    );

    return Column(
      children: [
        Text(
          AppStrings.enterOtp,
          style: AppTypography.labelLarge.copyWith(color: AppColors.grey800),
        ),
        const SizedBox(height: 16),
        Center(
          child: Pinput(
            controller: controller,
            length: AppConstants.otpLength,
            defaultPinTheme: defaultPinTheme,
            focusedPinTheme: focusedPinTheme,
            errorPinTheme: errorPinTheme,
            onChanged: onChanged,
            hapticFeedbackType: HapticFeedbackType.lightImpact,
          ),
        ),
      ],
    );
  }
}
