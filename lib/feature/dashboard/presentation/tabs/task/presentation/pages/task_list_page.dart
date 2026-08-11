import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hireanythingbooking/core/core.dart';
import 'package:hireanythingbooking/feature/add_task/presentation/cubit/add_task_cubit.dart';
import 'package:hireanythingbooking/feature/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:hireanythingbooking/feature/dashboard/presentation/tabs/leave/data/model/leave_model.dart';
import 'package:hireanythingbooking/feature/dashboard/presentation/tabs/leave/presentation/cubit/leave_cubit.dart';
import 'package:hireanythingbooking/feature/dashboard/presentation/tabs/leave/presentation/cubit/leave_state.dart';
import 'package:hireanythingbooking/feature/dashboard/presentation/tabs/task/data/model/task_model.dart';
import 'package:hireanythingbooking/feature/dashboard/presentation/tabs/task/presentation/cubit/task_cubit.dart';
import 'package:hireanythingbooking/feature/dashboard/presentation/tabs/task/presentation/cubit/task_state.dart';
import 'package:hireanythingbooking/feature/dashboard/presentation/tabs/task/presentation/pages/task_detail_page.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

enum CalendarView { day, threeDays, week, month }

class _CalendarEvent {
  const _CalendarEvent({
    required this.start,
    required this.end,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.source,
    required this.isAllDay,
  });

  final DateTime start;
  final DateTime end;
  final String title;
  final String subtitle;
  final Color color;
  final Object source;
  final bool isAllDay;
  int get durationMinutes => end.difference(start).inMinutes.clamp(30, 1440);
}

class TaskListPage extends StatefulWidget {
  const TaskListPage({super.key});

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  final ScrollController _timelineController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  DateTime _selectedDay = DateUtils.dateOnly(DateTime.now());
  CalendarView _view = CalendarView.day;
  Timer? _clock;
  bool _didAutoScroll = false;
  String _query = '';
  _TaskDateFilter _dateFilter = _TaskDateFilter.all;
  _TaskSort _sort = _TaskSort.date;
  double _sheetExtent = .27;

