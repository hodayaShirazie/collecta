// import '../datasources/remote/api_source.dart';
import '../datasources/remote/product_api.dart';

class ProductTypeRepository {
  // final ApiSource _source = ApiSource();
  final ProductApi _source = ProductApi();

  Future<String> createProductType({
    required String name,
    required String description,
  }) async {
    return await _source.createProductType(
      name: name,
      description: description,
    );
  }
}
