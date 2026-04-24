import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hireanythingbooking/core/common/widgets/app_snackbar.dart';
import 'package:hireanythingbooking/feature/login/presentation/cubit/login_cubit.dart';
import 'package:hireanythingbooking/feature/login/presentation/pages/widgets/widgets.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<LoginCubit>();
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      body: BlocListener<LoginCubit, LoginState>(
        listenWhen: (prev, curr) => prev.errorMessage != curr.errorMessage,
        listener: (context, state) {
          if (state.errorMessage != null) {
            AppSnackBar.show(
              context,
              message: state.errorMessage!,
              type: SnackBarType.error,
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
                    LoginHeader(
                      screenWidth: size.width,
                      screenHeight: size.height,
                    ),

                    // Form Card
                    LoginFormCard(
                      cubit: cubit,
                      onSubmit: () => cubit.login(context),
                      onForgotPassword: () =>
                          cubit.navigateToForgotPassword(context),
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
