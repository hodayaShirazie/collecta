import '../data/repositories/product_repository.dart';

class ProductService {
  final ProductRepository _repo = ProductRepository();

  Future<String> createProduct({
    required String productTypeId,
    required int quantity,
  }) async {
    return await _repo.createProduct(
      productTypeId: productTypeId,
      quantity: quantity,
    );
  }
}
