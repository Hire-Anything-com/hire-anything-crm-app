import 'package:equatable/equatable.dart';

enum TaskStatus { pending, accepted, rejected, inProgress, completed }

class TaskModel extends Equatable {
  const TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.customerName,
    required this.location,
    required this.scheduledAt,
    required this.durationMinutes,
    this.status = TaskStatus.pending,
    this.photoPath,
  });

  final String id;
  final String title;
  final String description;
  final String customerName;
  final String location;
  final DateTime scheduledAt;
  final int durationMinutes;
  final TaskStatus status;
  final String? photoPath;

  TaskModel copyWith({TaskStatus? status, String? photoPath}) {
    return TaskModel(
      id: id,
      title: title,
      description: description,
      customerName: customerName,
      location: location,
      scheduledAt: scheduledAt,
      durationMinutes: durationMinutes,
      status: status ?? this.status,
      photoPath: photoPath ?? this.photoPath,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    customerName,
    location,
    scheduledAt,
    durationMinutes,
    status,
    photoPath,
  ];
}
