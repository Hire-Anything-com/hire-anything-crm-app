import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hireanythingbooking/core/common/widgets/app_button.dart';
import 'package:hireanythingbooking/core/constants/app_strings.dart';
import 'package:hireanythingbooking/feature/forgot_password/presentation/cubit/forgot_password_cubit.dart';

/// Submit button widget for change password screen
class ChangePasswordSubmitButton extends StatelessWidget {
  final VoidCallback onPressed;

  const ChangePasswordSubmitButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ForgotPasswordCubit, ForgotPasswordState>(
      buildWhen: (prev, curr) =>
          prev.isLoading != curr.isLoading ||
          prev.isPasswordFormValid != curr.isPasswordFormValid,
      builder: (context, state) {
        return AppButton(
          text: AppStrings.changePassword,
          isLoading: state.isLoading,
          onPressed: state.isPasswordFormValid ? onPressed : null,
        );
      },
    );
  }
}
