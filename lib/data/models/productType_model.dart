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
      description: json['description'] as String?,
    );
  }
  Map<String, dynamic> toJson() {
    final map = {
      'id': id,
      'name': name,
    };

    if (description != null) {
      map['description'] = description ?? '';
    }

    return map;
  }
}