import 'package:collecta/data/repositories/address_repository.dart';

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
  
} 

