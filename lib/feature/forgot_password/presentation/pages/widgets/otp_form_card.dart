import 'package:flutter/material.dart';
import 'package:hireanythingbooking/core/common/widgets/app_card.dart';
import 'package:hireanythingbooking/core/constants/app_spacing.dart';
import 'package:hireanythingbooking/feature/forgot_password/presentation/cubit/forgot_password_cubit.dart';
import 'package:hireanythingbooking/feature/forgot_password/presentation/pages/widgets/otp_error_message.dart';
import 'package:hireanythingbooking/feature/forgot_password/presentation/pages/widgets/otp_pin_input.dart';
import 'package:hireanythingbooking/feature/forgot_password/presentation/pages/widgets/otp_verify_button.dart';

/// Form card containing OTP input, error message, and verify button
class OtpFormCard extends StatelessWidget {
  const OtpFormCard({required this.cubit, required this.onVerify, super.key});
  final ForgotPasswordCubit cubit;
  final VoidCallback onVerify;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          OtpPinInput(
            controller: cubit.otpController,
            onChanged: cubit.onOtpChanged,
          ),
          const OtpErrorMessage(),
          AppSpacing.h24,
          OtpVerifyButton(onPressed: onVerify),
        ],
      ),
    );
  }
}
