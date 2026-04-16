import 'package:flutter/material.dart';
import 'package:hireanythingbooking/core/common/widgets/app_card.dart';
import 'package:hireanythingbooking/core/constants/app_spacing.dart';
import 'package:hireanythingbooking/feature/forgot_password/presentation/cubit/reset_password_email_cubit.dart';
import 'package:hireanythingbooking/feature/forgot_password/presentation/pages/widgets/reset_password_email_field.dart';
import 'package:hireanythingbooking/feature/forgot_password/presentation/pages/widgets/reset_password_submit_button.dart';

/// Form card containing email field and submit button for reset password
class ResetPasswordFormCard extends StatelessWidget {
  final ResetPasswordEmailCubit cubit;
  final VoidCallback onSubmit;

  const ResetPasswordFormCard({
    super.key,
    required this.cubit,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ResetPasswordEmailField(
            controller: cubit.emailController,
            focusNode: cubit.emailFocusNode,
            validator: cubit.validateEmail,
            onChanged: cubit.onEmailChanged,
          ),
          AppSpacing.h24,
          ResetPasswordSubmitButton(onPressed: onSubmit),
        ],
      ),
    );
  }
}
