import '../datasources/remote/api_source.dart';
import '../models/destination_model.dart';

class DestinationRepository {

  final ApiSource _apiSource = ApiSource();

  Future<void> updateDestination(DestinationModel destination) {

    return _apiSource.updateDestination(destination);

  }

}