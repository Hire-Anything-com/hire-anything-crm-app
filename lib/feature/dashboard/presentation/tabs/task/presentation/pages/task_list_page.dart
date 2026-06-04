import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hireanythingbooking/core/core.dart';
import 'package:hireanythingbooking/core/extension/date_time_ext.dart';
import 'package:hireanythingbooking/feature/dashboard/presentation/tabs/task/presentation/cubit/task_cubit.dart';
import 'package:hireanythingbooking/feature/dashboard/presentation/tabs/task/presentation/cubit/task_state.dart';
import 'package:hireanythingbooking/feature/dashboard/presentation/tabs/task/data/model/task_model.dart';
import 'package:hireanythingbooking/feature/dashboard/presentation/tabs/task/presentation/pages/task_detail_page.dart';

class TaskListPage extends StatelessWidget {
  const TaskListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TaskCubit, TaskState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.errorMessage != null) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  state.errorMessage!,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.error,
                  ),
                  textAlign: TextAlign.center,
                ),
                AppSpacing.h16,
                ElevatedButton(
                  onPressed: () =>
                      context.read<TaskCubit>().fetchMyAssignments(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final assigned = state.assignedTasks;
        final accepted = state.acceptedTasks;
        final inProgress = state.inProgressTasks;
        final completed = state.completedTasks;
        final cancelled = state.cancelledTasks;
        final respondingTaskId = state.respondingTaskId;

        return CustomScrollView(
          slivers: [
            AppSliverAppBar(
              title: AppStrings.taskTitle,
              actions: [LogoutAction()],
            ),

            // Accepted Tasks
            if (accepted.isNotEmpty) ...[
              _buildSectionHeader(
                context,
                'Accepted Tasks',
                accepted.length,
                AppColors.success,
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList.separated(
                  itemCount: accepted.length,
                  separatorBuilder: (_, __) => AppSpacing.h8,
                  itemBuilder: (context, index) =>
                      _AssignedTaskCard(task: accepted[index]),
                ),
              ),
              const SliverToBoxAdapter(child: AppSpacing.h16),
            ],

            // Rejected Tasks
            if (cancelled.isNotEmpty) ...[
              _buildSectionHeader(
                context,
                'Rejected Tasks',
                cancelled.length,
                AppColors.error,
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList.separated(
                  itemCount: cancelled.length,
                  separatorBuilder: (_, __) => AppSpacing.h8,
                  itemBuilder: (context, index) =>
                      _AssignedTaskCard(task: cancelled[index]),
                ),
              ),
              const SliverToBoxAdapter(child: AppSpacing.h16),
            ],

            // In-Progress Tasks
            if (inProgress.isNotEmpty) ...[
              _buildSectionHeader(
                context,
                'In Progress',
                inProgress.length,
                AppColors.secondary,
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList.separated(
                  itemCount: inProgress.length,
                  separatorBuilder: (_, __) => AppSpacing.h8,
                  itemBuilder: (context, index) =>
                      _AssignedTaskCard(task: inProgress[index]),
                ),
              ),
              const SliverToBoxAdapter(child: AppSpacing.h16),
            ],

            // Assigned Tasks (with Accept/Reject buttons)
            if (assigned.isNotEmpty) ...[
              _buildSectionHeader(
                context,
                'Assigned Tasks',
                assigned.length,
                AppColors.primary,
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList.separated(
                  itemCount: assigned.length,
                  separatorBuilder: (_, __) => AppSpacing.h12,
                  itemBuilder: (context, index) {
                    final task = assigned[index];
                    return _AssignedTaskCard(
                      task: task,
                      isResponding: respondingTaskId == task.id,
                      onAccept: () =>
                          context.read<TaskCubit>().acceptTask(task.id ?? ''),
                      onReject: () => _showRejectDialog(context, task.id ?? ''),
                    );
                  },
                ),
              ),
              const SliverToBoxAdapter(child: AppSpacing.h24),
            ],

            // Completed Tasks
            if (completed.isNotEmpty) ...[
              _buildSectionHeader(
                context,
                'Completed Tasks',
                completed.length,
                AppColors.success,
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList.separated(
                  itemCount: completed.length,
                  separatorBuilder: (_, __) => AppSpacing.h8,
                  itemBuilder: (context, index) =>
                      _AssignedTaskCard(task: completed[index]),
                ),
              ),
              const SliverToBoxAdapter(child: AppSpacing.h16),
            ],

            // Empty state
            if (assigned.isEmpty &&
                accepted.isEmpty &&
                cancelled.isEmpty &&
                inProgress.isEmpty &&
                completed.isEmpty)
              const SliverFillRemaining(
                child: Center(child: Text(AppStrings.noData)),
              ),
          ],
        );
      },
    );
  }

  SliverToBoxAdapter _buildSectionHeader(
    BuildContext context,
    String title,
    int count,
    Color badgeColor,
  ) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
        child: Row(
          children: [
            Text(
              title,
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.grey900,
              ),
            ),
            const Spacer(),
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: badgeColor,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                '$count',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _showRejectDialog(BuildContext context, String taskId) async {
  final controller = TextEditingController();
  final cubit = context.read<TaskCubit>();

  final confirmed = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Reason for Rejection',
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.grey900,
          ),
        ),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Enter reason...',
            hintStyle: AppTypography.bodySmall.copyWith(
              color: AppColors.grey500,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.grey200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary),
            ),
            contentPadding: const EdgeInsets.all(12),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(
              'Cancel',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.grey500,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              'Reject',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      );
    },
  );

  if (confirmed == true) {
    await cubit.rejectTask(taskId, controller.text.trim());
  }
  controller.dispose();
}

