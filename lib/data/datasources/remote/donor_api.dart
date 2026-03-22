import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../config/api_config.dart';
// import 'auth_headers.dart';
import 'api_source.dart';

class DonorApi extends ApiSource {
    Future<Map<String, dynamic>> getDonorProfile() async {
        // final headers = await AuthHeaders.build();

        final response = await http.get(
            Uri.parse('${ApiConfig.baseUrl}/getDonorProfile'),
            // headers: headers,
            headers: await headers(),
        );

        if (response.statusCode != 200) {
            throw Exception(json.decode(response.body)['error']);
        }

        return Map<String, dynamic>.from(json.decode(response.body));
    }

    Future<String> updateDonorProfile({
        required String businessName,
        required String businessPhone,
        required String businessAddress,
        required String contactName,
        required String contactPhone,
        required String crn,
    }) async {
        // final headers = await AuthHeaders.build();

        final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/updateDonorProfile'),
            // headers: headers,
            headers: await headers(),
            body: json.encode({
                'businessName': businessName,
                'businessPhone': businessPhone,
                'businessAddress': businessAddress,
                'contactName': contactName,
                'contactPhone': contactPhone,
                'crn': crn,
            }),
        );

        final data = json.decode(response.body);

        if (response.statusCode != 200) {
            throw Exception(data['error']);
        }

        return data['status'];
    }
}