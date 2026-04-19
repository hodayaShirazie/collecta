class PlacePrediction {
  final String description;
  final String placeId;
  final bool isManual;

  PlacePrediction({
    required this.description,
    required this.placeId,
    this.isManual = false,
  });

  factory PlacePrediction.fromJson(Map<String, dynamic> json) {
    return PlacePrediction(
      description: json['description'],
      placeId: json['placeId'],
    );
  }
}
