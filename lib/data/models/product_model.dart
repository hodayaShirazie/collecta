import 'productType_model.dart';

class ProductModel {
  final String id;
  final int quantity;
  final ProductTypeModel type;

  ProductModel({
    required this.id,
    required this.quantity,
    required this.type,
  });

  factory ProductModel.fromApi(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      quantity: json['quantity'],
      type: ProductTypeModel.fromApi(json['type']),
    );
  }
    Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quantity': quantity,
      'type': type.toJson(),  // גם סוג המוצר מומר ל־JSON
    };
  }
}