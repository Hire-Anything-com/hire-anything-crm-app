import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hireanythingbooking/core/core.dart';
import 'package:hireanythingbooking/core/extension/date_time_ext.dart';
import 'package:hireanythingbooking/feature/dashboard/presentation/tabs/task/presentation/cubit/task_cubit.dart';
import 'package:hireanythingbooking/feature/dashboard/presentation/tabs/task/presentation/cubit/task_state.dart';
import 'package:hireanythingbooking/feature/dashboard/presentation/tabs/task/data/model/task_model.dart';
import 'package:hireanythingbooking/feature/dashboard/presentation/tabs/task/presentation/pages/task_detail_page.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppAppBar(
          title: AppStrings.history,
          actions: const [LogoutAction()],
          bottom: TabBar(
            labelColor: AppColors.white,
            unselectedLabelColor: AppColors.white.withAlpha(180),
            indicatorColor: AppColors.white,
            indicatorWeight: 3,
            labelStyle: AppTypography.labelLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: AppTypography.labelLarge,
            tabs: const [
              Tab(text: 'Accepted'),
              Tab(text: 'Rejected'),
              Tab(text: 'Completed'),
            ],
          ),
        ),
        body: BlocBuilder<TaskCubit, TaskState>(
          builder: (context, state) {
            return TabBarView(
              children: [
                _TaskList(
                  tasks: state.acceptedTasks,
                  emptyMessage: 'No accepted tasks yet',
                  statusColor: AppColors.success,
                  statusLabel: 'Accepted',
                ),
                _TaskList(
                  tasks: state.cancelledTasks,
                  emptyMessage: 'No rejected tasks yet',
                  statusColor: AppColors.error,
                  statusLabel: 'Rejected',
                ),
                _TaskList(
                  tasks: state.completedTasks,
                  emptyMessage: 'No completed tasks yet',
                  statusColor: AppColors.success,
                  statusLabel: 'Completed',
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _TaskList extends StatelessWidget {
  const _TaskList({
    required this.tasks,
    required this.emptyMessage,
    required this.statusColor,
    required this.statusLabel,
  });

  final List<TaskModel> tasks;
  final String emptyMessage;
  final Color statusColor;
  final String statusLabel;

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(AppIcons.task, size: 48, color: AppColors.grey300),
            AppSpacing.h12,
            Text(
              emptyMessage,
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.textLight,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: tasks.length,
      separatorBuilder: (_, __) => AppSpacing.h12,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return _HistoryTaskCard(
          task: task,
          statusLabel: statusLabel,
          statusColor: statusColor,
        );
      },
    );
  }
}

class _HistoryTaskCard extends StatelessWidget {
  const _HistoryTaskCard({
    required this.task,
    required this.statusLabel,
    required this.statusColor,
  });

  final TaskModel task;
  final String statusLabel;
  final Color statusColor;

  @override
  Widget build(BuildContext context) {
    final isInProgress = task.status == TaskStatus.inProgress;
    final isCompleted = task.status == TaskStatus.completed;
    final isAssigned = task.status == TaskStatus.assigned;

    final statusColorLocal = switch (task.status) {
      TaskStatus.accepted => AppColors.success,
      TaskStatus.inProgress => AppColors.secondary,
      TaskStatus.completed => AppColors.success,
      TaskStatus.cancelled => AppColors.error,
      _ => AppColors.primary,
    };

    final statusLabelLocal = switch (task.status) {
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
                    color: statusColorLocal.withAlpha(20),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isInProgress
                        ? AppIcons.clock
                        : isCompleted
                        ? Icons.check_circle_outline_rounded
                        : AppIcons.task,
                    color: statusColorLocal,
                    size: 22,
                  ),
                ),
                AppSpacing.w12,
                Expanded(
                  child: Text(
                    task.customerName.isNotEmpty ? task.customerName : 'Task',
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
                        color: statusColorLocal.withAlpha(20),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        statusLabelLocal,
                        style: AppTypography.labelSmall.copyWith(
                          color: statusColorLocal,
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
