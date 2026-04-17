import '../data/repositories/driver_repository.dart';
import '../data/models/driver_model.dart';

class DriverService {
  final DriverRepository _repo = DriverRepository();

  Future<List<DriverProfile>> fetchDriversByOrganization(String organizationId) {
    return _repo.getDriversByOrganization(organizationId);
  }

  Future<DriverProfile> getMyDriverProfile() {
    return _repo.getDriverProfile();
  }

  Future<String> updateDriverProfile(DriverProfile driver) {
    return _repo.updateDriverProfile(driver);
  }

  Future<String> addDriverByAdmin({
    required String name,
    required String email,
    required String phone,
    required String organizationId,
  }) {
    return _repo.addDriverByAdmin(
      name: name,
      email: email,
      phone: phone,
      organizationId: organizationId,
    );
  }
}