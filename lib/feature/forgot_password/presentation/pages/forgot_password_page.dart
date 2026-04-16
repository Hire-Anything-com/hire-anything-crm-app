import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hireanythingbooking/core/constants/app_icons.dart';
import 'package:hireanythingbooking/core/theme/app_colors.dart';
import 'package:hireanythingbooking/feature/forgot_password/presentation/cubit/forgot_password_cubit.dart';
import 'package:hireanythingbooking/feature/forgot_password/presentation/pages/change_password_screen.dart';
import 'package:hireanythingbooking/feature/forgot_password/presentation/pages/otp_screen.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ForgotPasswordCubit>();

    return Scaffold(
      backgroundColor: AppColors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: AppIcons.icon(AppIcons.back, color: AppColors.grey900),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: PageView(
          controller: cubit.pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: const [OtpScreen(), ChangePasswordScreen()],
        ),
      ),
    );
  }
}
