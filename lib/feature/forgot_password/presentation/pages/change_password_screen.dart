import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hireanythingbooking/core/common/widgets/app_snackbar.dart';
import 'package:hireanythingbooking/core/routes/routes.dart';
import 'package:hireanythingbooking/feature/forgot_password/presentation/cubit/forgot_password_cubit.dart';
import 'package:hireanythingbooking/feature/forgot_password/presentation/pages/widgets/widgets.dart';

class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ForgotPasswordCubit>();
    final size = MediaQuery.sizeOf(context);

    return BlocListener<ForgotPasswordCubit, ForgotPasswordState>(
      listenWhen: (prev, curr) =>
          prev.successMessage != curr.successMessage ||
          prev.errorMessage != curr.errorMessage,
      listener: (context, state) {
        if (state.successMessage != null) {
          AppSnackBar.show(
            context,
            message: state.successMessage!,
            type: SnackBarType.success,
          );
          Future<void>.delayed(const Duration(seconds: 1), () {
            if (!context.mounted) return;
            context.go(AppRoutes.login);
          });
        }
        if (state.errorMessage != null) {
          AppSnackBar.show(
            context,
            message: state.errorMessage!,
            type: SnackBarType.error,
            duration: const Duration(seconds: 3),
          );
          Future<void>.delayed(const Duration(seconds: 3), () {
            if (!context.mounted) return;
            context.go(AppRoutes.login);
          });
        }
      },
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: size.width * 0.07),
        child: Form(
          key: cubit.passwordFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              ChangePasswordHeader(screenHeight: size.height),

              // Form Card
              ChangePasswordFormCard(
                cubit: cubit,
                onSubmit: cubit.changePassword,
              ),

              SizedBox(height: size.height * 0.04),
            ],
          ),
        ),
      ),
    );
  }
}
