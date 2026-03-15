import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../config/api_config.dart';
// import 'auth_headers.dart';
import 'api_source.dart';

class DonationApi extends ApiSource {
    Future<String> reportDonationRaw(Map<String, dynamic> body) async {
        // final headers = await AuthHeaders.build();

        final response = await http.post(
            Uri.parse('${ApiConfig.baseUrl}/reportDonation'),
            // headers: headers,
            headers: await headers(),
            body: json.encode(body),
        );

        final data = json.decode(response.body);

        if (response.statusCode != 200) {
            throw Exception(data['error']);
        }

        return data['status'];
    }

    Future<List<dynamic>> getMyDonations() async {
        // final headers = await AuthHeaders.build();

        final response = await http.get(
            Uri.parse('${ApiConfig.baseUrl}/getMyDonations'),
            // headers: headers,
            headers: await headers(),
        );

        if (response.statusCode != 200) {
            throw Exception(response.body);
        }

        return json.decode(response.body);
    }


    Future<List<Map<String, dynamic>>> getDonationsByOrganization(String organizationId) async {

        // final headers = await AuthHeaders.build();

        final response = await http.get(
            Uri.parse('${ApiConfig.baseUrl}/getAllDonationsByOrganization?organizationId=$organizationId'),
            // headers: headers,
            headers: await headers(),
        );

        if (response.statusCode != 200) {
            throw Exception(response.body);
        }

        return List<Map<String, dynamic>>.from(
        json.decode(response.body),
        );
    }

    Future<int> getDonationsCount(String organizationId) async {
        // final headers = await AuthHeaders.build();

        final response = await http.get(
            Uri.parse('${ApiConfig.baseUrl}/getDonationsCount?organizationId=$organizationId'),
            // headers: headers,
            headers: await headers(),
        );

        if (response.statusCode != 200) {
            throw Exception(json.decode(response.body)['error'] ?? 'error');
        }

        final data = json.decode(response.body);
        return data['count'];
    }

    Future<int> getDonationsPendingCount(String organizationId) async {
        // final headers = await AuthHeaders.build();

        final response = await http.get(
            Uri.parse('${ApiConfig.baseUrl}/getDonationsPendingCount?organizationId=$organizationId'),
            // headers: headers,
            headers: await headers(),
        );

        if (response.statusCode != 200) {
            throw Exception(json.decode(response.body)['error'] ?? 'error');
        }

        final data = json.decode(response.body);
        return data['count'];
    }

    Future<int> getDonationsCountByMonth({
        required String organizationId,
        required int monthOffset,
    }) async {
        // final headers = await AuthHeaders.build();

        final response = await http.get(
            Uri.parse('${ApiConfig.baseUrl}/getDonationsCountByMonth?organizationId=$organizationId&monthOffset=$monthOffset'),
            // headers: headers,
            headers: await headers(),
        );

        if (response.statusCode != 200) {
            throw Exception(json.decode(response.body)['error'] ?? 'error');
        }

        final data = json.decode(response.body);
        return data['count'];
    }

    Future<int> getDonationsCanceledCount(String organizationId) async {
        // final headers = await AuthHeaders.build();

        final response = await http.get(
            Uri.parse('${ApiConfig.baseUrl}/getDonationsCanceledCount?organizationId=$organizationId',),
            // headers: headers,
            headers: await headers(),
        );

        if (response.statusCode != 200) {
        throw Exception(json.decode(response.body)['error'] ?? 'error');
        }

        final data = json.decode(response.body);
        return data['count'];
    }


    Future<int> getDonationsConfirmedCount(String organizationId) async {
        // final headers = await AuthHeaders.build();

        final res = await http.get(
            Uri.parse("${ApiConfig.baseUrl}/getDonationsConfirmedCount?organizationId=$organizationId"),
            // headers: headers,
            headers: await headers(),
        );

        if (res.statusCode != 200) {
            throw Exception(res.body);
        }

        return jsonDecode(res.body)["count"];
    }

}