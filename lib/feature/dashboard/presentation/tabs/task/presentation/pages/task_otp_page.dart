import 'package:hireanythingbooking/core/core.dart';
import 'package:hireanythingbooking/feature/dashboard/presentation/tabs/task/presentation/cubit/task_cubit.dart';
import 'package:hireanythingbooking/feature/dashboard/presentation/tabs/task/presentation/cubit/task_state.dart';
import 'package:pinput/pinput.dart';

class TaskOtpPage extends StatefulWidget {
  const TaskOtpPage({super.key});

  @override
  State<TaskOtpPage> createState() => _TaskOtpPageState();
}

class _TaskOtpPageState extends State<TaskOtpPage> {
  final _otpController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _otpController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppAppBar(title: 'Verify & Complete'),
      body: BlocConsumer<TaskCubit, TaskState>(
        listenWhen: (prev, curr) => !prev.taskCompleted && curr.taskCompleted,
        listener: (context, state) {
          // Task completed — pop back to task list
          AppSnackBar.show(
            context,
            message: 'Task completed successfully!',
            type: SnackBarType.success,
          );
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
        builder: (context, state) {
          final defaultPinTheme = PinTheme(
            width: 48,
            height: 56,
            textStyle: AppTypography.headlineSmall,
            decoration: BoxDecoration(
              color: AppColors.fieldBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.fieldBorder),
            ),
          );

          return SingleChildScrollView(
            padding: AppSpacing.p24,
            child: Column(
              children: [
                AppSpacing.h32,

                // Lock icon
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(25),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    AppIcons.lock,
                    color: AppColors.primary,
                    size: 40,
                  ),
                ),

                AppSpacing.h24,

                Text(
                  'Enter Customer OTP',
                  style: AppTypography.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                AppSpacing.h8,
                Text(
                  'Please ask the customer for the 6-digit OTP '
                  'to verify task completion.',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),

                AppSpacing.h32,

                Pinput(
                  controller: _otpController,
                  focusNode: _focusNode,
                  length: 6,
                  defaultPinTheme: defaultPinTheme,
                  focusedPinTheme: defaultPinTheme.copyWith(
                    decoration: defaultPinTheme.decoration!.copyWith(
                      border: Border.all(
                        color: AppColors.fieldBorderFocused,
                        width: 2,
                      ),
                    ),
                  ),
                  errorPinTheme: defaultPinTheme.copyWith(
                    decoration: defaultPinTheme.decoration!.copyWith(
                      border: Border.all(color: AppColors.error, width: 1.5),
                    ),
                  ),
                  onChanged: (_) {
                    if (state.otpError != null) {
                      context.read<TaskCubit>().clearOtpError();
                    }
                  },
                ),

                if (state.otpError != null) ...[
                  AppSpacing.h12,
                  Text(
                    state.otpError!,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ],

                AppSpacing.h32,

                AppButton(
                  text: state.isCompletingTask
                      ? 'Verifying...'
                      : 'Complete Task',
                  backgroundColor: AppColors.primary,
                  onPressed: state.isCompletingTask
                      ? null
                      : () {
                          final otp = _otpController.text.trim();
                          if (otp.length < 6) {
                            AppSnackBar.show(
                              context,
                              message: AppStrings.invalidOtp,
                              type: SnackBarType.warning,
                            );
                            return;
                          }
                          context.read<TaskCubit>().verifyOtp(otp);
                        },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
