import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../config/api_config.dart';
// import 'auth_headers.dart';
import 'api_source.dart';
import '../../models/destination_model.dart';


class DestinationApi extends ApiSource {
    Future<String> createDestination({
        required String driverId,
        required String organizationId,
        required String day,
        required String addressId,
    }) async {
        final response = await http.post(
            Uri.parse('${ApiConfig.baseUrl}/createDestination'),
            headers: await headers(),
            body: jsonEncode({
                'driverId': driverId,
                'organizationId': organizationId,
                'day': day,
                'name': '',
                'addressId': addressId,
            }),
        );

        final data = json.decode(response.body);

        if (response.statusCode != 200) {
            throw Exception(data['error'] ?? 'Failed to create destination');
        }

        return data['id'];
    }

    Future<void> updateDestination(DestinationModel destination) async {
        // final headers = await AuthHeaders.build();

        final response = await http.put(
            Uri.parse('${ApiConfig.baseUrl}/updateDestination/${destination.id}'),
            headers: await headers(),
            body: jsonEncode(destination.toJson()),
        );

        if (response.statusCode != 200) {
            throw Exception("Failed to update destination");
        }

    }
}