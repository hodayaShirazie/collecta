import '../datasources/remote/api_source.dart';
// import '../models/address_model.dart';

class AddressRepository {
  final ApiSource _source = ApiSource();

  
  Future<String> createAddress({
    required String name,
    required double lat,
    required double lng,
  }) async {
    return await _source.createAddress(
      name: name,
      lat: lat,
      lng: lng,
    );
  }
}