// â”€â”€â”€ Assigned Task Card â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _AssignedTaskCard extends StatelessWidget {
  const _AssignedTaskCard({
    required this.task,
    this.onAccept,
    this.onReject,
    this.isResponding = false,
  });

  final TaskModel task;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final bool isResponding;

  @override
  Widget build(BuildContext context) {
    final isInProgress = task.status == TaskStatus.inProgress;
    final isCompleted = task.status == TaskStatus.completed;
    final isAssigned = task.status == TaskStatus.assigned;

    final statusColor = switch (task.status) {
      TaskStatus.accepted => AppColors.success,
      TaskStatus.inProgress => AppColors.secondary,
      TaskStatus.completed => AppColors.success,
      TaskStatus.cancelled => AppColors.error,
      _ => AppColors.primary,
    };

    final statusLabel = switch (task.status) {
      TaskStatus.accepted => 'ACCEPTED',
      TaskStatus.inProgress => 'IN PROGRESS',
      TaskStatus.completed => 'COMPLETED',
      TaskStatus.cancelled => 'CANCELLED',
      _ => 'ASSIGNED',
    };

    final isCancelled = task.status == TaskStatus.cancelled;

    return GestureDetector(
      onTap: isCancelled
          ? null
          : () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => BlocProvider.value(
                  value: context.read<TaskCubit>(),
                  child: TaskDetailPage(taskId: task.id ?? ''),
                ),
              ),
            ),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha(20),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isInProgress
                        ? AppIcons.clock
                        : isCompleted
                        ? Icons.check_circle_outline_rounded
                        : AppIcons.task,
                    color: statusColor,
                    size: 22,
                  ),
                ),
                AppSpacing.w12,
                Expanded(
                  child: Text(
                    task.customerName,
                    style: AppTypography.titleSmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.grey900,
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withAlpha(20),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        statusLabel,
                        style: AppTypography.labelSmall.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    AppSpacing.h4,
                    if (task.scheduledAt != null)
                      Text(
                        task.scheduledAt!.formatTime,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.grey500,
                        ),
                      ),
                  ],
                ),
              ],
            ),
            // Services chips
            if ((task.task?.services ?? []).isNotEmpty) ...[
              AppSpacing.h12,
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: task.task!.services!
                    .where((s) => s.name != null && s.name!.isNotEmpty)
                    .map((s) => _ServiceChip(label: s.name!))
                    .toList(),
              ),
            ],

            AppSpacing.h12,

            // Info row
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.grey50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  if (task.location.isNotEmpty)
                    Row(
                      children: [
                        const Icon(
                          AppIcons.location,
                          size: 16,
                          color: AppColors.grey500,
                        ),
                        AppSpacing.w8,
                        Expanded(
                          child: Text(
                            task.location,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.grey700,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  if (task.location.isNotEmpty) AppSpacing.h8,
                  Row(
                    children: [
                      const Icon(
                        AppIcons.clock,
                        size: 16,
                        color: AppColors.grey500,
                      ),
                      AppSpacing.w8,
                      Text(
                        '${task.durationMinutes} min',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.grey700,
                        ),
                      ),
                      if (task.totalPrice.isNotEmpty) ...[
                        const Spacer(),
                        Text(
                          '£${task.totalPrice}',
                          style: AppTypography.titleSmall.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.grey900,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Accept / Reject buttons (assigned tasks only)
            if (isAssigned) ...[
              AppSpacing.h12,
              if (isResponding)
                const Center(child: CircularProgressIndicator())
              else
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onReject,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.error),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        child: Text(
                          'Reject',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    AppSpacing.w12,
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onAccept,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        child: Text(
                          'Accept',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ],
        ),
      ),
    );
  }
}

// â”€â”€â”€ Service Chip â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _ServiceChip extends StatelessWidget {
  const _ServiceChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primary.withAlpha(80)),
        borderRadius: BorderRadius.circular(20),
        color: AppColors.primary.withAlpha(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(AppIcons.task, size: 12, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(
            label.toUpperCase(),
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
              fontSize: 10,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
