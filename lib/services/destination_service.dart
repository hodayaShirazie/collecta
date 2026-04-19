import '../data/models/destination_model.dart';
import '../data/repositories/destination_repository.dart';

class DestinationService {

  final DestinationRepository _repo = DestinationRepository();

  Future<String> createDestination({
    required String driverId,
    required String organizationId,
    required String day,
    required String addressId,
  }) {
    return _repo.createDestination(
      driverId: driverId,
      organizationId: organizationId,
      day: day,
      addressId: addressId,
    );
  }

  Future<void> updateDestination(DestinationModel destination) {
    return _repo.updateDestination(destination);
  }

}