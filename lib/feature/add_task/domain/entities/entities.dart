class ServiceItem {
  final String id;
  final String name;

  const ServiceItem({required this.id, required this.name});

  factory ServiceItem.fromJson(Map<String, dynamic> json) =>
      ServiceItem(id: json['id'] as String, name: json['name'] as String);
}
