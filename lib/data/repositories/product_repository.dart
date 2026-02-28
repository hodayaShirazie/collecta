import '../datasources/remote/api_source.dart';

class ProductRepository {
  final ApiSource _source = ApiSource();

  Future<String> createProduct({
    required String productTypeId,
    required int quantity,
  }) async {
    return await _source.createProduct(
      productTypeId: productTypeId,
      quantity: quantity,
    );
  }
}
