import '../data/repositories/places_repository.dart';
import '../data/models/place_prediction.dart';
import '../data/models/lat_lng_model.dart';

class PlacesService {
  final _repo = PlacesRepository();

  Future<List<PlacePrediction>> autocomplete(String input) {
    return _repo.autocomplete(input);
  }

  Future<LatLngModel> getPlaceDetails(String placeId) {
    return _repo.getDetails(placeId);
  }
}

