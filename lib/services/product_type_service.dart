import '../data/repositories/product_type_repository.dart';

class ProductTypeService {
  final ProductTypeRepository _repo = ProductTypeRepository();

  Future<String> createProductType({
    required String name,
    required String description,
  }) async {
    return await _repo.createProductType(
      name: name,
      description: description,
    );
  }
}
