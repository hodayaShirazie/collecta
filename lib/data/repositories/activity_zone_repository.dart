import '../datasources/remote/activity_zone_api.dart';
import '../models/activity_zone_model.dart';

class ActivityZoneRepository {
  final ActivityZoneApi _source = ActivityZoneApi();

  Future<String> createActivityZone({
    required String name,
    required String addressId,
    required double range,
    required String organizationId,
  }) async {
    return await _source.createActivityZone(
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
    return await _source.updateActivityZone(
      id: id,
      name: name,
      addressId: addressId,
      range: range,
    );
  }

  Future<List<ActivityZoneModel>> getActivityZones(
      String organizationId) async {
    final data = await _source.getActivityZones(organizationId);
    return data.map((e) => ActivityZoneModel.fromApi(e)).toList();
  }
}
