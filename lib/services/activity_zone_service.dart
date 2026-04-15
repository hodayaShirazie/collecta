import '../data/repositories/activity_zone_repository.dart';
import '../data/models/activity_zone_model.dart';

class ActivityZoneService {
  final ActivityZoneRepository _repo = ActivityZoneRepository();

  Future<String> createActivityZone({
    required String name,
    required String addressId,
    required double range,
    required String organizationId,
  }) async {
    return await _repo.createActivityZone(
      name: name,
      addressId: addressId,
      range: range,
      organizationId: organizationId,
    );
  }

  Future<String> updateActivityZone({
    required String id,
    String? name,
    String? addressId,
    double? range,
  }) async {
    return await _repo.updateActivityZone(
      id: id,
      name: name,
      addressId: addressId,
      range: range,
    );
  }

  Future<List<ActivityZoneModel>> getActivityZones(
      String organizationId) async {
    return await _repo.getActivityZones(organizationId);
  }
}
