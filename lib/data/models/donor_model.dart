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
  final DateTime? lastLogin;
  final DateTime createdAt;

  DonorProfile({
    required this.user,
    required this.businessAddressId,
    required this.businessName,
    required this.businessPhone,
    required this.coins,
    required this.contactName,
    required this.contactPhone,
    required this.crn,
    required this.lastLogin,
    required this.createdAt,
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
      lastLogin: json['role']['last_login'] != null
        ? DateTime.parse(json['role']['last_login'])
        : null,
      createdAt: DateTime.parse(json['role']['created_at']),

    );
  }
}
