import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../config/api_config.dart';

class ApiSource {
  Future<List<Map<String, dynamic>>> getUsers() async {
    final response =
        await http.get(Uri.parse('${ApiConfig.baseUrl}/getUsers'));

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch users');
    }

    return List<Map<String, dynamic>>.from(
      json.decode(response.body),
    );
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
}
