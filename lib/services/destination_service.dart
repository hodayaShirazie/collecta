import '../data/models/destination_model.dart';
import '../data/repositories/destination_repository.dart';

class DestinationService {

  final DestinationRepository _repo = DestinationRepository();

  Future<void> updateDestination(DestinationModel destination) {
    return _repo.updateDestination(destination);
  }

}