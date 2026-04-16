import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hireanythingbooking/core/theme/app_colors.dart';
import 'package:hireanythingbooking/core/theme/app_typography.dart';
import 'package:hireanythingbooking/feature/forgot_password/presentation/cubit/forgot_password_cubit.dart';

/// Error message widget for OTP screen
class OtpErrorMessage extends StatelessWidget {
  const OtpErrorMessage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ForgotPasswordCubit, ForgotPasswordState>(
      buildWhen: (prev, curr) => prev.errorMessage != curr.errorMessage,
      builder: (context, state) {
        if (state.errorMessage == null) {
          return const SizedBox.shrink();
        }
        return Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Text(
            state.errorMessage!,
            style: AppTypography.bodySmall.copyWith(color: AppColors.error),
            textAlign: TextAlign.center,
          ),
        );
      },
    );
  }
}
