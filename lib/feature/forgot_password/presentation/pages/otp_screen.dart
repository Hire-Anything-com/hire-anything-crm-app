import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hireanythingbooking/feature/forgot_password/presentation/cubit/forgot_password_cubit.dart';
import 'package:hireanythingbooking/feature/forgot_password/presentation/pages/widgets/widgets.dart';

class OtpScreen extends StatelessWidget {
  const OtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ForgotPasswordCubit>();
    final size = MediaQuery.sizeOf(context);

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.07),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            OtpHeader(screenHeight: size.height),

            // OTP Form Card
            OtpFormCard(cubit: cubit, onVerify: cubit.verifyOtp),

            SizedBox(height: size.height * 0.04),
          ],
        ),
      ),
    );
  }
}
