import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hireanythingbooking/core/core.dart';
import 'package:hireanythingbooking/core/extension/date_time_ext.dart';
import 'package:hireanythingbooking/feature/dashboard/leave/cubit/leave_cubit.dart';
import 'package:hireanythingbooking/feature/dashboard/leave/cubit/leave_state.dart';
import 'package:hireanythingbooking/feature/dashboard/leave/model/leave_model.dart';
import 'package:table_calendar/table_calendar.dart';

class LeavePage extends StatelessWidget {
  const LeavePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LeaveCubit, LeaveState>(
      builder: (context, state) {
        final selectedLeaves = state.selectedDay != null
            ? state.leavesForDay(state.selectedDay!)
            : <LeaveModel>[];

        return Scaffold(
          appBar: const AppAppBar(
            title: AppStrings.leaves,
            actions: [LogoutAction()],
          ),
          body: CustomScrollView(
            slivers: [
              // Calendar
              SliverToBoxAdapter(
                child: AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  alignment: Alignment.topCenter,
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.black.withAlpha(25),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: TableCalendar<LeaveModel>(
                        firstDay: DateTime.now(),
                        lastDay: DateTime.now().add(const Duration(days: 365)),
                        focusedDay: state.currentFocusedDay,
                        enabledDayPredicate: (day) {
                          final today = DateTime.now();
                          final todayNorm = DateTime(
                            today.year,
                            today.month,
                            today.day,
                          );
                          return !day.isBefore(todayNorm);
                        },
                        selectedDayPredicate: (day) =>
                            state.selectedDay != null &&
                            isSameDay(state.selectedDay, day),
                        eventLoader: state.leavesForDay,
                        onDaySelected: (selected, focused) {
                          context.read<LeaveCubit>().selectDay(selected);
                        },
                        onPageChanged: (focused) {
                          context.read<LeaveCubit>().changeFocusedDay(focused);
                        },
                        availableCalendarFormats: const {
                          CalendarFormat.month: 'Month',
                        },
                        headerStyle: HeaderStyle(
                          titleCentered: true,
                          formatButtonVisible: false,
                          titleTextStyle: AppTypography.titleMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          leftChevronIcon: const Icon(
                            Icons.chevron_left,
                            color: AppColors.primary,
                          ),
                          rightChevronIcon: const Icon(
                            Icons.chevron_right,
                            color: AppColors.primary,
                          ),
                        ),
                        daysOfWeekStyle: DaysOfWeekStyle(
                          weekdayStyle: AppTypography.labelSmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          weekendStyle: AppTypography.labelSmall.copyWith(
                            color: AppColors.textLight,
                          ),
                        ),
                        calendarStyle: CalendarStyle(
                          todayDecoration: BoxDecoration(
                            color: AppColors.primary.withAlpha(50),
                            shape: BoxShape.circle,
                          ),
                          todayTextStyle: AppTypography.bodyMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                          selectedDecoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          selectedTextStyle: AppTypography.bodyMedium.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w600,
                          ),
                          markerDecoration: const BoxDecoration(
                            color: AppColors.secondary,
                            shape: BoxShape.circle,
                          ),
                          markerSize: 6,
                          markersMaxCount: 1,
                          outsideDaysVisible: false,
                          weekendTextStyle: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textLight,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Selected day leaves
              if (state.selectedDay != null && selectedLeaves.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: Text(
                      'Leaves on ${state.selectedDay!.formatDate}',
                      style: AppTypography.titleSmall.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList.separated(
                    itemCount: selectedLeaves.length,
                    separatorBuilder: (_, __) => AppSpacing.h8,
                    itemBuilder: (_, i) => _LeaveCard(leave: selectedLeaves[i]),
                  ),
                ),
                const SliverToBoxAdapter(child: AppSpacing.h16),
              ],

              // Upcoming Leaves
              if (state.upcomingLeaves.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Row(
                      children: [
                        Text(
                          'Upcoming Leaves',
                          style: AppTypography.titleSmall.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        AppSpacing.w8,
                        _CountBadge(count: state.upcomingLeaves.length),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList.separated(
                    itemCount: state.upcomingLeaves.length,
                    separatorBuilder: (_, __) => AppSpacing.h8,
                    itemBuilder: (_, i) =>
                        _LeaveCard(leave: state.upcomingLeaves[i]),
                  ),
                ),
                const SliverToBoxAdapter(child: AppSpacing.h16),
              ],

              // Past Leaves
              if (state.pastLeaves.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Row(
                      children: [
                        Text(
                          'Past Leaves',
                          style: AppTypography.titleSmall.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        AppSpacing.w8,
                        _CountBadge(count: state.pastLeaves.length),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList.separated(
                    itemCount: state.pastLeaves.length,
                    separatorBuilder: (_, __) => AppSpacing.h8,
                    itemBuilder: (_, i) =>
                        _LeaveCard(leave: state.pastLeaves[i]),
                  ),
                ),
                const SliverToBoxAdapter(child: AppSpacing.h24),
              ],
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showApplyLeaveSheet(context, state.selectedDay),
            icon: const Icon(Icons.add),
            label: const Text('Apply Leave'),
          ),
        );
      },
    );
  }

  void _showApplyLeaveSheet(BuildContext context, DateTime? preselectedDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    var isMultiple = false;
    DateTime? singleDate;
    DateTime? startDate;
    DateTime? endDate;
    if (preselectedDate != null && !preselectedDate.isBefore(today)) {
      singleDate = DateTime(
        preselectedDate.year,
        preselectedDate.month,
        preselectedDate.day,
      );
    }
    var selectedType = LeaveType.casual;
    final reasonController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    var dateError = '';
    final existingLeaves = context.read<LeaveCubit>().state;

    // Don't preselect a date that already has a leave
    if (singleDate != null && existingLeaves.hasLeaveOnDay(singleDate!)) {
      singleDate = null;
    }

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  24,
                  16,
                  24,
                  MediaQuery.of(sheetContext).viewInsets.bottom + 24,
                ),
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: AppColors.grey300,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        AppSpacing.h16,
                        Text(
                          'Apply for Leave',
                          style: AppTypography.titleMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        AppSpacing.h24,

                        // Single / Multiple toggle
                        Row(
                          children: [
                            Expanded(
                              child: ChoiceChip(
                                label: const Text('Single Day'),
                                selected: !isMultiple,
                                selectedColor: AppColors.primary.withAlpha(30),
                                labelStyle: AppTypography.labelMedium.copyWith(
                                  color: !isMultiple
                                      ? AppColors.primary
                                      : AppColors.textSecondary,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                side: BorderSide(
                                  color: !isMultiple
                                      ? AppColors.primary
                                      : AppColors.borderLight,
                                ),
                                onSelected: (_) {
                                  setSheetState(() {
                                    isMultiple = false;
                                    startDate = null;
                                    endDate = null;
                                  });
                                },
                              ),
                            ),
                            AppSpacing.w8,
                            Expanded(
                              child: ChoiceChip(
                                label: const Text('Multiple Days'),
                                selected: isMultiple,
                                selectedColor: AppColors.primary.withAlpha(30),
                                labelStyle: AppTypography.labelMedium.copyWith(
                                  color: isMultiple
                                      ? AppColors.primary
                                      : AppColors.textSecondary,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                side: BorderSide(
                                  color: isMultiple
                                      ? AppColors.primary
                                      : AppColors.borderLight,
                                ),
                                onSelected: (_) {
                                  setSheetState(() {
                                    isMultiple = true;
                                    singleDate = null;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        AppSpacing.h16,

                        // Date selection
                        if (dateError.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              dateError,
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.error,
                              ),
                            ),
                          ),
                        if (!isMultiple) ...[
                          // Single date picker
                          GestureDetector(
                            onTap: () async {
                              final singleInitial = singleDate ?? today;
                              final picked = await showDatePicker(
                                context: sheetContext,
                                initialDate:
                                    existingLeaves.hasLeaveOnDay(singleInitial)
                                    ? null
                                    : singleInitial,
                                firstDate: today,
                                lastDate: today.add(const Duration(days: 365)),
                                selectableDayPredicate: (day) =>
                                    !existingLeaves.hasLeaveOnDay(day),
                              );
                              if (picked != null) {
                                setSheetState(() {
                                  singleDate = DateTime(
                                    picked.year,
                                    picked.month,
                                    picked.day,
                                  );
                                  dateError = '';
                                });
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.blueLighten5,
                                borderRadius: BorderRadius.circular(12),
                                border:
                                    dateError.isNotEmpty && singleDate == null
                                    ? Border.all(color: AppColors.error)
                                    : null,
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    AppIcons.calendar,
                                    color: AppColors.primary,
                                    size: 20,
                                  ),
                                  AppSpacing.w12,
                                  Expanded(
                                    child: Text(
                                      singleDate != null
                                          ? singleDate!.formatDate
                                          : 'Select date',
                                      style: AppTypography.bodyLarge.copyWith(
                                        fontWeight: FontWeight.w500,
                                        color: singleDate != null
                                            ? null
                                            : AppColors.textLight,
                                      ),
                                    ),
                                  ),
                                  const Icon(
                                    Icons.edit_calendar,
                                    color: AppColors.primary,
                                    size: 18,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ] else ...[
                          // Start date
                          GestureDetector(
                            onTap: () async {
                              final startInitial = startDate ?? today;
                              final picked = await showDatePicker(
                                context: sheetContext,
                                initialDate:
                                    existingLeaves.hasLeaveOnDay(startInitial)
                                    ? null
                                    : startInitial,
                                firstDate: today,
                                lastDate: today.add(const Duration(days: 365)),
                                selectableDayPredicate: (day) =>
                                    !existingLeaves.hasLeaveOnDay(day),
                              );
                              if (picked != null) {
                                setSheetState(() {
                                  startDate = DateTime(
                                    picked.year,
                                    picked.month,
                                    picked.day,
                                  );
                                  dateError = '';
                                  // Reset end date if it's before new start
                                  if (endDate != null &&
                                      endDate!.isBefore(startDate!)) {
                                    endDate = null;
                                  }
                                });
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.blueLighten5,
                                borderRadius: BorderRadius.circular(12),
                                border:
                                    dateError.isNotEmpty && startDate == null
                                    ? Border.all(color: AppColors.error)
                                    : null,
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    AppIcons.calendar,
                                    color: AppColors.primary,
                                    size: 20,
                                  ),
                                  AppSpacing.w12,
                                  Expanded(
                                    child: Text(
                                      startDate != null
                                          ? 'From: ${startDate!.formatDate}'
                                          : 'Select start date',
                                      style: AppTypography.bodyMedium.copyWith(
                                        fontWeight: FontWeight.w500,
                                        color: startDate != null
                                            ? null
                                            : AppColors.textLight,
                                      ),
                                    ),
                                  ),
                                  const Icon(
                                    Icons.edit_calendar,
                                    color: AppColors.primary,
                                    size: 18,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          AppSpacing.h8,
                          // End date
                          GestureDetector(
                            onTap: () async {
                              final firstDate = startDate != null
                                  ? startDate!.add(const Duration(days: 1))
                                  : today;
                              final endInitial = endDate ?? firstDate;
                              final picked = await showDatePicker(
                                context: sheetContext,
                                initialDate:
                                    existingLeaves.hasLeaveOnDay(endInitial)
                                    ? null
                                    : endInitial,
                                firstDate: firstDate,
                                lastDate: today.add(const Duration(days: 365)),
                                selectableDayPredicate: (day) =>
                                    !existingLeaves.hasLeaveOnDay(day),
                              );
                              if (picked != null) {
                                setSheetState(() {
                                  endDate = DateTime(
                                    picked.year,
                                    picked.month,
                                    picked.day,
                                  );
                                  dateError = '';
                                });
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.blueLighten5,
                                borderRadius: BorderRadius.circular(12),
                                border: dateError.isNotEmpty && endDate == null
                                    ? Border.all(color: AppColors.error)
                                    : null,
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    AppIcons.calendar,
                                    color: AppColors.primary,
                                    size: 20,
                                  ),
                                  AppSpacing.w12,
                                  Expanded(
                                    child: Text(
                                      endDate != null
                                          ? 'To: ${endDate!.formatDate}'
                                          : 'Select end date',
                                      style: AppTypography.bodyMedium.copyWith(
                                        fontWeight: FontWeight.w500,
                                        color: endDate != null
                                            ? null
                                            : AppColors.textLight,
                                      ),
                                    ),
                                  ),
                                  const Icon(
                                    Icons.edit_calendar,
                                    color: AppColors.primary,
                                    size: 18,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (startDate != null && endDate != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                '${endDate!.difference(startDate!).inDays + 1} day(s) selected',
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                        ],
                        AppSpacing.h16,

                        // Leave type chips
                        Text(
                          'Leave Type',
                          style: AppTypography.labelLarge.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        AppSpacing.h8,
                        Row(
                          children: LeaveType.values.map((type) {
                            final selected = type == selectedType;
                            return Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(
                                  right: type != LeaveType.values.last
                                      ? 8.0
                                      : 0.0,
                                ),
                                child: ChoiceChip(
                                  label: Text(_leaveTypeLabel(type)),
                                  selected: selected,
                                  selectedColor: AppColors.primary.withAlpha(
                                    30,
                                  ),
                                  labelStyle: AppTypography.labelMedium
                                      .copyWith(
                                        color: selected
                                            ? AppColors.primary
                                            : AppColors.textSecondary,
                                      ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  side: BorderSide(
                                    color: selected
                                        ? AppColors.primary
                                        : AppColors.borderLight,
                                  ),
                                  onSelected: (_) {
                                    setSheetState(() => selectedType = type);
                                  },
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        AppSpacing.h16,

                        // Reason
                        AppTextField(
                          controller: reasonController,
                          hintText: 'Enter reason for leave',
                          labelText: 'Reason',
                          maxLines: 3,
                          textInputAction: TextInputAction.done,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Please enter a reason';
                            }
                            return null;
                          },
                        ),
                        AppSpacing.h24,

                        AppButton(
                          text: 'Submit',
                          onPressed: () {
                            // Validate dates
                            if (!isMultiple && singleDate == null) {
                              setSheetState(() {
                                dateError = 'Please select a date';
                              });
                              return;
                            }
                            if (isMultiple &&
                                startDate == null &&
                                endDate == null) {
                              setSheetState(() {
                                dateError =
                                    'Please select both start and end dates';
                              });
                              return;
                            }
                            if (isMultiple && startDate == null) {
                              setSheetState(() {
                                dateError = 'Please select a start date';
                              });
                              return;
                            }
                            if (isMultiple && endDate == null) {
                              setSheetState(() {
                                dateError = 'Please select an end date';
                              });
                              return;
                            }
                            if (!formKey.currentState!.validate()) return;

                            final dates = <DateTime>[];
                            if (!isMultiple) {
                              dates.add(singleDate!);
                            } else {
                              var current = startDate!;
                              while (!current.isAfter(endDate!)) {
                                if (!existingLeaves.hasLeaveOnDay(current)) {
                                  dates.add(current);
                                }
                                current = current.add(const Duration(days: 1));
                              }
                            }

                            if (dates.isEmpty) {
                              setSheetState(() {
                                dateError =
                                    'All selected dates already have leaves';
                              });
                              return;
                            }

                            context.read<LeaveCubit>().applyLeave(
                              dates: dates,
                              type: selectedType,
                              reason: reasonController.text.trim(),
                            );
                            Navigator.of(sheetContext).pop();
                            AppSnackBar.show(
                              context,
                              message: dates.length == 1
                                  ? 'Leave applied successfully!'
                                  : '${dates.length} leaves applied successfully!',
                              type: SnackBarType.success,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _leaveTypeLabel(LeaveType type) {
    return switch (type) {
      LeaveType.casual => 'Casual',
      LeaveType.sick => 'Sick',
      LeaveType.annual => 'Annual',
    };
  }
}

// ─── Leave Card ──────────────────────────────────────────────────────────────

class _LeaveCard extends StatelessWidget {
  const _LeaveCard({required this.leave});
  final LeaveModel leave;

  @override
  Widget build(BuildContext context) {
    final (statusColor, statusLabel) = switch (leave.status) {
      LeaveStatus.pending => (AppColors.secondary, 'Pending'),
      LeaveStatus.approved => (AppColors.success, 'Approved'),
      LeaveStatus.rejected => (AppColors.error, 'Rejected'),
    };

    final typeLabel = switch (leave.type) {
      LeaveType.casual => 'Casual',
      LeaveType.sick => 'Sick',
      LeaveType.annual => 'Annual',
    };

    final isPast = leave.date.isBefore(
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
    );

    return Container(
      decoration: BoxDecoration(
        color: isPast ? AppColors.grey50 : AppColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withAlpha(25),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: AppSpacing.p16,
        child: Row(
          children: [
            // Date circle
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: statusColor.withAlpha(25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${leave.date.day}',
                    style: AppTypography.titleSmall.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _monthShort(leave.date.month),
                    style: AppTypography.labelSmall.copyWith(
                      color: statusColor,
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ),
            AppSpacing.w12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(20),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          typeLabel,
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  AppSpacing.h4,
                  Text(
                    leave.reason,
                    style: AppTypography.bodySmall.copyWith(
                      color: isPast
                          ? AppColors.textLight
                          : AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
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
                if (!isPast && leave.status == LeaveStatus.pending)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: GestureDetector(
                      onTap: () =>
                          context.read<LeaveCubit>().cancelLeave(leave.id),
                      child: Text(
                        'Cancel',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.error,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _monthShort(int month) {
    const months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];
    return months[month - 1];
  }
}

// ─── Count Badge ─────────────────────────────────────────────────────────────

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primary.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$count',
        style: AppTypography.labelSmall.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