  @override
  void initState() {
    super.initState();
    context.read<LeaveCubit>().fetchMyLeaves();
    _clock = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted && _containsToday) setState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToNow());
  }

  @override
  void dispose() {
    _clock?.cancel();
    _timelineController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  bool get _containsToday =>
      _visibleDays.any((day) => isSameDay(day, DateTime.now()));

  List<DateTime> get _visibleDays {
    switch (_view) {
      case CalendarView.day:
        return [_selectedDay];
      case CalendarView.threeDays:
        return List.generate(
          3,
          (index) => _selectedDay.add(Duration(days: index)),
        );
      case CalendarView.week:
        final start = _selectedDay.subtract(
          Duration(days: _selectedDay.weekday - 1),
        );
        return List.generate(7, (index) => start.add(Duration(days: index)));
      case CalendarView.month:
        return const [];
    }
  }

  void _scrollToNow({bool animate = false}) {
    if (_didAutoScroll || !_containsToday || !(_view != CalendarView.month))
      return;
    if (!_timelineController.hasClients) return;
    final now = DateTime.now();
    const pixelsPerHour = 64.0;
    final target = ((now.hour + now.minute / 60) * pixelsPerHour - 180).clamp(
      0.0,
      _timelineController.position.maxScrollExtent,
    );
    if (animate) {
      _timelineController.animateTo(
        target,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    } else {
      _timelineController.jumpTo(target);
    }
    _didAutoScroll = true;
  }

  void _changeView(CalendarView value) {
    if (value == _view) return;
    setState(() => _view = value);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToNow());
  }

  void _move(int direction) {
    final date = switch (_view) {
      CalendarView.day => _selectedDay.add(Duration(days: direction)),
      CalendarView.threeDays => _selectedDay.add(Duration(days: direction * 3)),
      CalendarView.week => _selectedDay.add(Duration(days: direction * 7)),
      CalendarView.month => DateTime(
        _selectedDay.year,
        _selectedDay.month + direction,
        1,
      ),
    };
    setState(() {
      _selectedDay = DateUtils.dateOnly(date);
      _didAutoScroll = false;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToNow());
  }

  void _today() {
    setState(() {
      _selectedDay = DateUtils.dateOnly(DateTime.now());
      _didAutoScroll = false;
    });
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _scrollToNow(animate: true),
    );
  }

  List<_CalendarEvent> _eventsFor(
    DateTime day,
    List<TaskModel> tasks,
    List<LeaveModel> leaves,
  ) {
    final theme = Theme.of(context).colorScheme;
    final dayStart = DateUtils.dateOnly(day);
    final dayEnd = dayStart.add(const Duration(days: 1));
    final result = <_CalendarEvent>[];
    for (final task in tasks) {
      final start = task.scheduledAt;
      if (start == null || !isSameDay(start, day)) continue;
      result.add(
        _CalendarEvent(
          start: start,
          end: start.add(
            Duration(
              minutes: task.durationMinutes > 0 ? task.durationMinutes : 60,
            ),
          ),
          title: task.customerName.isEmpty ? 'Task' : task.customerName,
          subtitle: task.serviceNames.isEmpty
              ? 'Task assignment'
              : task.serviceNames,
          color: theme.primaryContainer,
          source: task,
          isAllDay: false,
        ),
      );
    }
    for (final leave in leaves) {
      if (!leave.coversDay(day)) continue;
      final rawStart = leave.startDateTime;
      final rawEnd = leave.endDateTime;
      final allDay =
          rawStart.hour == 0 &&
          rawStart.minute == 0 &&
          rawEnd.hour == 0 &&
          rawEnd.minute == 0;
      result.add(
        _CalendarEvent(
          start: rawStart.isBefore(dayStart) ? dayStart : rawStart,
          end: rawEnd.isAfter(dayEnd) || rawEnd == dayStart ? dayEnd : rawEnd,
          title: 'Leave',
          subtitle: leave.reason.isEmpty ? 'Leave request' : leave.reason,
          color: theme.secondaryContainer,
          source: leave,
          isAllDay: allDay,
        ),
      );
    }
    result.sort((a, b) => a.start.compareTo(b.start));
    return result;
  }

  void _openSlot(DateTime slot) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheet) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                DateFormat('EEE, MMM d • h:mm a').format(slot),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  Navigator.pop(sheet);
                  _addTask(slot);
                },
                child: const Text('Assign Task'),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () {
                  Navigator.pop(sheet);
                  _addLeave(slot);
                },
                child: const Text('Apply Leave'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addTask(DateTime slot) {
    context.read<AddTaskCubit>().dateController.text = DateFormat(
      'dd/MM/yyyy HH:mm',
    ).format(slot);
    context.read<DashboardCubit>().changeTab(2);
  }

  void _addLeave(DateTime slot) {
    context.read<LeaveCubit>().selectDay(DateUtils.dateOnly(slot));
    context.read<DashboardCubit>().changeTab(1);
  }

  void _openEvent(Object event) {
    if (event is TaskModel && event.id != null) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => BlocProvider.value(
            value: context.read<TaskCubit>(),
            child: TaskDetailPage(taskId: event.id!),
          ),
        ),
      );
    } else if (event is LeaveModel) {
      context.read<LeaveCubit>().selectDay(event.startDateTime);
      context.read<DashboardCubit>().changeTab(1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LeaveCubit, LeaveState>(
      builder: (context, leave) => BlocBuilder<TaskCubit, TaskState>(
        builder: (context, task) {
          if (task.isLoading) return const _LoadingView();
          if (task.errorMessage != null)
            return _ErrorView(
              message: task.errorMessage!,
              onRetry: context.read<TaskCubit>().fetchMyAssignments,
            );
          final events = <DateTime, List<_CalendarEvent>>{
            for (final day in _visibleDays)
              DateUtils.dateOnly(day): _eventsFor(
                day,
                task.tasks,
                leave.leaves,
              ),
          };
          final filteredTasks = _filteredTasks(task.tasks);
          return SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    CalendarHeader(
                      selectedDay: _selectedDay,
                      view: _view,
                      onBack: () => _move(-1),
                      onForward: () => _move(1),
                      onToday: _today,
                      onViewChanged: _changeView,
                    ),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 280),
                        switchInCurve: Curves.easeOutCubic,
                        child: _view == CalendarView.month
                            ? MonthView(
                                key: const ValueKey('month'),
                                focusedDay: _selectedDay,
                                tasks: task.tasks,
                                leaves: leave.leaves,
                                onDateTap: (day) {
                                  setState(() {
                                    _selectedDay = DateUtils.dateOnly(day);
                                    _view = CalendarView.day;
                                    _didAutoScroll = false;
                                  });
                                  WidgetsBinding.instance.addPostFrameCallback(
                                    (_) => _scrollToNow(),
                                  );
                                },
                              )
                            : TimelineView(
                                key: ValueKey(_view),
                                days: _visibleDays,
                                events: events,
                                controller: _timelineController,
                                showCurrentTime: _containsToday,
                                onSlotTap: _openSlot,
                                onEventTap: _openEvent,
                                onAddTask: () => _addTask(_selectedDay),
                              ),
                      ),
                    ),
                  ],
                ),
                _AllTasksSheet(
                  tasks: filteredTasks,
                  rangeLabel: _rangeLabel,
                  searchController: _searchController,
                  query: _query,
                  selectedDateFilter: _dateFilter,
                  sort: _sort,
                  onQueryChanged: (value) => setState(() => _query = value),
                  onDateFilterChanged: (value) =>
                      setState(() => _dateFilter = value),
                  onSortChanged: (value) => setState(() => _sort = value),
                  onClear: () {
                    _searchController.clear();
                    setState(() {
                      _query = '';
                      _dateFilter = _TaskDateFilter.all;
                    });
                  },
                  onTaskTap: _openEvent,
                  onTaskLongPress: _showTaskActions,
                  onExtentChanged: (extent) =>
                      setState(() => _sheetExtent = extent),
                ),
                _TaskSpeedDial(
                  onAddTask: () => _addTask(_selectedDay),
                  onLeave: () => _addLeave(_selectedDay),
                  bottomInset: _sheetExtent,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<TaskModel> _filteredTasks(List<TaskModel> tasks) {
    final today = DateUtils.dateOnly(DateTime.now());
    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
    final nextWeek = startOfWeek.add(const Duration(days: 7));
    final monthEnd = DateTime(today.year, today.month + 1);
    final result = tasks.where((task) {
      final date = task.scheduledAt;
      if (date == null) return false;
      final text = '${task.customerName} ${task.serviceNames} ${task.location}'
          .toLowerCase();
      return _matchesDateFilter(
            date,
            task.status,
            today,
            startOfWeek,
            nextWeek,
            monthEnd,
          ) &&
          (_query.isEmpty || text.contains(_query.toLowerCase()));
    }).toList();
    result.sort((a, b) => _compareTasks(a, b));
    return result;
  }

  bool _matchesDateFilter(
    DateTime date,
    TaskStatus? status,
    DateTime today,
    DateTime startOfWeek,
    DateTime nextWeek,
    DateTime monthEnd,
  ) {
    final day = DateUtils.dateOnly(date);
    return switch (_dateFilter) {
      _TaskDateFilter.all => true,
      _TaskDateFilter.today => isSameDay(day, today),
      _TaskDateFilter.tomorrow => isSameDay(
        day,
        today.add(const Duration(days: 1)),
      ),
      _TaskDateFilter.nextThreeDays =>
        !day.isBefore(today) &&
            day.isBefore(today.add(const Duration(days: 3))),
      _TaskDateFilter.thisWeek =>
        !day.isBefore(startOfWeek) && day.isBefore(nextWeek),
      _TaskDateFilter.nextWeek =>
        !day.isBefore(nextWeek) &&
            day.isBefore(nextWeek.add(const Duration(days: 7))),
      _TaskDateFilter.thisMonth =>
        !day.isBefore(today) && day.isBefore(monthEnd),
      _TaskDateFilter.upcoming => day.isAfter(today),
      _TaskDateFilter.overdue =>
        day.isBefore(today) && status != TaskStatus.completed,
      _TaskDateFilter.completed => status == TaskStatus.completed,
    };
  }

  int _compareTasks(TaskModel a, TaskModel b) => switch (_sort) {
    _TaskSort.date => a.scheduledAt!.compareTo(b.scheduledAt!),
    _TaskSort.time => _timeValue(
      a.scheduledAt!,
    ).compareTo(_timeValue(b.scheduledAt!)),
    _TaskSort.recentlyAdded => (b.createdAt ?? '').compareTo(a.createdAt ?? ''),
    _TaskSort.priority => 0,
  };

  int _timeValue(DateTime value) => value.hour * 60 + value.minute;

  String get _rangeLabel => switch (_view) {
    CalendarView.month => DateFormat('MMMM yyyy').format(_selectedDay),
    CalendarView.day => DateFormat('EEEE, MMMM d').format(_selectedDay),
    CalendarView.threeDays =>
      '${DateFormat('MMM d').format(_selectedDay)} – ${DateFormat('MMM d').format(_selectedDay.add(const Duration(days: 2)))}',
    CalendarView.week =>
      '${DateFormat('MMM d').format(_visibleDays.first)} – ${DateFormat('MMM d').format(_visibleDays.last)}',
  };

  void _showTaskActions(TaskModel task) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheet) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.open_in_new_rounded),
              title: const Text('Open task details'),
              onTap: () {
                Navigator.pop(sheet);
                _openEvent(task);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class CalendarHeader extends StatelessWidget {
  const CalendarHeader({
    super.key,
    required this.selectedDay,
    required this.view,
    required this.onBack,
    required this.onForward,
    required this.onToday,
    required this.onViewChanged,
  });
  final DateTime selectedDay;
  final CalendarView view;
  final VoidCallback onBack;
  final VoidCallback onForward;
  final VoidCallback onToday;
  final ValueChanged<CalendarView> onViewChanged;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = switch (view) {
      CalendarView.month => DateFormat('MMMM yyyy').format(selectedDay),
      CalendarView.week =>
        '${DateFormat('MMM d').format(selectedDay.subtract(Duration(days: selectedDay.weekday - 1)))} – ${DateFormat('MMM d').format(selectedDay.add(Duration(days: 7 - selectedDay.weekday)))}',
      CalendarView.threeDays =>
        '${DateFormat('EEE, MMM d').format(selectedDay)} – ${DateFormat('EEE, MMM d').format(selectedDay.add(const Duration(days: 2)))}',
      CalendarView.day => DateFormat('EEE, MMM d').format(selectedDay),
    };
    return Material(
      color: theme.colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
        child: Column(
          children: [
            Row(
              children: [
                IconButton.filledTonal(
                  tooltip: 'Previous',
                  onPressed: onBack,
                  icon: const Icon(Icons.chevron_left_rounded),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -.5,
                      ),
                    ),
                  ),
                ),
                IconButton.filledTonal(
                  tooltip: 'Next',
                  onPressed: onForward,
                  icon: const Icon(Icons.chevron_right_rounded),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ViewSelector(value: view, onChanged: onViewChanged),
            const SizedBox(height: 14),
            TextButton(onPressed: onToday, child: const Text('Today')),
          ],
        ),
      ),
    );
  }
}

