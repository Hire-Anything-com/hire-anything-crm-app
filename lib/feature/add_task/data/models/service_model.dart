import 'package:hireanythingbooking/feature/add_task/domain/entities/entities.dart';

class ServiceModel {
  ServiceModel({required this.id, required this.name});
  factory ServiceModel.fromJson(Map<String, dynamic> json) =>
      ServiceModel(id: json['id'] as String, name: json['name'] as String);

  final String id;
  final String name;

  ServiceItem toEntity() => ServiceItem(id: id, name: name);
}
