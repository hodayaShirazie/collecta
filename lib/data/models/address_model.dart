
class AddressModel {
  final String id;
  final double lat;
  final double lng;
  final String name;

  AddressModel({
    required this.id,
    required this.lat,
    required this.lng,
    required this.name,
  });

  factory AddressModel.fromApi(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'] as String,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      name: json['name'] as String,
    );
  }
}
