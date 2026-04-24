import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hireanythingbooking/core/core.dart';
import 'package:hireanythingbooking/core/utils/debug_logger.dart';
import 'package:hireanythingbooking/core/extension/date_time_ext.dart';
import 'package:hireanythingbooking/feature/dashboard/presentation/tabs/task/presentation/cubit/task_cubit.dart';
import 'package:hireanythingbooking/feature/dashboard/presentation/tabs/task/presentation/cubit/task_state.dart';
import 'package:hireanythingbooking/feature/dashboard/presentation/tabs/task/data/model/task_model.dart';
import 'package:hireanythingbooking/feature/dashboard/presentation/tabs/task/presentation/pages/task_photo_page.dart';
import 'package:url_launcher/url_launcher.dart';

class TaskDetailPage extends StatelessWidget {
  const TaskDetailPage({required this.taskId, super.key});
  final String taskId;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TaskCubit, TaskState>(
      listenWhen: (prev, curr) => prev.isTimerRunning && !curr.isTimerRunning,
      listener: (context, state) {
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
        final task = state.tasks.firstWhere(
          (t) => t.id == taskId,
          orElse: () => const TaskModel(),
        );
        final isActive = state.activeTaskId == taskId;

        return Scaffold(
          appBar: const AppAppBar(title: 'Task Details'),
          body: SingleChildScrollView(
            padding: AppSpacing.p16.copyWith(
              bottom: 16 + MediaQuery.of(context).padding.bottom + 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Task Info Card
                _TaskInfoCard(task: task),

                AppSpacing.h24,

                // Payment Info Card
                _PaymentInfoCard(task: task),

                AppSpacing.h24,

                // Timer Section (only if task is in-progress)
                if (isActive && state.isTimerRunning) ...[
                  _TimerSection(
                    timerDisplay: state.timerDisplay,
                    remainingSeconds: state.remainingSeconds,
                    totalSeconds: task.durationMinutes * 60,
                    isOvertime: state.isOvertime,
                    overtimeSeconds: state.overtimeSeconds,
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

                // Start Button (only if assigned but not started yet)
                if (task.status == TaskStatus.assigned && !isActive) ...[
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

                // Continue Button (for accepted tasks not yet started)
                if (task.status == TaskStatus.accepted && !isActive) ...[
                  AppSpacing.h24,
                  SizedBox(
                    width: double.infinity,
                    child: AppButton(
                      text: 'Continue',
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

  Future<void> _openInMap(String postCode) async {
    final query = Uri.encodeComponent(postCode);
    final Uri url;
    if (Platform.isAndroid) {
      url = Uri.parse('geo:0,0?q=$query');
    } else if (Platform.isIOS) {
      url = Uri.parse('https://maps.apple.com/?q=$query');
    } else {
      url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
    }
    DebugLogger.log('🗺️', 'MAP', 'Opening map with postCode: $postCode');
    DebugLogger.log('🗺️', 'MAP', 'URL: $url');
    final canLaunch = await canLaunchUrl(url);
    DebugLogger.log('🗺️', 'MAP', 'canLaunchUrl: $canLaunch');
    if (canLaunch) {
      final launched = await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
      DebugLogger.log('🗺️', 'MAP', 'launchUrl result: $launched');
    } else {
      DebugLogger.error('MAP', 'Cannot launch URL: $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shadowColor: AppColors.disabledBtnText,
      child: Padding(
        padding: AppSpacing.p16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    task.customerName.isNotEmpty ? task.customerName : 'Task',
                    style: AppTypography.headlineSmall,
                  ),
                ),
                _StatusChip(status: task.status),
              ],
            ),
            if ((task.task?.services ?? []).isNotEmpty) ...[
              AppSpacing.h12,
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: task.task!.services!
                    .where((s) => s.name != null && s.name!.isNotEmpty)
                    .map((s) => _ServiceDetailChip(label: s.name!))
                    .toList(),
              ),
            ],
            if (task.businessName.isNotEmpty) ...[
              AppSpacing.h4,
              Text(
                task.businessName,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            AppSpacing.h16,
            const Divider(),
            AppSpacing.h12,
            _InfoRow(
              icon: AppIcons.profile,
              label: 'Customer',
              value: task.customerName,
            ),
            AppSpacing.h12,
            if (task.customerPhone.isNotEmpty) ...[
              _InfoRow(
                icon: AppIcons.call,
                label: 'Phone',
                value: task.customerPhone,
              ),
              AppSpacing.h12,
            ],
            if (task.location.isNotEmpty) ...[
              Row(
                children: [
                  Icon(AppIcons.location, size: 18, color: AppColors.primary),
                  AppSpacing.w12,
                  SizedBox(
                    width: 80,
                    child: Text(
                      'Location',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textLight,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(task.location, style: AppTypography.bodyMedium),
                  ),
                  if ((task.task?.customerInfo?.postCode ?? '').isNotEmpty)
                    TextButton.icon(
                      onPressed: () =>
                          _openInMap(task.task!.customerInfo!.postCode!),
                      icon: const Icon(Icons.map_outlined, size: 16),
                      label: const Text('Map'),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                ],
              ),
              AppSpacing.h12,
            ],
            if (task.scheduledAt != null) ...[
              _InfoRow(
                icon: AppIcons.clock,
                label: 'Scheduled',
                value: task.scheduledAt!.formatDateTime,
              ),
              AppSpacing.h12,
            ],
            _InfoRow(
              icon: AppIcons.calendar,
              label: 'Duration',
              value: '${task.durationMinutes} minutes',
            ),
            AppSpacing.h12,
            _InfoRow(
              icon: AppIcons.task,
              label: 'Type',
              value: task.bookingType.replaceAll('_', ' '),
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
    this.isOvertime = false,
    this.overtimeSeconds = 0,
  });

  final String timerDisplay;
  final int remainingSeconds;
  final int totalSeconds;
  final bool isOvertime;
  final int overtimeSeconds;

  @override
  Widget build(BuildContext context) {
    final progress = isOvertime
        ? 1.0
        : (totalSeconds > 0
              ? (totalSeconds - remainingSeconds) / totalSeconds
              : 0.0);

    final timerColor = isOvertime
        ? AppColors.error
        : (remainingSeconds < 60 ? AppColors.error : AppColors.primary);

    return Center(
      child: Column(
        children: [
          Text(
            isOvertime ? 'Overtime' : 'Time Remaining',
            style: AppTypography.titleMedium.copyWith(
              color: isOvertime ? AppColors.error : AppColors.textSecondary,
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
                    valueColor: AlwaysStoppedAnimation<Color>(timerColor),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      timerDisplay,
                      style: AppTypography.headlineLarge.copyWith(
                        color: timerColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      isOvertime ? 'overtime' : 'min : sec',
                      style: AppTypography.labelSmall.copyWith(
                        color: isOvertime
                            ? AppColors.error
                            : AppColors.textLight,
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

// ─── Status Chip ─────────────────────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final TaskStatus? status;

  @override
  Widget build(BuildContext context) {
    final label = switch (status) {
      TaskStatus.assigned => 'Assigned',
      TaskStatus.accepted => 'Accepted',
      TaskStatus.inProgress => 'In Progress',
      TaskStatus.completed => 'Completed',
      TaskStatus.cancelled => 'Cancelled',
      _ => 'Unknown',
    };
    final color = switch (status) {
      TaskStatus.assigned => AppColors.primary,
      TaskStatus.accepted => AppColors.success,
      TaskStatus.inProgress => AppColors.secondary,
      TaskStatus.completed => AppColors.success,
      TaskStatus.cancelled => AppColors.error,
      _ => AppColors.grey500,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTypography.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ServiceDetailChip extends StatelessWidget {
  const _ServiceDetailChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primary.withAlpha(80)),
        borderRadius: BorderRadius.circular(20),
        color: AppColors.primary.withAlpha(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(AppIcons.task, size: 14, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            label.toUpperCase(),
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
              fontSize: 11,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Payment Info Card ───────────────────────────────────────────────────────

class _PaymentInfoCard extends StatelessWidget {
  const _PaymentInfoCard({required this.task});
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
            Text('Payment Details', style: AppTypography.titleMedium),
            AppSpacing.h12,
            if (task.totalPrice.isNotEmpty)
              _InfoRow(
                icon: Icons.attach_money_rounded,
                label: 'Total',
                value: '£${task.totalPrice}',
              ),
            if (task.totalPrice.isNotEmpty) AppSpacing.h12,
            if (task.paymentStatus.isNotEmpty)
              _InfoRow(
                icon: Icons.payment_rounded,
                label: 'Status',
                value: task.paymentStatus.replaceAll('_', ' '),
              ),
          ],
        ),
      ),
    );
  }
}
