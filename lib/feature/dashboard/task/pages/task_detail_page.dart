import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hireanythingbooking/core/core.dart';
import 'package:hireanythingbooking/core/extension/date_time_ext.dart';
import 'package:hireanythingbooking/feature/dashboard/task/cubit/task_cubit.dart';
import 'package:hireanythingbooking/feature/dashboard/task/cubit/task_state.dart';
import 'package:hireanythingbooking/feature/dashboard/task/model/task_model.dart';
import 'package:hireanythingbooking/feature/dashboard/task/pages/task_photo_page.dart';

class TaskDetailPage extends StatelessWidget {
  const TaskDetailPage({required this.taskId, super.key});
  final String taskId;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TaskCubit, TaskState>(
      listenWhen: (prev, curr) =>
          prev.isTimerRunning &&
          !curr.isTimerRunning &&
          curr.remainingSeconds == 0,
      listener: (context, state) {
        // Timer finished — navigate to photo upload
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(
            builder: (_) => BlocProvider.value(
              value: context.read<TaskCubit>(),
              child: const TaskPhotoPage(),
            ),
          ),
        );
      },
      builder: (context, state) {
        final task = state.tasks.firstWhere((t) => t.id == taskId);
        final isActive = state.activeTaskId == taskId;

        return Scaffold(
          appBar: const AppAppBar(title: 'Task Details'),
          body: SingleChildScrollView(
            padding: AppSpacing.p16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Task Info Card
                _TaskInfoCard(task: task),

                AppSpacing.h24,

                // Timer Section (only if task is in-progress)
                if (isActive && state.isTimerRunning) ...[
                  _TimerSection(
                    timerDisplay: state.timerDisplay,
                    remainingSeconds: state.remainingSeconds,
                    totalSeconds: task.durationMinutes * 60,
                  ),
                  AppSpacing.h24,
                  SizedBox(
                    width: double.infinity,
                    child: AppButton(
                      text: 'Stop & Complete',
                      backgroundColor: AppColors.secondary,
                      onPressed: () {
                        context.read<TaskCubit>().stopTimer();
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute<void>(
                            builder: (_) => BlocProvider.value(
                              value: context.read<TaskCubit>(),
                              child: const TaskPhotoPage(),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],

                // Start Button (only if accepted but not started yet)
                if (task.status == TaskStatus.accepted && !isActive) ...[
                  AppSpacing.h24,
                  SizedBox(
                    width: double.infinity,
                    child: AppButton(
                      text: 'Start Task',
                      backgroundColor: AppColors.primary,
                      onPressed: () => _handleStartTask(context, taskId),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleStartTask(BuildContext context, String taskId) {
    final cubit = context.read<TaskCubit>();

    if (cubit.isStartingEarly(taskId)) {
      showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: AppColors.warning,
                size: 28,
              ),
              AppSpacing.w8,
              const Text('Early Start'),
            ],
          ),
          content: const Text(
            'You are starting this task before the scheduled time. '
            'Do you want to proceed?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text(AppStrings.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                cubit.startTask(taskId);
              },
              child: const Text('Start Anyway'),
            ),
          ],
        ),
      );
    } else {
      cubit.startTask(taskId);
    }
  }
}

// ─── Task Info Card ──────────────────────────────────────────────────────────

class _TaskInfoCard extends StatelessWidget {
  const _TaskInfoCard({required this.task});
  final TaskModel task;

  @override
  Widget build(BuildContext context) {
    return Card(
      shadowColor: AppColors.disabledBtnText,
      child: Padding(
        padding: AppSpacing.p16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(task.title, style: AppTypography.headlineSmall),
            AppSpacing.h12,
            Text(
              task.description,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            AppSpacing.h16,
            const Divider(),
            AppSpacing.h12,
            _InfoRow(
              icon: AppIcons.profile,
              label: 'Customer',
              value: task.customerName,
            ),
            AppSpacing.h12,
            _InfoRow(
              icon: AppIcons.location,
              label: 'Location',
              value: task.location,
            ),
            AppSpacing.h12,
            _InfoRow(
              icon: AppIcons.clock,
              label: 'Scheduled',
              value: task.scheduledAt.formatTime,
            ),
            AppSpacing.h12,
            _InfoRow(
              icon: AppIcons.calendar,
              label: 'Duration',
              value: '${task.durationMinutes} minutes',
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        AppSpacing.w12,
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: AppTypography.bodySmall.copyWith(color: AppColors.textLight),
          ),
        ),
        Expanded(child: Text(value, style: AppTypography.bodyMedium)),
      ],
    );
  }
}

// ─── Timer Section ───────────────────────────────────────────────────────────

class _TimerSection extends StatelessWidget {
  const _TimerSection({
    required this.timerDisplay,
    required this.remainingSeconds,
    required this.totalSeconds,
  });

  final String timerDisplay;
  final int remainingSeconds;
  final int totalSeconds;

  @override
  Widget build(BuildContext context) {
    final progress = totalSeconds > 0
        ? (totalSeconds - remainingSeconds) / totalSeconds
        : 0.0;

    return Center(
      child: Column(
        children: [
          Text(
            'Time Remaining',
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          AppSpacing.h16,
          SizedBox(
            width: 200,
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 200,
                  height: 200,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 8,
                    backgroundColor: AppColors.grey200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      remainingSeconds < 60
                          ? AppColors.error
                          : AppColors.primary,
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      timerDisplay,
                      style: AppTypography.headlineLarge.copyWith(
                        color: remainingSeconds < 60
                            ? AppColors.error
                            : AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'min : sec',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
