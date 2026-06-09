import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hireanythingbooking/core/common/widgets/app_button.dart';
import 'package:hireanythingbooking/core/constants/app_strings.dart';
import 'package:hireanythingbooking/core/theme/app_colors.dart';
import 'package:hireanythingbooking/feature/forgot_password/presentation/cubit/forgot_password_cubit.dart';

/// Verify OTP button widget
class OtpVerifyButton extends StatelessWidget {
  const OtpVerifyButton({required this.onPressed, super.key});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ForgotPasswordCubit, ForgotPasswordState>(
      buildWhen: (prev, curr) =>
          prev.isLoading != curr.isLoading ||
          prev.isOtpValid != curr.isOtpValid,
      builder: (context, state) {
        return AppButton(
          text: state.isLoading
              ? AppStrings.verifyingOtp
              : AppStrings.verifyOtp,
          backgroundColor: AppColors.primary,
          onPressed: state.isOtpValid && !state.isLoading ? onPressed : null,
        );
      },
    );
  }
}
