import 'package:equatable/equatable.dart';
import 'package:hireanythingbooking/core/utils/typedefs.dart';

int? _parseInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

class AssignmentServiceModel extends Equatable {
  const AssignmentServiceModel({this.id, this.name});

  factory AssignmentServiceModel.fromJson(DataMap json) {
    return AssignmentServiceModel(
      id: json['id'] as String?,
      name: json['name'] as String?,
    );
  }

  final String? id;
  final String? name;

  @override
  List<Object?> get props => [id, name];
}

class AssignmentCustomerInfoModel extends Equatable {
  const AssignmentCustomerInfoModel({this.postCode, this.fullAddress});

  factory AssignmentCustomerInfoModel.fromJson(DataMap json) {
    return AssignmentCustomerInfoModel(
      postCode: json['postCode'] as String?,
      fullAddress: json['fullAddress'] as String?,
    );
  }

  final String? postCode;
  final String? fullAddress;

  @override
  List<Object?> get props => [postCode, fullAddress];
}

class AssignmentBusinessModel extends Equatable {
  const AssignmentBusinessModel({this.id, this.name, this.phone, this.address});

  factory AssignmentBusinessModel.fromJson(DataMap json) {
    return AssignmentBusinessModel(
      id: json['id'] as String?,
      name: json['name'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
    );
  }

  final String? id;
  final String? name;
  final String? phone;
  final String? address;

  @override
  List<Object?> get props => [id, name, phone, address];
}

class AssignmentTaskInfoModel extends Equatable {
  const AssignmentTaskInfoModel({
    this.businessId,
    this.customerName,
    this.customerPhone,
    this.customerEmail,
    this.customerInfo,
    this.estimateMinutes,
    this.requireOtp = false,
    this.requirePhotos = false,
    this.photos,
    this.scheduledFor,
    this.services,
    this.business,
  });

  factory AssignmentTaskInfoModel.fromJson(DataMap json) {
    return AssignmentTaskInfoModel(
      businessId: json['businessId'] as String?,
      customerName: json['customerName'] as String?,
      customerPhone: json['customerPhone'] as String?,
      customerEmail: json['customerEmail'] as String?,
      customerInfo: json['customerInfo'] != null
          ? AssignmentCustomerInfoModel.fromJson(
              json['customerInfo'] as DataMap,
            )
          : null,
      estimateMinutes: _parseInt(json['estimateMinutes']),
      requireOtp: json['requireOtp'] as bool? ?? false,
      requirePhotos: json['requirePhotos'] as bool? ?? false,
      photos: (json['photos'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      scheduledFor: _parseInt(json['scheduledFor']),
      services: (json['services'] as List<dynamic>?)
          ?.map((e) => AssignmentServiceModel.fromJson(e as DataMap))
          .toList(),
      business: json['business'] != null
          ? AssignmentBusinessModel.fromJson(json['business'] as DataMap)
          : null,
    );
  }

  final String? businessId;
  final String? customerName;
  final String? customerPhone;
  final String? customerEmail;
  final AssignmentCustomerInfoModel? customerInfo;
  final int? estimateMinutes;
  final bool requireOtp;
  final bool requirePhotos;
  final List<String>? photos;
  final int? scheduledFor;
  final List<AssignmentServiceModel>? services;
  final AssignmentBusinessModel? business;

  DateTime? get scheduledDateTime => scheduledFor != null
      ? DateTime.fromMillisecondsSinceEpoch(scheduledFor! * 1000)
      : null;

  String get serviceNames =>
      services
          ?.map((s) => s.name ?? '')
          .where((n) => n.isNotEmpty)
          .join(', ') ??
      '';

  @override
  List<Object?> get props => [
    businessId,
    customerName,
    customerPhone,
    customerEmail,
    customerInfo,
    estimateMinutes,
    requireOtp,
    requirePhotos,
    photos,
    scheduledFor,
    services,
    business,
  ];
}

class AssignmentDetailModel extends Equatable {
  const AssignmentDetailModel({
    this.id,
    this.taskId,
    this.workerId,
    this.status,
    this.task,
  });

  factory AssignmentDetailModel.fromJson(DataMap json) {
    return AssignmentDetailModel(
      id: json['id'] as String?,
      taskId: json['taskId'] as String?,
      workerId: json['workerId'] as String?,
      status: json['status'] as String?,
      task: json['task'] != null
          ? AssignmentTaskInfoModel.fromJson(json['task'] as DataMap)
          : null,
    );
  }

  final String? id;
  final String? taskId;
  final String? workerId;
  final String? status;
  final AssignmentTaskInfoModel? task;

  @override
  List<Object?> get props => [id, taskId, workerId, status, task];
}
