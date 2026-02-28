import '../datasources/remote/api_source.dart';
import '../models/place_prediction.dart';
import '../models/lat_lng_model.dart';

class PlacesRepository {
  final ApiSource _api = ApiSource();

  Future<List<PlacePrediction>> autocomplete(String input) async {
    final data = await _api.placesAutocomplete(input);
    return data.map((e) => PlacePrediction.fromJson(e)).toList();
  }

  Future<LatLngModel> getDetails(String placeId) async {
    final data = await _api.placeDetails(placeId);
    return LatLngModel.fromJson(data);
  }
}

