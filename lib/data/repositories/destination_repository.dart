// import '../datasources/remote/api_source.dart';
import '../datasources/remote/destination_api.dart';
import '../models/destination_model.dart';

class DestinationRepository {

  // final ApiSource _apiSource = ApiSource();
  final DestinationApi _apiSource = DestinationApi();

  Future<String> createDestination({
    required String driverId,
    required String organizationId,
    required String day,
    required String addressId,
  }) {
    return _apiSource.createDestination(
      driverId: driverId,
      organizationId: organizationId,
      day: day,
      addressId: addressId,
    );
  }

  Future<void> updateDestination(DestinationModel destination) {

    return _apiSource.updateDestination(destination);

  }

}