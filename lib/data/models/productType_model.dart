class ProductTypeModel {
  final String id;
  final String name;

  ProductTypeModel({
    required this.id,
    required this.name,
  });

  factory ProductTypeModel.fromApi(Map<String, dynamic> json) {
    return ProductTypeModel(
      id: json['id'],
      name: json['name'],
    );
  }
}