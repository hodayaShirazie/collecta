class DestinationModel {
  final String id;
  final String name;
  final String organizationId;
  final String day;
  final String addressId;

  DestinationModel({
    required this.id,
    required this.name,
    required this.organizationId,
    required this.day,
    required this.addressId,
  });

  factory DestinationModel.fromApi(Map<String, dynamic> json) {
    return DestinationModel(
      id: json['id'] as String,
      name: json['name'] as String,
      organizationId: json['organization_id'] as String,
      day: json['day'] as String,
      addressId: json['address_id'] as String,
    );
  }
}
