class LatLngModel {
  final double lat;
  final double lng;

  LatLngModel({required this.lat, required this.lng});

  factory LatLngModel.fromJson(Map<String, dynamic> json) {
    return LatLngModel(
      lat: json['lat'],
      lng: json['lng'],
    );
  }
}
