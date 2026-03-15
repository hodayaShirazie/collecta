import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../config/api_config.dart';
// import 'auth_headers.dart';
import 'api_source.dart';
import '../../models/destination_model.dart';


class DestinationApi extends ApiSource {
    Future<void> updateDestination(DestinationModel destination) async {
        // final headers = await AuthHeaders.build();

        final response = await http.put(
            Uri.parse('${ApiConfig.baseUrl}/updateDestination/${destination.id}'),
            headers: await headers(),
            body: jsonEncode(destination.toJson()),
        );

        if (response.statusCode != 200) {
            throw Exception("Failed to update destination");
        }

    }
}