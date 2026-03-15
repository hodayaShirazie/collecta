import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../config/api_config.dart';
// import 'auth_headers.dart';
import 'api_source.dart';


class UserApi extends ApiSource {

    Future<List<Map<String, dynamic>>> getUsers() async {
        // final headers = await AuthHeaders.build();

        final response = await http.get(
            Uri.parse('${ApiConfig.baseUrl}/getUsers'),
        // headers: headers,
            headers: await headers(),
        );

        if (response.statusCode != 200) {
            throw Exception('Failed to fetch users');
        }

        return List<Map<String, dynamic>>.from(json.decode(response.body));
    }

    Future<String> syncUserWithRole({
        required String name,
        required String mail,
        required String img,
        required String role,
        required String organizationId,
    }) async {
        // final headers = await AuthHeaders.build();

        final response = await http.post(
            Uri.parse('${ApiConfig.baseUrl}/syncUserWithRole'),
            // headers: headers,
            headers: await headers(),   
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

    Future<Map<String, dynamic>> getMyProfile(String role) async {
        // final headers = await AuthHeaders.build();

        final response = await http.get(
            Uri.parse('${ApiConfig.baseUrl}/getMyProfile?role=$role'),
            // headers: headers,
            headers: await headers(),
        );

        if (response.statusCode != 200) {
        throw Exception(json.decode(response.body)['error']);
        }

        return Map<String, dynamic>.from(json.decode(response.body));
    }

    Future<String> updateUserProfile({
        required String name,
        // required String img,
    }) async {
        // final headers = await AuthHeaders.build();

        final response = await http.put(
            Uri.parse('${ApiConfig.baseUrl}/updateUserProfile'),
            // headers: headers,
            headers: await headers(),
            body: json.encode({
                'name': name,
                // 'img': img,
            }),
        );

        final data = json.decode(response.body);

        if (response.statusCode != 200) {
            throw Exception(data['error']);
        }

        return data['status'];
    }

}