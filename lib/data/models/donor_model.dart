import 'user_model.dart';
import 'address_model.dart';

class DonorProfile {
  final UserModel user;
  final AddressModel businessAddress;
  final String businessName;
  final String businessPhone;
  final int coins;
  final String contactName;
  final String contactPhone;
  final String crn;

  DonorProfile({
    required this.user,
    required this.businessAddress,
    required this.businessName,
    required this.businessPhone,
    required this.coins,
    required this.contactName,
    required this.contactPhone,
    required this.crn,
  });

  factory DonorProfile.fromApi(Map<String, dynamic> json) {
    final addressJson = json['address'];
    return DonorProfile(
      user: UserModel.fromMap(json['user']),
      businessAddress: addressJson != null
          ? AddressModel.fromApi(addressJson)
          : AddressModel(id: '', lat: 0.0, lng: 0.0, name: ''), // ברירת מחדל
      businessName: json['role']?['businessName'] ?? '',
      businessPhone: json['role']?['businessPhone'] ?? '',
      coins: json['role']?['coins'] ?? 0,
      contactName: json['role']?['contactName'] ?? '',
      contactPhone: json['role']?['contactPhone'] ?? '',
      crn: json['role']?['crn'] ?? '',
    );
  }

   Map<String, dynamic> toJson() {
    return {
      "businessName": businessName,
      "businessPhone": businessPhone,
      "contactName": contactName,
      "contactPhone": contactPhone,
      "crn": crn,
      "businessAddressId": businessAddress.id,
    };
  }

  /// 🔹 תוספת – לעדכון שדות בקלות
  DonorProfile copyWith({
    UserModel? user,
    AddressModel? businessAddress,
    String? businessName,
    String? businessPhone,
    int? coins,
    String? contactName,
    String? contactPhone,
    String? crn,
  }) {
    return DonorProfile(
      user: user ?? this.user,
      businessAddress: businessAddress ?? this.businessAddress,
      businessName: businessName ?? this.businessName,
      businessPhone: businessPhone ?? this.businessPhone,
      coins: coins ?? this.coins,
      contactName: contactName ?? this.contactName,
      contactPhone: contactPhone ?? this.contactPhone,
      crn: crn ?? this.crn,
    );
  }

   List<String> missingFields() {
    final missing = <String>[];

    if (user.name.isEmpty) missing.add("name");
    if (businessName.isEmpty) missing.add("businessName");
    if (businessPhone.isEmpty) missing.add("businessPhone");
    if (businessAddress.name.isEmpty) missing.add("address");
    if (contactName.isEmpty) missing.add("contactName");
    if (contactPhone.isEmpty) missing.add("contactPhone");
    if (crn.isEmpty) missing.add("crn");

    return missing;
  }
}
