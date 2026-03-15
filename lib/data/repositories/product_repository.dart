// import '../datasources/remote/api_source.dart';
import '../datasources/remote/product_api.dart';

class ProductRepository {
  // final ApiSource _source = ApiSource();
  final ProductApi _source = ProductApi();

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
