import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../config/api_config.dart';
import 'api_source.dart';

class ActivityZoneApi extends ApiSource {
  Future<String> createActivityZone({
    required String name,
    required String addressId,
    required double range,
    required String organizationId,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/createActivityZone'),
      headers: await headers(),
      body: json.encode({
        'name': name,
        'addressId': addressId,
        'range': range,
        'organizationId': organizationId,
      }),
    );

    final data = json.decode(response.body);

    if (response.statusCode != 200) {
      throw Exception(data['error']);
    }

    return data['activityZoneId'];
  }

  Future<String> updateActivityZone({
    required String id,
    String? name,
    String? addressId,
    double? range,
  }) async {
    final body = <String, dynamic>{'id': id};
    if (name != null) body['name'] = name;
    if (addressId != null) body['addressId'] = addressId;
    if (range != null) body['range'] = range;

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/updateActivityZone'),
      headers: await headers(),
      body: json.encode(body),
    );

    final data = json.decode(response.body);

    if (response.statusCode != 200) {
      throw Exception(data['error']);
    }

    return data['status'];
  }

  Future<List<Map<String, dynamic>>> getActivityZones(
      String organizationId) async {
    final response = await http.get(
      Uri.parse(
          '${ApiConfig.baseUrl}/getActivityZones?organizationId=$organizationId'),
      headers: await headers(),
    );

    if (response.statusCode != 200) {
      final data = json.decode(response.body);
      throw Exception(data['error']);
    }

    return List<Map<String, dynamic>>.from(json.decode(response.body));
  }
}
