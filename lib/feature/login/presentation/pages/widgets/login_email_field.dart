import 'package:flutter/material.dart';
import 'package:hireanythingbooking/core/common/widgets/app_text_field.dart';
import 'package:hireanythingbooking/core/constants/app_icons.dart';
import 'package:hireanythingbooking/core/constants/app_spacing.dart';
import 'package:hireanythingbooking/core/constants/app_strings.dart';
import 'package:hireanythingbooking/core/theme/app_colors.dart';
import 'package:hireanythingbooking/core/theme/app_typography.dart';

/// Email input field widget
class LoginEmailField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;

  const LoginEmailField({
    super.key,
    required this.controller,
    required this.focusNode,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Label
        Text(
          AppStrings.email,
          style: AppTypography.labelMedium.copyWith(
            color: AppColors.grey700,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
        AppSpacing.h8,
        // Email Field
        AppTextField(
          controller: controller,
          focusNode: focusNode,
          hintText: AppStrings.enterYourEmail,
          keyboardType: TextInputType.emailAddress,
          validator: validator,
          onChanged: onChanged,
          prefixIcon: AppIcons.icon(
            AppIcons.mail,
            color: AppColors.grey500,
            size: 20,
          ),
        ),
      ],
    );
  }
}
