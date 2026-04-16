import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../config/api_config.dart';
// import 'auth_headers.dart';
import 'api_source.dart';
import 'package:http_parser/http_parser.dart';
import 'package:dio/dio.dart';
import '../../../services/org_manager.dart';


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
        final orgId = OrgManager.orgId;
        if (orgId == null) throw Exception("Organization ID not found");

        final response = await http.get(
            Uri.parse('${ApiConfig.baseUrl}/getMyDonations?organizationId=$orgId'),
            headers: await headers(),
        );

        if (response.statusCode != 200) {
            throw Exception(response.body);
        }

        return json.decode(response.body);
    }

    Future<Map<String, dynamic>> getDonationById(String donationId) async {
      // final headers = await AuthHeaders.build();

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/getDonationById?donationId=$donationId'),
        // headers: headers,
        headers: await headers(),
      );

      if (response.statusCode != 200) {
        throw Exception(response.body);
      }

      return Map<String, dynamic>.from(json.decode(response.body));
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

    Future<String> updateDonation(Map<String, dynamic> body) async {
        final response = await http.post(
            Uri.parse('${ApiConfig.baseUrl}/updateDonation'),
            headers: await headers(),
            body: json.encode(body),
        );

        final data = json.decode(response.body);

        if (response.statusCode != 200) {
            throw Exception(data['error']);
        }

        return data['status'];
    }


    Future<String> cancelDonation(String donationId) async {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/cancelDonation'),
        headers: await headers(),
        body: json.encode({
          "donationId": donationId,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode != 200) {
        throw Exception(data['error']);
      }

      return data['status'];
    }


    Future<String> uploadDonationReceipt({
        required String donationId,
        required List<int> fileBytes,
        required String fileName,
        }) async {
        final dio = Dio();
        
        final formData = FormData.fromMap({
            "donationId": donationId,
            "file": MultipartFile.fromBytes(
            fileBytes, 
            filename: fileName, 
            contentType: MediaType("application", "pdf")
            ),
        });

        final res = await dio.post(
            '${ApiConfig.baseUrl}/updateDonationReceipt',
            data: formData,
            options: Options(headers: await headers()),
        );

        // התיקון כאן: res.data הוא אובייקט (Map). אנחנו צריכים רק את ה-url מתוכו.
        if (res.data != null && res.data is Map) {
            return res.data['url'] as String; 
        }
        
        throw Exception("Invalid respond from server");
    }

Future<List<dynamic>> getDriverDonationsById() async {
  final response = await http.get(
    Uri.parse('${ApiConfig.baseUrl}/getDriverDonationsById'),
    headers: await headers(),
  );

  if (response.statusCode != 200) {
    throw Exception(response.body);
  }

  return json.decode(response.body);
}


Future<String> submitPickup({
  required String donationId,
  required List<Map<String, dynamic>> products,
}) async {
  final response = await http.post(
    Uri.parse('${ApiConfig.baseUrl}/submitPickup'),
    headers: await headers(),
    body: json.encode({
      "donationId": donationId,
      "products": products,
    }),
  );

  if (response.statusCode != 200) {
    throw Exception(json.decode(response.body)['error'] ?? 'Failed to submit pickup');
  }
  return "success";
}

}