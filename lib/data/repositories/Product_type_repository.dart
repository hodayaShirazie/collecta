import '../datasources/remote/api_source.dart';

class ProductTypeRepository {
  final ApiSource _source = ApiSource();

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
