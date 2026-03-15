import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../config/api_config.dart';
// import 'auth_headers.dart';
import 'api_source.dart';

class AddressApi extends ApiSource {
    Future<String> updateAddress({
        required String id,
        required String name,
        required double lat,
        required double lng,
    }) async {
        // final headers = await AuthHeaders.build();

        final response = await http.put(
            Uri.parse('${ApiConfig.baseUrl}/updateAddress'),
            // headers: headers,
            headers: await headers(),
            body: json.encode({
                'id': id,
                'name': name,
                'lat': lat,
                'lng': lng,
            }),
        );

        final data = json.decode(response.body);

        if (response.statusCode != 200) {
            throw Exception(data['error']);
        }

        return data['status'];
    }

    Future<String> createAddress({
        required String name,
        required double lat,
        required double lng,
    }) async {
        // final headers = await AuthHeaders.build();

        final response = await http.post(
            Uri.parse('${ApiConfig.baseUrl}/createAddress'),
            // headers: headers,
            headers: await headers(),
            body: json.encode({
                'name': name,
                'lat': lat,
                'lng': lng,
            }),
        );

        final data = json.decode(response.body);

        if (response.statusCode != 200) {
            throw Exception(data['error']);
        }

        return data['addressId'];
    }
}