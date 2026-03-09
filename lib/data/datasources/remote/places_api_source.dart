import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

final String? kGoogleApiKey = dotenv.env['GOOGLE_API_KEY'];

class PlacesApiSource {
  Future<List<PlacePrediction>> autocomplete(String input) async {
    final url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=$kGoogleApiKey&language=he';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final predictions = data['predictions'] as List;
      return predictions.map((p) => PlacePrediction.fromJson(p)).toList();
    } else {
      throw Exception('Failed to fetch autocomplete');
    }
  }

  Future<Map<String, double>> getPlaceDetails(String placeId) async {
    final url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$kGoogleApiKey&language=he';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final location = data['result']['geometry']['location'];
      return {
        'lat': location['lat'],
        'lng': location['lng'],
      };
    } else {
      throw Exception('Failed to fetch place details');
    }
  }
}