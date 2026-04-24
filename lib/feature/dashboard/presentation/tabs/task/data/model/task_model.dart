import 'package:equatable/equatable.dart';
import 'package:hireanythingbooking/core/utils/typedefs.dart';

// ─── Enums ───────────────────────────────────────────────────────────────────

enum TaskStatus { assigned, accepted, inProgress, completed, cancelled }

TaskStatus _parseTaskStatus(String? value) {
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

// ─── Service Model ───────────────────────────────────────────────────────────

class ServiceModel extends Equatable {
  const ServiceModel({this.id, this.serviceId, this.name});

  factory ServiceModel.fromJson(DataMap json) {
    final serviceMap = json['service'] as DataMap?;
    return ServiceModel(
      id: json['id'] as String?,
      serviceId: json['serviceId'] as String?,
      name: serviceMap?['name'] as String?,
    );
  }

  final String? id;
  final String? serviceId;
  final String? name;

  @override
  List<Object?> get props => [id, serviceId, name];
}

// ─── Customer Info Model ─────────────────────────────────────────────────────

class CustomerInfoModel extends Equatable {
  const CustomerInfoModel({this.postCode, this.fullAddress});

  factory CustomerInfoModel.fromJson(DataMap json) {
    return CustomerInfoModel(
      postCode: json['postCode'] as String?,
      fullAddress: json['fullAddress'] as String?,
    );
  }

  final String? postCode;
  final String? fullAddress;

  @override
  List<Object?> get props => [postCode, fullAddress];
}

// ─── Business Model ──────────────────────────────────────────────────────────

class BusinessModel extends Equatable {
  const BusinessModel({this.name});

  factory BusinessModel.fromJson(DataMap json) {
    return BusinessModel(name: json['name'] as String?);
  }

  final String? name;

  @override
  List<Object?> get props => [name];
}

// ─── Inner Task Detail (nested "task" object) ────────────────────────────────

class TaskDetailModel extends Equatable {
  const TaskDetailModel({
    this.id,
    this.businessId,
    this.customerName,
    this.customerPhone,
    this.customerEmail,
    this.customerInfo,
    this.totalPrice,
    this.estimateMinutes,
    this.bookingType,
    this.status,
    this.paymentStatus,
    this.paymentMode,
    this.otp,
    this.photos,
    this.scheduledFor,
    this.startedAt,
    this.completedAt,
    this.createdAt,
    this.updatedAt,
    this.services,
    this.business,
  });

  factory TaskDetailModel.fromJson(DataMap json) {
    return TaskDetailModel(
      id: json['id'] as String?,
      businessId: json['businessId'] as String?,
      customerName: json['customerName'] as String?,
      customerPhone: json['customerPhone'] as String?,
      customerEmail: json['customerEmail'] as String?,
      customerInfo: json['customerInfo'] != null
          ? CustomerInfoModel.fromJson(json['customerInfo'] as DataMap)
          : null,
      totalPrice: json['totalPrice'] as String?,
      estimateMinutes: json['estimateMinutes'] as int?,
      bookingType: json['bookingType'] as String?,
      status: json['status'] as String?,
      paymentStatus: json['paymentStatus'] as String?,
      paymentMode: json['paymentMode'] as String?,
      otp: json['otp'] as String?,
      photos: (json['photos'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      scheduledFor: json['scheduledFor'] as int?,
      startedAt: json['startedAt'] as String?,
      completedAt: json['completedAt'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      services: (json['services'] as List<dynamic>?)
          ?.map((e) => ServiceModel.fromJson(e as DataMap))
          .toList(),
      business: json['business'] != null
          ? BusinessModel.fromJson(json['business'] as DataMap)
          : null,
    );
  }

  final String? id;
  final String? businessId;
  final String? customerName;
  final String? customerPhone;
  final String? customerEmail;
  final CustomerInfoModel? customerInfo;
  final String? totalPrice;
  final int? estimateMinutes;
  final String? bookingType;
  final String? status;
  final String? paymentStatus;
  final String? paymentMode;
  final String? otp;
  final List<String>? photos;
  final int? scheduledFor;
  final String? startedAt;
  final String? completedAt;
  final String? createdAt;
  final String? updatedAt;
  final List<ServiceModel>? services;
  final BusinessModel? business;

  /// Converts scheduledFor (epoch seconds) to DateTime
  DateTime? get scheduledDateTime => scheduledFor != null
      ? DateTime.fromMillisecondsSinceEpoch(scheduledFor! * 1000)
      : null;

  /// Convenience: comma-separated service names
  String get serviceNames =>
      services
          ?.map((s) => s.name ?? '')
          .where((n) => n.isNotEmpty)
          .join(', ') ??
      '';

  /// Full address from customerInfo
  String get fullAddress => customerInfo?.fullAddress ?? '';

  @override
  List<Object?> get props => [
    id,
    businessId,
    customerName,
    customerPhone,
    customerEmail,
    customerInfo,
    totalPrice,
    estimateMinutes,
    bookingType,
    status,
    paymentStatus,
    paymentMode,
    otp,
    photos,
    scheduledFor,
    startedAt,
    completedAt,
    createdAt,
    updatedAt,
    services,
    business,
  ];
}

// ─── Assignment Model (top-level item in response data array) ────────────────

class TaskModel extends Equatable {
  const TaskModel({
    this.id,
    this.taskId,
    this.workerId,
    this.status,
    this.reason,
    this.photos,
    this.completedAt,
    this.createdAt,
    this.updatedAt,
    this.task,
  });

  factory TaskModel.fromJson(DataMap json) {
    return TaskModel(
      id: json['id'] as String?,
      taskId: json['taskId'] as String?,
      workerId: json['workerId'] as String?,
      status: _parseTaskStatus(json['status'] as String?),
      reason: json['reason'] as String?,
      photos: (json['photos'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      completedAt: json['completedAt'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      task: json['task'] != null
          ? TaskDetailModel.fromJson(json['task'] as DataMap)
          : null,
    );
  }

  final String? id;
  final String? taskId;
  final String? workerId;
  final TaskStatus? status;
  final String? reason;
  final List<String>? photos;
  final String? completedAt;
  final String? createdAt;
  final String? updatedAt;
  final TaskDetailModel? task;

  // ─── Convenience getters for UI ────────────────────────────────────────────

  String get customerName => task?.customerName ?? '';
  String get customerPhone => task?.customerPhone ?? '';
  String get customerEmail => task?.customerEmail ?? '';
  String get location => task?.fullAddress ?? '';
  String get businessName => task?.business?.name ?? '';
  String get serviceNames => task?.serviceNames ?? '';
  String get totalPrice => task?.totalPrice ?? '';
  String get bookingType => task?.bookingType ?? '';
  String get paymentStatus => task?.paymentStatus ?? '';
  int get durationMinutes => task?.estimateMinutes ?? 0;
  DateTime? get scheduledAt => task?.scheduledDateTime;

  TaskModel copyWith({TaskStatus? status, String? photoPath}) {
    return TaskModel(
      id: id,
      taskId: taskId,
      workerId: workerId,
      status: status ?? this.status,
      reason: reason,
      photos: photoPath != null ? [...(photos ?? []), photoPath] : photos,
      completedAt: completedAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
      task: task,
    );
  }

  @override
  List<Object?> get props => [
    id,
    taskId,
    workerId,
    status,
    reason,
    photos,
    completedAt,
    createdAt,
    updatedAt,
    task,
  ];
}
