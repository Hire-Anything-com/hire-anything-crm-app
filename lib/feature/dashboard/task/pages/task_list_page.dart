import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hireanythingbooking/core/core.dart';
import 'package:hireanythingbooking/core/extension/date_time_ext.dart';
import 'package:hireanythingbooking/feature/dashboard/task/cubit/task_cubit.dart';
import 'package:hireanythingbooking/feature/dashboard/task/cubit/task_state.dart';
import 'package:hireanythingbooking/feature/dashboard/task/model/task_model.dart';
import 'package:hireanythingbooking/feature/dashboard/task/pages/task_detail_page.dart';

class TaskListPage extends StatelessWidget {
  const TaskListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TaskCubit, TaskState>(
      builder: (context, state) {
        final pending = state.pendingTasks;
        final accepted = state.acceptedTasks;
        final rejected = state.rejectedTasks;

        return CustomScrollView(
          slivers: [
            const AppSliverAppBar(
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
                      _AcceptedTaskCard(task: accepted[index]),
                ),
              ),
              const SliverToBoxAdapter(child: AppSpacing.h16),
            ],

            // Rejected Tasks
            if (rejected.isNotEmpty) ...[
              _buildSectionHeader(
                context,
                'Rejected Tasks',
                rejected.length,
                AppColors.error,
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList.separated(
                  itemCount: rejected.length,
                  separatorBuilder: (_, __) => AppSpacing.h8,
                  itemBuilder: (context, index) =>
                      _RejectedTaskCard(task: rejected[index]),
                ),
              ),
              const SliverToBoxAdapter(child: AppSpacing.h16),
            ],

            // New / Pending Tasks
            if (pending.isNotEmpty) ...[
              _buildSectionHeader(
                context,
                'New Tasks',
                pending.length,
                AppColors.primary,
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList.separated(
                  itemCount: pending.length,
                  separatorBuilder: (_, __) => AppSpacing.h12,
                  itemBuilder: (context, index) =>
                      _PendingTaskCard(task: pending[index]),
                ),
              ),
              const SliverToBoxAdapter(child: AppSpacing.h24),
            ],

            // Empty state
            if (pending.isEmpty && accepted.isEmpty && rejected.isEmpty)
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

// ─── Pending Task Card ───────────────────────────────────────────────────────

class _PendingTaskCard extends StatelessWidget {
  const _PendingTaskCard({required this.task});

  final TaskModel task;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row: name + time/duration
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.grey900,
                      ),
                    ),
                    AppSpacing.h4,
                    Text(
                      task.customerName,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    task.scheduledAt.formatTime,
                    style: AppTypography.titleSmall.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.grey900,
                    ),
                  ),
                  AppSpacing.h4,
                  Text(
                    '${(task.durationMinutes / 60).toStringAsFixed(1)} HRS',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.grey500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          AppSpacing.h16,

          // Location & Description info rows
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.grey50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
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
                AppSpacing.h8,
                Row(
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      size: 16,
                      color: AppColors.grey500,
                    ),
                    AppSpacing.w8,
                    Expanded(
                      child: Text(
                        '"${task.description}"',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.grey700,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          AppSpacing.h16,

          // Action buttons
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 46,
                  child: OutlinedButton(
                    onPressed: () =>
                        context.read<TaskCubit>().rejectTask(task.id),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(
                        color: AppColors.error,
                        width: 1.5,
                      ),
                      backgroundColor: AppColors.error.withAlpha(12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'Reject',
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              AppSpacing.w12,
              Expanded(
                child: SizedBox(
                  height: 46,
                  child: ElevatedButton(
                    onPressed: () =>
                        context.read<TaskCubit>().acceptTask(task.id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: AppColors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'Accept',
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Accepted Task Card ──────────────────────────────────────────────────────

class _AcceptedTaskCard extends StatelessWidget {
  const _AcceptedTaskCard({required this.task});

  final TaskModel task;

  @override
  Widget build(BuildContext context) {
    final isInProgress = task.status == TaskStatus.inProgress;

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => BlocProvider.value(
            value: context.read<TaskCubit>(),
            child: TaskDetailPage(taskId: task.id),
          ),
        ),
      ),
      child: AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isInProgress
                    ? AppColors.secondary.withAlpha(20)
                    : AppColors.success.withAlpha(20),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isInProgress ? AppIcons.clock : AppIcons.task,
                color: isInProgress ? AppColors.secondary : AppColors.success,
                size: 22,
              ),
            ),
            AppSpacing.w12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: AppTypography.titleSmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.grey900,
                    ),
                  ),
                  AppSpacing.h4,
                  Row(
                    children: [
                      Text(
                        task.customerName,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.grey500,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Text(
                          '•',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.grey400,
                          ),
                        ),
                      ),
                      Text(
                        task.scheduledAt.formatTime,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.grey500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: isInProgress
                    ? AppColors.secondary.withAlpha(20)
                    : AppColors.success.withAlpha(20),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isInProgress ? 'IN PROGRESS' : 'ACCEPTED',
                style: AppTypography.labelSmall.copyWith(
                  color: isInProgress ? AppColors.secondary : AppColors.success,
                  fontWeight: FontWeight.w700,
                  fontSize: 10,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            AppSpacing.w4,
            const Icon(AppIcons.forward, size: 18, color: AppColors.grey400),
          ],
        ),
      ),
    );
  }
}

// ─── Rejected Task Card ──────────────────────────────────────────────────────

class _RejectedTaskCard extends StatelessWidget {
  const _RejectedTaskCard({required this.task});

  final TaskModel task;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.grey200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(AppIcons.close, color: AppColors.grey500, size: 22),
          ),
          AppSpacing.w12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: AppTypography.titleSmall.copyWith(
                    color: AppColors.grey500,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                AppSpacing.h4,
                Text(
                  'Request expired',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.grey400,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.error.withAlpha(15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'REJECTED',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w700,
                fontSize: 10,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
