import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../config/api_config.dart';
// import 'auth_headers.dart';
import 'api_source.dart';

class PlacesApi extends ApiSource {
    Future<List<Map<String, dynamic>>> placesAutocomplete(String input) async {
        // final headers = await AuthHeaders.build();

        final response = await http.get(
            Uri.parse('${ApiConfig.baseUrl}/placesAutocomplete?input=$input'),
            // headers: headers,
            headers: await headers(),
        );

        if (response.statusCode != 200) {
            throw Exception('Failed to fetch places');
        }

        return List<Map<String, dynamic>>.from(json.decode(response.body));
    }

    Future<Map<String, dynamic>> placeDetails(String placeId) async {
        // final headers = await AuthHeaders.build();

        final response = await http.get(
            Uri.parse('${ApiConfig.baseUrl}/placeDetails?placeId=$placeId'),
            // headers: headers,
            headers: await headers(),
        );

        if (response.statusCode != 200) {
            throw Exception('Failed to fetch details');
        }

        return json.decode(response.body);
    }
}