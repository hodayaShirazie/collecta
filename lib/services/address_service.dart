import 'package:collecta/data/repositories/address_repository.dart';
import '../data/models/address_model.dart';

class AddressService {
  final AddressRepository _repo = AddressRepository();

  Future<String> createAddress({
    required String name,
    required double lat,
    required double lng,
  }) async {
    return await _repo.createAddress(
      name: name,
      lat: lat,
      lng: lng,
    );
  }
  
  Future<String> updateAddress(AddressModel address) {
    return _repo.updateAddress(address);
  }
} 

