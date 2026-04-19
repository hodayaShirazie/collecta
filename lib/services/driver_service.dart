import '../data/repositories/driver_repository.dart';
import '../data/models/driver_model.dart';

class DriverService {
  final DriverRepository _repo = DriverRepository();

  // Cache: פרופיל נהג
  static DriverProfile? _cachedProfile;
  static DateTime? _profileCacheTime;
  static const _profileTTL = Duration(minutes: 5);

  static void invalidateProfileCache() {
    _cachedProfile = null;
    _profileCacheTime = null;
  }

  Future<List<DriverProfile>> fetchDriversByOrganization(String organizationId) {
    return _repo.getDriversByOrganization(organizationId);
  }

  Future<DriverProfile> getMyDriverProfile() async {
    final now = DateTime.now();
    if (_cachedProfile != null &&
        _profileCacheTime != null &&
        now.difference(_profileCacheTime!) < _profileTTL) {
      return _cachedProfile!;
    }
    final result = await _repo.getDriverProfile();
    _cachedProfile = result;
    _profileCacheTime = now;
    return result;
  }

  Future<String> updateDriverProfile(DriverProfile driver) async {
    final result = await _repo.updateDriverProfile(driver);
    invalidateProfileCache();
    return result;
  }

  /// Creates the driver account. The backend automatically creates 5 empty
  /// destinations (one per weekday: ראשון–חמישי) linked to the new driver.
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
