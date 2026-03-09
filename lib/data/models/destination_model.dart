// import 'address_model.dart';

// class DestinationModel {
//   final String id;
//   final String name;
//   final String organizationId;
//   final String day;
//   final AddressModel address;

//   DestinationModel({
//     required this.id,
//     required this.name,
//     required this.organizationId,
//     required this.day,
//     required this.address,
//   });

//   factory DestinationModel.fromApi(Map<String, dynamic> json) {
//     return DestinationModel(
//       id: json['id'] as String,
//       name: json['name'] as String,
//       organizationId: json['organization_id'] as String,
//       day: json['day'] as String,
//       address: AddressModel.fromApi(json['address']),
//     );
//   }
//     Map<String, dynamic> toJson() {
//     return {
//       'id': id,                     // ID של היעד
//       'name': name,
//       'organization_id': organizationId,
//       'day': day,
//       'address': address.toJson(),  // ממיר את הכתובת גם ל־JSON
//     };
//   }
// }


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
    final addressJson = json['address'];

    return DestinationModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      organizationId: json['organization_id'] ?? '',
      day: json['day'] ?? '',
      address: addressJson != null
          ? AddressModel.fromApi(addressJson)
          : AddressModel(id: '', lat: 0.0, lng: 0.0, name: ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "organization_id": organizationId,
      "day": day,
      "addressId": address.id,
    };
  }

  /// 🔹 עדכון שדות
  DestinationModel copyWith({
    String? id,
    String? name,
    String? organizationId,
    String? day,
    AddressModel? address,
  }) {
    return DestinationModel(
      id: id ?? this.id,
      name: name ?? this.name,
      organizationId: organizationId ?? this.organizationId,
      day: day ?? this.day,
      address: address ?? this.address,
    );
  }
}