class ViewSelector extends StatelessWidget {
  const ViewSelector({super.key, required this.value, required this.onChanged});
  final CalendarView value;
  final ValueChanged<CalendarView> onChanged;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const values = CalendarView.values;
    const labels = ['Day', '3 Days', 'Week', 'Month'];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: .62),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: List.generate(
          values.length,
          (index) => Expanded(
            child: Semantics(
              selected: value == values[index],
              button: true,
              child: InkWell(
                borderRadius: BorderRadius.circular(13),
                onTap: () => onChanged(values[index]),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  height: 38,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: value == values[index]
                        ? theme.colorScheme.surface
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(13),
                    boxShadow: value == values[index]
                        ? const [
                            BoxShadow(color: Color(0x16000000), blurRadius: 4),
                          ]
                        : null,
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      labels[index],
                      maxLines: 1,
                      softWrap: false,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: value == values[index]
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class TimelineView extends StatelessWidget {
  const TimelineView({
    super.key,
    required this.days,
    required this.events,
    required this.controller,
    required this.showCurrentTime,
    required this.onSlotTap,
    required this.onEventTap,
    required this.onAddTask,
  });
  static const _hourHeight = 64.0;
  static const _gutter = 58.0;
  final List<DateTime> days;
  final Map<DateTime, List<_CalendarEvent>> events;
  final ScrollController controller;
  final bool showCurrentTime;
  final ValueChanged<DateTime> onSlotTap;
  final ValueChanged<Object> onEventTap;
  final VoidCallback onAddTask;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final columns = days.length;
      final columnWidth = columns == 1
          ? (constraints.maxWidth - _gutter).clamp(180.0, double.infinity)
          : 116.0;
      final contentWidth = _gutter + columnWidth * columns;
      final hasEvents = events.values.any((list) => list.isNotEmpty);
      return Column(
        children: [
          _DayLabels(
            days: days,
            gutter: _gutter,
            columnWidth: columnWidth,
            contentWidth: contentWidth,
          ),
          _AllDayRow(
            days: days,
            events: events,
            gutter: _gutter,
            columnWidth: columnWidth,
            contentWidth: contentWidth,
            onEventTap: onEventTap,
          ),
          Expanded(
            child: Scrollbar(
              controller: controller,
              child: SingleChildScrollView(
                controller: controller,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: contentWidth,
                    height: 24 * _hourHeight,
                    child: Stack(
                      children: [
                        _HourLines(
                          days: days,
                          gutter: _gutter,
                          columnWidth: columnWidth,
                        ),
                        for (
                          var dayIndex = 0;
                          dayIndex < days.length;
                          dayIndex++
                        )
                          _DayColumn(
                            day: days[dayIndex],
                            left: _gutter + dayIndex * columnWidth,
                            width: columnWidth,
                            events:
                                events[DateUtils.dateOnly(days[dayIndex])] ??
                                const [],
                            onSlotTap: onSlotTap,
                            onEventTap: onEventTap,
                          ),
                        if (showCurrentTime)
                          CurrentTimeIndicator(
                            days: days,
                            gutter: _gutter,
                            columnWidth: columnWidth,
                          ),
                        if (!hasEvents)
                          Positioned(
                            top: 8 * _hourHeight,
                            left: _gutter,
                            right: 0,
                            child: _EmptyState(onAddTask: onAddTask),
                          ),
                      ],
                    ),
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

class _DayLabels extends StatelessWidget {
  const _DayLabels({
    required this.days,
    required this.gutter,
    required this.columnWidth,
    required this.contentWidth,
  });
  final List<DateTime> days;
  final double gutter, columnWidth, contentWidth;
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: SizedBox(
      width: contentWidth,
      child: Row(
        children: [
          SizedBox(width: gutter),
          ...days.map(
            (day) => SizedBox(
              width: columnWidth,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text(
                  DateFormat(
                    days.length == 1 ? 'EEEE, d MMM' : 'EEE d',
                  ).format(day),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: isSameDay(day, DateTime.now())
                        ? FontWeight.w800
                        : FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _AllDayRow extends StatelessWidget {
  const _AllDayRow({
    required this.days,
    required this.events,
    required this.gutter,
    required this.columnWidth,
    required this.contentWidth,
    required this.onEventTap,
  });
  final List<DateTime> days;
  final Map<DateTime, List<_CalendarEvent>> events;
  final double gutter, columnWidth, contentWidth;
  final ValueChanged<Object> onEventTap;
  @override
  Widget build(BuildContext context) {
    final any = events.values
        .expand((value) => value)
        .any((event) => event.isAllDay);
    if (!any) return const SizedBox.shrink();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: contentWidth,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: gutter,
              child: const Padding(
                padding: EdgeInsets.only(top: 6),
                child: Text('All-day', textAlign: TextAlign.center),
              ),
            ),
            ...days.map((day) {
              final allDay = (events[DateUtils.dateOnly(day)] ?? const [])
                  .where((event) => event.isAllDay)
                  .toList();
              return SizedBox(
                width: columnWidth,
                child: Wrap(
                  children: allDay
                      .map(
                        (event) => InkWell(
                          onTap: () => onEventTap(event.source),
                          child: Container(
                            margin: const EdgeInsets.all(2),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: event.color,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              event.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _HourLines extends StatelessWidget {
  const _HourLines({
    required this.days,
    required this.gutter,
    required this.columnWidth,
  });
  final List<DateTime> days;
  final double gutter, columnWidth;
  @override
  Widget build(BuildContext context) => Column(
    children: List.generate(
      24,
      (hour) => SizedBox(
        height: TimelineView._hourHeight,
        child: Row(
          children: [
            SizedBox(
              width: gutter,
              child: Padding(
                padding: const EdgeInsets.only(top: 4, right: 6),
                child: Text(
                  DateFormat('h a').format(DateTime(2020, 1, 1, hour)),
                  textAlign: TextAlign.right,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Theme.of(context).dividerColor),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _DayColumn extends StatelessWidget {
  const _DayColumn({
    required this.day,
    required this.left,
    required this.width,
    required this.events,
    required this.onSlotTap,
    required this.onEventTap,
  });
  final DateTime day;
  final double left, width;
  final List<_CalendarEvent> events;
  final ValueChanged<DateTime> onSlotTap;
  final ValueChanged<Object> onEventTap;
  @override
  Widget build(BuildContext context) {
    final positioned = _positionEvents(
      events.where((event) => !event.isAllDay).toList(),
    );
    return Positioned(
      left: left,
      top: 0,
      width: width,
      height: 24 * TimelineView._hourHeight,
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTapUp: (detail) {
                final minutes =
                    ((detail.localPosition.dy / TimelineView._hourHeight) * 60)
                        .round()
                        .clamp(0, 1439);
                final slot = DateTime(
                  day.year,
                  day.month,
                  day.day,
                ).add(Duration(minutes: (minutes ~/ 30) * 30));
                onSlotTap(slot);
              },
            ),
          ),
          ...positioned.map(
            (item) => Positioned(
              top:
                  (item.event.start.hour * 60 + item.event.start.minute) /
                      60 *
                      TimelineView._hourHeight +
                  2,
              left: item.column * width / item.count + 2,
              width: width / item.count - 4,
              height:
                  (item.event.durationMinutes / 60 * TimelineView._hourHeight -
                          4)
                      .clamp(26, 24 * TimelineView._hourHeight),
              child: TaskCard(
                event: item.event,
                onTap: () => onEventTap(item.event.source),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlacedEvent {
  const _PlacedEvent(this.event, this.column, this.count);
  final _CalendarEvent event;
  final int column, count;
}

List<_PlacedEvent> _positionEvents(List<_CalendarEvent> events) {
  final placed = <_PlacedEvent>[];
  for (final event in events) {
    final overlaps = placed
        .where(
          (item) =>
              item.event.start.isBefore(event.end) &&
              item.event.end.isAfter(event.start),
        )
        .toList();
    var column = 0;
    while (overlaps.any((item) => item.column == column)) {
      column++;
    }
    final count =
        [
          ...overlaps.map((item) => item.column),
          column,
        ].reduce((a, b) => a > b ? a : b) +
        1;
    placed.add(_PlacedEvent(event, column, count));
  }
  return [
    for (final item in placed)
      _PlacedEvent(
        item.event,
        item.column,
        placed
                .where(
                  (other) =>
                      other.event.start.isBefore(item.event.end) &&
                      other.event.end.isAfter(item.event.start),
                )
                .map((other) => other.column)
                .fold(item.column, (a, b) => a > b ? a : b) +
            1,
      ),
  ];
}

class TaskCard extends StatelessWidget {
  const TaskCard({super.key, required this.event, required this.onTap});
  final _CalendarEvent event;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Material(
    color: event.color,
    borderRadius: BorderRadius.circular(8),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final showTime = constraints.maxHeight >= 38;
          final showSubtitle = constraints.maxHeight >= 56;
          return Padding(
            padding: const EdgeInsets.all(6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  event.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (showTime)
                  Text(
                    DateFormat('h:mm a').format(event.start),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                if (showSubtitle)
                  Text(
                    event.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
              ],
            ),
          );
        },
      ),
    ),
  );
}

class CurrentTimeIndicator extends StatelessWidget {
  const CurrentTimeIndicator({
    super.key,
    required this.days,
    required this.gutter,
    required this.columnWidth,
  });
  final List<DateTime> days;
  final double gutter, columnWidth;
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final index = days.indexWhere((day) => isSameDay(day, now));
    if (index < 0) return const SizedBox.shrink();
    final top = (now.hour + now.minute / 60) * TimelineView._hourHeight;
    final color = Theme.of(context).colorScheme.error;
    return Positioned(
      top: top,
      left: gutter + index * columnWidth,
      width: columnWidth,
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          Expanded(child: Container(height: 2, color: color)),
        ],
      ),
    );
  }
}

class MonthView extends StatelessWidget {
  const MonthView({
    super.key,
    required this.focusedDay,
    required this.tasks,
    required this.leaves,
    required this.onDateTap,
  });
  final DateTime focusedDay;
  final List<TaskModel> tasks;
  final List<LeaveModel> leaves;
  final ValueChanged<DateTime> onDateTap;
  @override
  Widget build(BuildContext context) {
    final eventDays = <DateTime, List<Object>>{};
    for (final task in tasks) {
      if (task.scheduledAt != null)
        (eventDays[DateUtils.dateOnly(task.scheduledAt!)] ??= []).add(task);
    }
    for (final leave in leaves) {
      for (final day in leave.allDates) {
        (eventDays[DateUtils.dateOnly(day)] ??= []).add(leave);
      }
    }
    return TableCalendar<Object>(
      firstDay: DateTime(2020),
      lastDay: DateTime(2100),
      focusedDay: focusedDay,
      headerVisible: false,
      startingDayOfWeek: StartingDayOfWeek.monday,
      calendarFormat: CalendarFormat.month,
      eventLoader: (day) => eventDays[DateUtils.dateOnly(day)] ?? const [],
      selectedDayPredicate: (day) => isSameDay(day, focusedDay),
      onDaySelected: (selected, _) => onDateTap(selected),
      calendarStyle: CalendarStyle(
        todayDecoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          shape: BoxShape.circle,
        ),
        selectedDecoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          shape: BoxShape.circle,
        ),
        markerDecoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          shape: BoxShape.circle,
        ),
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: Theme.of(context).textTheme.labelSmall!,
        weekendStyle: Theme.of(context).textTheme.labelSmall!,
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAddTask});
  final VoidCallback onAddTask;
  @override
  Widget build(BuildContext context) => Center(
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.event_available_outlined),
            const SizedBox(height: 8),
            const Text('No tasks scheduled'),
            TextButton(onPressed: onAddTask, child: const Text('Add Task')),
          ],
        ),
      ),
    ),
  );
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          FilledButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    ),
  );
}

enum _TaskDateFilter {
  all,
  today,
  tomorrow,
  nextThreeDays,
  thisWeek,
  nextWeek,
  thisMonth,
  upcoming,
  overdue,
  completed,
}

enum _TaskSort { date, time, recentlyAdded, priority }

class _AllTasksSheet extends StatelessWidget {
  const _AllTasksSheet({
    required this.tasks,
    required this.rangeLabel,
    required this.searchController,
    required this.query,
    required this.selectedDateFilter,
    required this.sort,
    required this.onQueryChanged,
    required this.onDateFilterChanged,
    required this.onSortChanged,
    required this.onClear,
    required this.onTaskTap,
    required this.onTaskLongPress,
    required this.onExtentChanged,
  });

  final List<TaskModel> tasks;
  final String rangeLabel;
  final TextEditingController searchController;
  final String query;
  final _TaskDateFilter selectedDateFilter;
  final _TaskSort sort;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<_TaskDateFilter> onDateFilterChanged;
  final ValueChanged<_TaskSort> onSortChanged;
  final VoidCallback onClear;
  final ValueChanged<TaskModel> onTaskTap;
  final ValueChanged<TaskModel> onTaskLongPress;
  final ValueChanged<double> onExtentChanged;

  @override
  Widget build(
    BuildContext context,
  ) => NotificationListener<DraggableScrollableNotification>(
    onNotification: (notification) {
      onExtentChanged(notification.extent);
      return false;
    },
    child: DraggableScrollableSheet(
      initialChildSize: .27,
      minChildSize: .18,
      maxChildSize: .88,
      snap: true,
      snapSizes: const [.27, .56, .88],
      builder: (context, controller) {
        final theme = Theme.of(context);
        return Material(
          color: theme.colorScheme.surface,
          elevation: 14,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: Column(
            children: [
              Semantics(
                label: 'Drag to expand all tasks',
                child: Container(
                  width: 38,
                  height: 4,
                  margin: const EdgeInsets.only(top: 10, bottom: 10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'All Tasks (${tasks.length})',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Text(
                      rangeLabel,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView(
                  controller: controller,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  children: [
                    TextField(
                      controller: searchController,
                      onChanged: onQueryChanged,
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        hintText: 'Search tasks, customers or services',
                        prefixIcon: const Icon(Icons.search_rounded),
                        suffixIcon: query.isEmpty
                            ? null
                            : IconButton(
                                tooltip: 'Clear search',
                                onPressed: onClear,
                                icon: const Icon(Icons.close_rounded),
                              ),
                        filled: true,
                        fillColor: theme.colorScheme.surfaceContainerHighest
                            .withValues(alpha: .52),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 38,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          ..._TaskDateFilter.values.map(
                            (filter) => _DateFilterChip(
                              label: _dateFilterLabel(filter),
                              selected: selectedDateFilter == filter,
                              onTap: () => onDateFilterChanged(filter),
                            ),
                          ),
                          PopupMenuButton<_TaskSort>(
                            tooltip: 'Sort tasks',
                            onSelected: onSortChanged,
                            itemBuilder: (_) => const [
                              PopupMenuItem(
                                value: _TaskSort.date,
                                child: Text('Date'),
                              ),
                              PopupMenuItem(
                                value: _TaskSort.time,
                                child: Text('Time'),
                              ),
                              PopupMenuItem(
                                value: _TaskSort.recentlyAdded,
                                child: Text('Recently Added'),
                              ),
                              PopupMenuItem(
                                value: _TaskSort.priority,
                                child: Text('Priority'),
                              ),
                            ],
                            child: Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: Chip(
                                avatar: const Icon(
                                  Icons.sort_rounded,
                                  size: 18,
                                ),
                                label: Text(_sortLabel(sort)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (query.isNotEmpty ||
                        selectedDateFilter != _TaskDateFilter.all) ...[
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: onClear,
                          icon: const Icon(Icons.restart_alt_rounded, size: 18),
                          label: Text('Clear filters · $rangeLabel'),
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    if (tasks.isEmpty)
                      const _TasksEmptyState()
                    else
                      ..._groupTasks(tasks).entries.expand(
                        (entry) => [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(4, 12, 4, 7),
                            child: Text(
                              entry.key,
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          ...entry.value.map(
                            (task) => _TaskListCard(
                              task: task,
                              onTap: () => onTaskTap(task),
                              onLongPress: () => onTaskLongPress(task),
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
      },
    ),
  );
}

Map<String, List<TaskModel>> _groupTasks(List<TaskModel> tasks) {
  final groups = <String, List<TaskModel>>{};
  for (final task in tasks) {
    final day = task.scheduledAt!;
    final label = isSameDay(day, DateTime.now())
        ? 'Today'
        : isSameDay(day, DateTime.now().add(const Duration(days: 1)))
        ? 'Tomorrow'
        : DateFormat('EEEE, MMM d').format(day);
    (groups[label] ??= []).add(task);
  }
  return groups;
}

class _DateFilterChip extends StatelessWidget {
  const _DateFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(right: 8),
    child: FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
    ),
  );
}

String _dateFilterLabel(_TaskDateFilter filter) => switch (filter) {
  _TaskDateFilter.all => 'All',
  _TaskDateFilter.today => 'Today',
  _TaskDateFilter.tomorrow => 'Tomorrow',
  _TaskDateFilter.nextThreeDays => 'Next 3 Days',
  _TaskDateFilter.thisWeek => 'This Week',
  _TaskDateFilter.nextWeek => 'Next Week',
  _TaskDateFilter.thisMonth => 'This Month',
  _TaskDateFilter.upcoming => 'Upcoming',
  _TaskDateFilter.overdue => 'Overdue',
  _TaskDateFilter.completed => 'Completed',
};

String _sortLabel(_TaskSort sort) => switch (sort) {
  _TaskSort.date => 'Date',
  _TaskSort.time => 'Time',
  _TaskSort.recentlyAdded => 'Recent',
  _TaskSort.priority => 'Priority',
};

class _TaskListCard extends StatelessWidget {
  const _TaskListCard({
    required this.task,
    required this.onTap,
    required this.onLongPress,
  });
  final TaskModel task;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = task.status;
    final statusColor = status == null
        ? theme.colorScheme.primary
        : _statusColor(status, theme.colorScheme);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: statusColor.withValues(alpha: .28)),
      ),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 4,
                height: 64,
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            task.customerName.isEmpty
                                ? 'Task assignment'
                                : task.customerName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const _PriorityBadge(),
                        if (status != null)
                          _StatusBadge(status: status, color: statusColor),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      task.serviceNames.isEmpty
                          ? 'Service details unavailable'
                          : task.serviceNames,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 15,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('MMM d').format(task.scheduledAt!),
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.schedule_rounded,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            DateFormat('h:mm a').format(task.scheduledAt!),
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (task.location.isNotEmpty)
                          Icon(
                            Icons.location_on_outlined,
                            size: 16,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                      ],
                    ),
                    if ((task.reason ?? '').isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        task.reason!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status, required this.color});
  final TaskStatus status;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(left: 8),
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .12),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      _statusLabel(status),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: color,
        fontWeight: FontWeight.w800,
      ),
    ),
  );
}

class _PriorityBadge extends StatelessWidget {
  const _PriorityBadge();

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(left: 8),
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.primaryContainer,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      'Normal',
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: Theme.of(context).colorScheme.onPrimaryContainer,
        fontWeight: FontWeight.w800,
      ),
    ),
  );
}

String _statusLabel(TaskStatus status) => switch (status) {
  TaskStatus.assigned => 'Assigned',
  TaskStatus.accepted => 'Accepted',
  TaskStatus.inProgress => 'In progress',
  TaskStatus.completed => 'Done',
  TaskStatus.cancelled => 'Cancelled',
};

Color _statusColor(TaskStatus status, ColorScheme colors) => switch (status) {
  TaskStatus.assigned => colors.primary,
  TaskStatus.accepted => colors.tertiary,
  TaskStatus.inProgress => colors.secondary,
  TaskStatus.completed => Colors.green.shade700,
  TaskStatus.cancelled => colors.error,
};

class _TasksEmptyState extends StatelessWidget {
  const _TasksEmptyState();
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 36),
    child: Column(
      children: [
        Icon(
          Icons.event_busy_outlined,
          size: 36,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(height: 10),
        const Text('No tasks match this view'),
        const SizedBox(height: 4),
        Text(
          'Try another date range or clear your filters.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    ),
  );
}

class _TaskSpeedDial extends StatefulWidget {
  const _TaskSpeedDial({
    required this.onAddTask,
    required this.onLeave,
    required this.bottomInset,
  });
  final VoidCallback onAddTask;
  final VoidCallback onLeave;
  final double bottomInset;
  @override
  State<_TaskSpeedDial> createState() => _TaskSpeedDialState();
}

class _TaskSpeedDialState extends State<_TaskSpeedDial> {
  bool _open = false;
  void _select(VoidCallback action) {
    setState(() => _open = false);
    action();
  }

  @override
  Widget build(BuildContext context) => AnimatedPositioned(
    duration: const Duration(milliseconds: 180),
    curve: Curves.easeOutCubic,
    right: 18,
    bottom: MediaQuery.sizeOf(context).height * widget.bottomInset + 16,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_open) ...[
          _SpeedDialAction(
            icon: Icons.beach_access_outlined,
            label: 'Apply leave',
            onTap: () => _select(widget.onLeave),
          ),
          _SpeedDialAction(
            icon: Icons.add_task_rounded,
            label: 'Add task',
            onTap: () => _select(widget.onAddTask),
          ),
        ],
        FloatingActionButton.extended(
          onPressed: () => setState(() => _open = !_open),
          icon: AnimatedRotation(
            turns: _open ? .125 : 0,
            duration: const Duration(milliseconds: 180),
            child: const Icon(Icons.add_rounded),
          ),
          label: Text(_open ? 'Close' : 'Create'),
        ),
      ],
    ),
  );
}

class _SpeedDialAction extends StatelessWidget {
  const _SpeedDialAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: Theme.of(context).colorScheme.surface,
          elevation: 3,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            child: Text(label),
          ),
        ),
        const SizedBox(width: 10),
        FloatingActionButton.small(
          heroTag: label,
          onPressed: onTap,
          child: Icon(icon),
        ),
      ],
    ),
  );
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();
  @override
  Widget build(BuildContext context) =>
      const Center(child: CircularProgressIndicator());
}
