import '../datasources/remote/api_source.dart';
import '../models/driver_model.dart';

class DriverRepository {
  final ApiSource _source = ApiSource();

  Future<List<DriverProfile>> getDriversByOrganization(String organizationId) async {
    final data = await _source.getDriversByOrganization(organizationId);
    return data.map((e) => DriverProfile.fromApi(e)).toList();
  }

  Future<DriverProfile> getDriverProfile() async {
    final data = await _source.getDriverProfile();
    return DriverProfile.fromApi(data);
  }

  Future<String> updateDriverProfile(DriverProfile driver) {

    return _source.updateDriverProfile(
      phone: driver.phone,
      area: driver.area,
    );

  }
}