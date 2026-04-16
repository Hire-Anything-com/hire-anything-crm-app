import 'package:equatable/equatable.dart';

enum LeaveStatus { pending, approved, rejected }

enum LeaveType { casual, sick, annual }

class LeaveModel extends Equatable {
  const LeaveModel({
    required this.id,
    required this.date,
    required this.type,
    required this.reason,
    this.status = LeaveStatus.pending,
  });

  final String id;
  final DateTime date;
  final LeaveType type;
  final String reason;
  final LeaveStatus status;

  LeaveModel copyWith({LeaveStatus? status}) {
    return LeaveModel(
      id: id,
      date: date,
      type: type,
      reason: reason,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [id, date, type, reason, status];
}
