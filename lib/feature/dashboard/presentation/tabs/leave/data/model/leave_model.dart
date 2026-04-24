import 'package:equatable/equatable.dart';

enum LeaveStatus { pending, approved, rejected }

enum LeaveType { casual, sick, annual }

LeaveStatus _parseLeaveStatus(String? value) {
  switch (value?.toUpperCase()) {
    case 'APPROVED':
      return LeaveStatus.approved;
    case 'REJECTED':
      return LeaveStatus.rejected;
    case 'PENDING':
    default:
      return LeaveStatus.pending;
  }
}

LeaveType _parseLeaveType(String? value) {
  switch (value?.toUpperCase()) {
    case 'SICK':
      return LeaveType.sick;
    case 'ANNUAL':
      return LeaveType.annual;
    case 'CASUAL':
    default:
      return LeaveType.casual;
  }
}

class LeaveModel extends Equatable {
  const LeaveModel({
    required this.id,
    required this.date,
    required this.type,
    required this.reason,
    this.status = LeaveStatus.pending,
    this.startDate,
    this.endDate,
  });

  factory LeaveModel.fromJson(Map<String, dynamic> json) {
    final startEpoch = json['startDate'] as int?;
    final endEpoch = json['endDate'] as int?;
    final start = startEpoch != null
        ? DateTime.fromMillisecondsSinceEpoch(startEpoch * 1000)
        : DateTime.now();

    return LeaveModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      date: start,
      type: _parseLeaveType(json['type'] as String?),
      reason: (json['reason'] as String?) ?? '',
      status: _parseLeaveStatus(json['status'] as String?),
      startDate: startEpoch,
      endDate: endEpoch,
    );
  }

  final String id;
  final DateTime date;
  final LeaveType type;
  final String reason;
  final LeaveStatus status;
  final int? startDate;
  final int? endDate;

  /// Start as DateTime (falls back to [date]).
  DateTime get startDateTime => startDate != null
      ? DateTime.fromMillisecondsSinceEpoch(startDate! * 1000)
      : date;

  /// End as DateTime (falls back to [date]).
  DateTime get endDateTime => endDate != null
      ? DateTime.fromMillisecondsSinceEpoch(endDate! * 1000)
      : date;

  /// Number of calendar days this leave spans.
  int get days {
    final s = DateTime(
      startDateTime.year,
      startDateTime.month,
      startDateTime.day,
    );
    final e = DateTime(endDateTime.year, endDateTime.month, endDateTime.day);
    return e.difference(s).inDays + 1;
  }

  /// Whether this leave covers [day].
  bool coversDay(DateTime day) {
    final d = DateTime(day.year, day.month, day.day);
    final s = DateTime(
      startDateTime.year,
      startDateTime.month,
      startDateTime.day,
    );
    final e = DateTime(endDateTime.year, endDateTime.month, endDateTime.day);
    return !d.isBefore(s) && !d.isAfter(e);
  }

  /// All calendar dates covered by this leave.
  List<DateTime> get allDates {
    final result = <DateTime>[];
    var current = DateTime(
      startDateTime.year,
      startDateTime.month,
      startDateTime.day,
    );
    final end = DateTime(endDateTime.year, endDateTime.month, endDateTime.day);
    while (!current.isAfter(end)) {
      result.add(current);
      current = current.add(const Duration(days: 1));
    }
    return result;
  }

  LeaveModel copyWith({LeaveStatus? status}) {
    return LeaveModel(
      id: id,
      date: date,
      type: type,
      reason: reason,
      status: status ?? this.status,
      startDate: startDate,
      endDate: endDate,
    );
  }

  @override
  List<Object?> get props => [
    id,
    date,
    type,
    reason,
    status,
    startDate,
    endDate,
  ];
}
