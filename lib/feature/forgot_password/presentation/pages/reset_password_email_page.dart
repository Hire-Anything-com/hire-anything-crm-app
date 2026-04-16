import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hireanythingbooking/core/common/widgets/app_snackbar.dart';
import 'package:hireanythingbooking/core/constants/app_icons.dart';
import 'package:hireanythingbooking/core/theme/app_colors.dart';
import 'package:hireanythingbooking/feature/forgot_password/presentation/cubit/reset_password_email_cubit.dart';
import 'package:hireanythingbooking/feature/forgot_password/presentation/pages/widgets/widgets.dart';

class ResetPasswordEmailPage extends StatelessWidget {
  const ResetPasswordEmailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ResetPasswordEmailCubit>();
    final size = MediaQuery.sizeOf(context);

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
      body: BlocListener<ResetPasswordEmailCubit, ResetPasswordEmailState>(
        listenWhen: (prev, curr) =>
            prev.errorMessage != curr.errorMessage ||
            prev.successMessage != curr.successMessage,
        listener: (context, state) {
          if (state.errorMessage != null) {
            AppSnackBar.show(
              context,
              message: state.errorMessage!,
              type: SnackBarType.error,
            );
          }
          if (state.successMessage != null) {
            AppSnackBar.show(
              context,
              message: state.successMessage!,
              type: SnackBarType.success,
            );
          }
        },
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.07),
              child: Form(
                key: cubit.formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    ResetPasswordHeader(screenHeight: size.height),

                    // Email Form Card
                    ResetPasswordFormCard(
                      cubit: cubit,
                      onSubmit: () => cubit.sendOtp(context),
                    ),

                    SizedBox(height: size.height * 0.03),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
