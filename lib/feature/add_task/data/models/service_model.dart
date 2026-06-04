import 'package:hireanythingbooking/feature/add_task/domain/entities/entities.dart';

class ServiceModel {
  final String id;
  final String name;

  ServiceModel({required this.id, required this.name});

  factory ServiceModel.fromJson(Map<String, dynamic> json) =>
      ServiceModel(id: json['id'] as String, name: json['name'] as String);

  ServiceItem toEntity() => ServiceItem(id: id, name: name);
}
