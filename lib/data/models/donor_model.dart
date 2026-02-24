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
    return DonorProfile(
      user: UserModel.fromMap(json['user']),
      businessAddress: AddressModel.fromApi(json['address']),
      businessName: json['role']['businessName'] ?? '',
      businessPhone: json['role']['businessPhone'] ?? '',
      coins: json['role']['coins'] ?? 0,
      contactName: json['role']['contactName'] ?? '',
      contactPhone: json['role']['contactPhone'] ?? '',
      crn: json['role']['crn'] ?? '',

    );
  }
}
