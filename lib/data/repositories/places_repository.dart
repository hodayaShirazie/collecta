// import '../datasources/remote/api_source.dart';
import '../datasources/remote/places_api.dart';
import '../models/place_prediction.dart';
import '../models/lat_lng_model.dart';

class PlacesRepository {
  // final ApiSource _api = ApiSource();
  final PlacesApi _api = PlacesApi();

  Future<List<PlacePrediction>> autocomplete(String input) async {
    final data = await _api.placesAutocomplete(input);
    return data.map((e) => PlacePrediction.fromJson(e)).toList();
  }

  Future<LatLngModel> getDetails(String placeId) async {
    final data = await _api.placeDetails(placeId);
    return LatLngModel.fromJson(data);
  }
}

