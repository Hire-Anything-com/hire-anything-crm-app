import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hireanythingbooking/core/core.dart';
import 'package:hireanythingbooking/core/extension/date_time_ext.dart';
import 'package:hireanythingbooking/feature/dashboard/task/cubit/task_cubit.dart';
import 'package:hireanythingbooking/feature/dashboard/task/cubit/task_state.dart';
import 'package:hireanythingbooking/feature/dashboard/task/model/task_model.dart';

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
                _TaskTable(
                  tasks: state.acceptedTasks,
                  emptyMessage: 'No accepted tasks yet',
                  statusColor: AppColors.success,
                  statusLabel: 'Accepted',
                ),
                _TaskTable(
                  tasks: state.rejectedTasks,
                  emptyMessage: 'No rejected tasks yet',
                  statusColor: AppColors.error,
                  statusLabel: 'Rejected',
                ),
                _TaskTable(
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

class _TaskTable extends StatelessWidget {
  const _TaskTable({
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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(AppColors.info),
            dataRowColor: WidgetStateProperty.resolveWith((states) => null),
            border: TableBorder.all(
              color: AppColors.borderLight,
              borderRadius: BorderRadius.circular(12),
            ),
            headingTextStyle: AppTypography.labelMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.white,
            ),
            dataTextStyle: AppTypography.bodySmall.copyWith(
              color: AppColors.textPrimary,
            ),
            columnSpacing: 20,
            columns: const [
              DataColumn(label: Text('#')),
              DataColumn(label: Text('Task')),
              DataColumn(label: Text('Customer')),
              DataColumn(label: Text('Date')),
              DataColumn(label: Text('Status')),
            ],
            rows: tasks.asMap().entries.map((entry) {
              final index = entry.key;
              final task = entry.value;
              return DataRow(
                color: WidgetStateProperty.all(
                  index.isEven ? AppColors.white : AppColors.grey50,
                ),
                cells: [
                  DataCell(Text('${index + 1}')),
                  DataCell(
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 160),
                      child: Text(
                        task.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  DataCell(Text(task.customerName)),
                  DataCell(Text(task.scheduledAt.formatDate)),
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withAlpha(25),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        statusLabel,
                        style: AppTypography.labelSmall.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
