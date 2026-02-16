import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../config/api_config.dart';
import 'auth_headers.dart';

class ApiSource {
  Future<List<Map<String, dynamic>>> getUsers() async {
    final headers = await AuthHeaders.build();

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/getUsers'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch users');
    }

    return List<Map<String, dynamic>>.from(json.decode(response.body));
  }

  Future<List<Map<String, dynamic>>> getOrganizations() async {
    final response =
        await http.get(Uri.parse('${ApiConfig.baseUrl}/getOrganizations'));

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch organizations');
    }

    return List<Map<String, dynamic>>.from(
      json.decode(response.body),
    );
  }


  // Future<List<Map<String, dynamic>>> getOrganizations() async {
  //   final headers = await AuthHeaders.build();

  //   final response = await http.get(
  //     Uri.parse('${ApiConfig.baseUrl}/getOrganizations'),
  //     headers: headers,
  //   );

  //   if (response.statusCode != 200) {
  //     throw Exception('Failed to fetch organizations');
  //   }

  //   return List<Map<String, dynamic>>.from(json.decode(response.body));
  // }


  Future<String> syncUserWithRole({
    required String name,
    required String mail,
    required String img,
    required String role,
    required String organizationId,
  }) async {
    final headers = await AuthHeaders.build();

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/syncUserWithRole'),
      headers: headers,
      body: json.encode({
        'name': name,
        'mail': mail,
        'img': img,
        'role': role,
        'organizationId': organizationId,
      }),
    );

    final data = json.decode(response.body);

    if (response.statusCode != 200) {
      throw Exception(data['error']);
    }

    return data['status'];
  }
}
