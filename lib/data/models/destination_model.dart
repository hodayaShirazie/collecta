import 'address_model.dart';

class DestinationModel {
  final String id;
  final String name;
  final String organizationId;
  final String day;
  final AddressModel address;

  DestinationModel({
    required this.id,
    required this.name,
    required this.organizationId,
    required this.day,
    required this.address,
  });

  factory DestinationModel.fromApi(Map<String, dynamic> json) {
    return DestinationModel(
      id: json['id'] as String,
      name: json['name'] as String,
      organizationId: json['organization_id'] as String,
      day: json['day'] as String,
      address: AddressModel.fromApi(json['address']),
    );
  }
}

