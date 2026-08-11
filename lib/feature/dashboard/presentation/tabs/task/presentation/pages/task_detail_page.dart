import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hireanythingbooking/core/core.dart';
import 'package:hireanythingbooking/core/utils/debug_logger.dart';
import 'package:hireanythingbooking/core/extension/date_time_ext.dart';
import 'package:hireanythingbooking/feature/dashboard/presentation/tabs/task/presentation/cubit/task_cubit.dart';
import 'package:hireanythingbooking/feature/dashboard/presentation/tabs/task/presentation/cubit/task_state.dart';
import 'package:hireanythingbooking/feature/dashboard/presentation/tabs/task/data/model/assignment_detail_model.dart';
import 'package:hireanythingbooking/feature/dashboard/presentation/tabs/task/data/model/task_model.dart';
import 'package:hireanythingbooking/feature/dashboard/presentation/tabs/task/presentation/pages/task_photo_page.dart';
import 'package:hireanythingbooking/feature/dashboard/presentation/tabs/task/presentation/pages/task_otp_page.dart';
import 'package:url_launcher/url_launcher.dart';

class TaskDetailPage extends StatefulWidget {
  const TaskDetailPage({required this.taskId, super.key});
  final String taskId;

  @override
  State<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.taskId.isNotEmpty) {
        context.read<TaskCubit>().fetchAssignmentDetails(widget.taskId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TaskCubit, TaskState>(
      listenWhen: (prev, curr) => prev.isTimerRunning && !curr.isTimerRunning,
      listener: (context, state) async {
        // When timer stops, navigate to photo screen if photos are required.
        // Otherwise call the photos API with empty payload and proceed to OTP/completion.
        final cubit = context.read<TaskCubit>();
        final assignment = state.selectedAssignment;
        final requirePhotos = assignment?.task?.requirePhotos ?? false;
        final requireOtp = assignment?.task?.requireOtp ?? false;

        final navigator = Navigator.of(context);

        if (requirePhotos) {
          navigator.pushReplacement(
            MaterialPageRoute<void>(
              builder: (_) => BlocProvider.value(
                value: cubit,
                child: const TaskPhotoPage(),
              ),
            ),
          );
          return;
        }

        // Photos not required — call photos API with empty list
        final startTime =
            state.taskStartTimeEpoch ??
            DateTime.now().millisecondsSinceEpoch ~/ 1000;
        final endTime =
            state.taskEndTimeEpoch ??
            DateTime.now().millisecondsSinceEpoch ~/ 1000;
        final photosOk = await cubit.submitPhotosSkippingUI(
          startTime: startTime,
          endTime: endTime,
        );
        if (!photosOk) {
          AppSnackBar.show(
            context,
            message: 'Failed submitting photos',
            type: SnackBarType.error,
          );
          return;
        }

        // If OTP required, navigate to OTP page; otherwise complete with empty otp
        if (requireOtp) {
          navigator.pushReplacement(
            MaterialPageRoute<void>(
              builder: (_) =>
                  BlocProvider.value(value: cubit, child: const TaskOtpPage()),
            ),
          );
          return;
        }

        // Neither photos nor OTP required — complete task by sending empty otp
        final completed = await cubit.verifyOtp('');
        if (completed) {
          AppSnackBar.show(
            context,
            message: 'Task completed successfully!',
            type: SnackBarType.success,
          );
          navigator.popUntil((route) => route.isFirst);
        }
      },
      builder: (context, state) {
        final assignment =
            state.selectedAssignment ?? const AssignmentDetailModel();
        // Show loader while fetching assignment details for this page id
        if (state.isLoading &&
            (state.selectedAssignment == null ||
                state.selectedAssignment!.id != widget.taskId)) {
          return Scaffold(
            appBar: const AppAppBar(title: 'Task Details'),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        final isActive = state.activeTaskId == widget.taskId;

        TaskStatus _parseStatus(String? value) {
          switch (value?.toUpperCase()) {
            case 'ACCEPTED':
              return TaskStatus.accepted;
            case 'IN_PROGRESS':
              return TaskStatus.inProgress;
            case 'COMPLETED':
              return TaskStatus.completed;
            case 'CANCELLED':
              return TaskStatus.cancelled;
            case 'ASSIGNED':
            default:
              return TaskStatus.assigned;
          }
        }

        final statusEnum = _parseStatus(assignment.status);

        return Stack(
          children: [
            Scaffold(
              appBar: const AppAppBar(title: 'Task Details'),
              body: SingleChildScrollView(
                padding: AppSpacing.p16.copyWith(
                  bottom: 16 + MediaQuery.of(context).padding.bottom + 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Task Info Card
                    _TaskInfoCard(assignment: assignment, status: statusEnum),

                    AppSpacing.h24,

                    // Timer Section (only if task is in-progress)
                    if (isActive && state.isTimerRunning) ...[
                      _TimerSection(
                        timerDisplay: state.timerDisplay,
                        remainingSeconds: state.remainingSeconds,
                        totalSeconds:
                            (assignment.task?.estimateMinutes ?? 0) * 60,
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
                            // Only stop timer here — navigation/next-steps handled
                            // by the BlocConsumer listener (so we can conditionally
                            // skip photo/OTP screens based on assignment flags).
                            context.read<TaskCubit>().stopTimer();
                          },
                        ),
                      ),
                    ],

                    // Start Button (only if assigned but not started yet)
                    if (statusEnum == TaskStatus.assigned && !isActive) ...[
                      AppSpacing.h24,
                      SizedBox(
                        width: double.infinity,
                        child: AppButton(
                          text: 'Start Task',
                          backgroundColor: AppColors.primary,
                          onPressed: () =>
                              _handleStartTask(context, widget.taskId),
                        ),
                      ),
                    ],

                    // Continue Button (for accepted tasks not yet started)
                    if (statusEnum == TaskStatus.accepted && !isActive) ...[
                      AppSpacing.h24,
                      SizedBox(
                        width: double.infinity,
                        child: AppButton(
                          text: 'Continue',
                          backgroundColor: AppColors.primary,
                          onPressed: () =>
                              _handleStartTask(context, widget.taskId),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Background processing overlay when photos/otp calls are running
            if (state.isUploadingPhotos || state.isCompletingTask)
              Positioned.fill(
                child: Container(
                  color: Colors.black45,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.symmetric(horizontal: 40),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(
                            width: 48,
                            height: 48,
                            child: CircularProgressIndicator(),
                          ),
                          AppSpacing.h12,
                          Text(
                            state.isUploadingPhotos
                                ? 'Submitting photos...'
                                : state.isCompletingTask
                                ? 'Completing task...'
                                : 'Processing...',
                            textAlign: TextAlign.center,
                            style: AppTypography.titleMedium.copyWith(
                              color: AppColors.textPrimary,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
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
          title: const Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: AppColors.warning,
                size: 28,
              ),
              AppSpacing.w8,
              Text('Early Start'),
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
  const _TaskInfoCard({required this.assignment, required this.status});
  final AssignmentDetailModel assignment;
  final TaskStatus status;

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
    final detail = assignment.task;
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
                    (detail?.customerName ?? '').isNotEmpty
                        ? (detail?.customerName ?? '')
                        : 'Task',
                    style: AppTypography.headlineSmall,
                  ),
                ),
                _StatusChip(status: status),
              ],
            ),
            if ((detail?.services ?? []).isNotEmpty) ...[
              AppSpacing.h12,
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: detail!.services!
                    .where((s) => s.name != null && s.name!.isNotEmpty)
                    .map((s) => _ServiceDetailChip(label: s.name!))
                    .toList(),
              ),
            ],
            if ((detail?.business?.name ?? '').isNotEmpty) ...[
              AppSpacing.h4,
              Text(
                detail?.business?.name ?? '',
                style: AppTypography.bodySmall.copyWith(
                  // color: AppColors.primary,
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
              value: detail?.customerName ?? '',
            ),
            AppSpacing.h12,
            if ((detail?.customerPhone ?? '').isNotEmpty) ...[
              _InfoRow(
                icon: AppIcons.call,
                label: 'Phone',
                value: detail?.customerPhone ?? '',
              ),
              AppSpacing.h12,
            ],
            if ((detail?.customerInfo?.fullAddress ?? '').isNotEmpty) ...[
              Row(
                children: [
                  const Icon(
                    AppIcons.location,
                    size: 18,
                    color: AppColors.primary,
                  ),
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
                    child: Text(
                      detail?.customerInfo?.fullAddress ?? '',
                      style: AppTypography.bodyMedium,
                    ),
                  ),
                  if ((detail?.customerInfo?.postCode ?? '').isNotEmpty)
                    TextButton.icon(
                      onPressed: () =>
                          _openInMap(detail!.customerInfo!.postCode!),
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
            if (detail?.scheduledDateTime != null) ...[
              _InfoRow(
                icon: AppIcons.clock,
                label: 'Scheduled',
                value: detail!.scheduledDateTime!.formatDateTime,
              ),
              AppSpacing.h12,
            ],
            _InfoRow(
              icon: AppIcons.calendar,
              label: 'Duration',
              value: '${detail?.estimateMinutes ?? 0} minutes',
            ),
            AppSpacing.h12,
            // Services as type chips
            // if ((detail?.services ?? []).isNotEmpty) ...[
            //   AppSpacing.h8,
            //   Wrap(
            //     spacing: 8,
            //     children: detail!.services!
            //         .where((s) => s.name != null && s.name!.isNotEmpty)
            //         .map((s) => _ServiceDetailChip(label: s.name!))
            //         .toList(),
            //   ),
            //   AppSpacing.h12,
            // ],
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
