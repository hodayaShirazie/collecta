import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../config/api_config.dart';
// import 'auth_headers.dart';
import 'api_source.dart';

class ProductApi extends ApiSource {
    Future<String> createProductType({
        required String name,
        required String description,
    }) async {
        // final headers = await AuthHeaders.build();

        final response = await http.post(
            Uri.parse('${ApiConfig.baseUrl}/createProductType'),
            // headers: headers,
            headers: await headers(),
            body: json.encode({
                'name': name,
                'description': description,
            }),
        );

        final data = json.decode(response.body);

        if (response.statusCode != 200) {
            throw Exception(data['error']);
        }

        return data['productTypeId'];
    }


    Future<String> createProduct({
        required String productTypeId,
        required int quantity,
    }) async {
        // final headers = await AuthHeaders.build();

        final response = await http.post(
            Uri.parse('${ApiConfig.baseUrl}/createProduct'),
            // headers: headers,
            headers: await headers(),
            body: json.encode({
                'productTypeId': productTypeId,
                'quantity': quantity
            }),
        );

        final data = json.decode(response.body);

        if (response.statusCode != 200) {
            throw Exception(data['error']);
        }

        return data['productId'];
    }
}