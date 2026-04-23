import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../config/api_config.dart';
import 'api_source.dart';

class AdminApi extends ApiSource {
  Future<Map<String, dynamic>> verifyAdmin() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/verifyAdmin'),
      headers: await headers(),
    );
    final data = json.decode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200) {
      throw Exception(data['error']);
    }
    return data;
  }
}
