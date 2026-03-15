// import '../datasources/remote/api_source.dart';
import '../datasources/remote/address_api.dart';
import '../models/address_model.dart';

class AddressRepository {
  // final ApiSource _source = ApiSource();
  final AddressApi _source = AddressApi();

  
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

    Future<String> updateAddress(AddressModel address) {
    return _source.updateAddress(
      id: address.id,
      name: address.name,
      lat: address.lat,
      lng: address.lng,
    );
  }
}
