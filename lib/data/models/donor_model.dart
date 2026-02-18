import 'user_model.dart';

class DonorProfile {
  final UserModel user;

  final String businessAddressId;
  final String businessName;
  final String businessPhone;
  final int coins;
  final String contactName;
  final String contactPhone;
  final String crn;

  DonorProfile({
    required this.user,
    required this.businessAddressId,
    required this.businessName,
    required this.businessPhone,
    required this.coins,
    required this.contactName,
    required this.contactPhone,
    required this.crn,
  });

  factory DonorProfile.fromApi(Map<String, dynamic> json) {
    return DonorProfile(
      user: UserModel.fromMap(json['user']),
      businessAddressId: json['role']['businessAddress_id'] ?? '',
      businessName: json['role']['businessName'] ?? '',
      businessPhone: json['role']['businessPhone'] ?? '',
      coins: json['role']['coins'] ?? 0,
      contactName: json['role']['contactName'] ?? '',
      contactPhone: json['role']['contactPhone'] ?? '',
      crn: json['role']['crn'] ?? '',

    );
  }
}
