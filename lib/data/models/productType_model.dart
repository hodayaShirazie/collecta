class ProductTypeModel {
  final String id;
  final String name;
  final String? description;

  ProductTypeModel({
    required this.id,
    required this.name,
    this.description,
  });

  factory ProductTypeModel.fromApi(Map<String, dynamic> json) {
    return ProductTypeModel(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
    );
  }
}