import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hireanythingbooking/core/common/widgets/app_button.dart';
import 'package:hireanythingbooking/core/constants/app_strings.dart';
import 'package:hireanythingbooking/core/theme/app_colors.dart';
import 'package:hireanythingbooking/feature/forgot_password/presentation/cubit/reset_password_email_cubit.dart';

/// Submit button widget for reset password email page
class ResetPasswordSubmitButton extends StatelessWidget {
  final VoidCallback onPressed;

  const ResetPasswordSubmitButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ResetPasswordEmailCubit, ResetPasswordEmailState>(
      buildWhen: (prev, curr) =>
          prev.isLoading != curr.isLoading ||
          prev.isFormValid != curr.isFormValid,
      builder: (context, state) {
        return AppButton(
          text: state.isLoading
              ? AppStrings.sendingCode
              : AppStrings.sendVerificationCode,
          backgroundColor: AppColors.primary,
          onPressed: state.isFormValid && !state.isLoading ? onPressed : null,
        );
      },
    );
  }
}
