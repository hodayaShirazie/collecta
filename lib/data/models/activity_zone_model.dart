import 'address_model.dart';

class ActivityZoneModel {
  final String id;
  final String name;
  final String addressId;
  final double range;
  final String organizationId;
  final AddressModel? address;

  ActivityZoneModel({
    required this.id,
    required this.name,
    required this.addressId,
    required this.range,
    required this.organizationId,
    this.address,
  });

  factory ActivityZoneModel.fromApi(Map<String, dynamic> json) {
    return ActivityZoneModel(
      id: json['id'] as String,
      name: json['name'] as String,
      addressId: json['addressId'] as String,
      range: (json['range'] as num).toDouble(),
      organizationId: json['organizationId'] as String,
      address: json['address'] != null
          ? AddressModel.fromApi(json['address'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'addressId': addressId,
      'range': range,
      'organizationId': organizationId,
    };
  }

  ActivityZoneModel copyWith({
    String? id,
    String? name,
    String? addressId,
    double? range,
    String? organizationId,
    AddressModel? address,
  }) {
    return ActivityZoneModel(
      id: id ?? this.id,
      name: name ?? this.name,
      addressId: addressId ?? this.addressId,
      range: range ?? this.range,
      organizationId: organizationId ?? this.organizationId,
      address: address ?? this.address,
    );
  }
}