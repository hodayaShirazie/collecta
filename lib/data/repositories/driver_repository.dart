// import '../datasources/remote/api_source.dart';
import '../datasources/remote/driver_api.dart';
import '../models/driver_model.dart';

class DriverRepository {
  // final ApiSource _source = ApiSource();
  final DriverApi _source = DriverApi();

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
      areas: driver.areas,
    );

  }

  Future<String> addDriverByAdmin({
    required String name,
    required String email,
    required String phone,
    required String organizationId,
  }) {
    return _source.addDriverByAdmin(
      name: name,
      email: email,
      phone: phone,
      organizationId: organizationId,
    );
  }
}