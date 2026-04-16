import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../config/api_config.dart';
// import 'auth_headers.dart';
import 'api_source.dart';

class DriverApi extends ApiSource {
    Future<Map<String, dynamic>> getDriverProfile() async {
        // final headers = await AuthHeaders.build();

        final response = await http.get(
            Uri.parse('${ApiConfig.baseUrl}/getDriverProfile'),
            // headers: headers,
            headers: await headers(),
        );

        if (response.statusCode != 200) {
            throw Exception(json.decode(response.body)['error']);
        }

        return Map<String, dynamic>.from(json.decode(response.body));
    }

    Future<String> updateDriverProfile({
        required String phone,
        required List<String> areas,
    }) async {

        // final headers = await AuthHeaders.build();

        final response = await http.put(
            Uri.parse('${ApiConfig.baseUrl}/updateDriverProfile'),
            // headers: headers,
            headers: await headers(),
            body: json.encode({
                if (phone.isNotEmpty) 'phone': phone,
                'areas': areas,
            }),
        );

        final data = json.decode(response.body);

        if (response.statusCode != 200) {
            throw Exception(data['error']);
        }

        return data['status'];
    }

    Future<List<Map<String, dynamic>>> getDriversByOrganization(String organizationId) async {
        // final headers = await AuthHeaders.build();
        final url = '${ApiConfig.baseUrl}/getDriversByOrganization?organizationId=$organizationId';
        final response = await http.get(
            Uri.parse(url),
            // headers: headers,
            headers: await headers(),
        );


        if (response.statusCode != 200) {
            throw Exception(json.decode(response.body)['error'] ?? 'error');
        }

        return List<Map<String, dynamic>>.from(json.decode(response.body),);
    }

}