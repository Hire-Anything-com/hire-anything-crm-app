import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hireanythingbooking/core/common/widgets/app_button.dart';
import 'package:hireanythingbooking/core/constants/app_strings.dart';
import 'package:hireanythingbooking/core/theme/app_colors.dart';
import 'package:hireanythingbooking/feature/login/presentation/cubit/login_cubit.dart';

/// Sign In submit button widget
class LoginSubmitButton extends StatelessWidget {
  const LoginSubmitButton({required this.onPressed, super.key});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginCubit, LoginState>(
      buildWhen: (prev, curr) => prev.isLoading != curr.isLoading,
      builder: (context, state) {
        return AppButton(
          text: state.isLoading ? AppStrings.signingIn : AppStrings.signIn,
          backgroundColor: AppColors.primary,
          onPressed: state.isLoading ? null : onPressed,
        );
      },
    );
  }
}
