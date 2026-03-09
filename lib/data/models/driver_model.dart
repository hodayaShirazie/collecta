import 'user_model.dart';
import 'destination_model.dart';
import 'donation_model.dart';

class DriverProfile {
  final UserModel user;
  final String phone;
  final String area;
  final List<DestinationModel> destinations;
  final List<DonationModel> stops;

  DriverProfile({
    required this.user,
    required this.phone,
    required this.area,
    required this.destinations,
    required this.stops,
  });

  factory DriverProfile.fromApi(Map<String, dynamic> json) {
    final role = json['role'] as Map<String, dynamic>;
    return DriverProfile(
      user: UserModel.fromMap(json['user']),
      phone: role['phone'] ?? '',
      area: role['area'] ?? '',
      destinations: (json['destinations'] as List<dynamic>? ?? [])
          .map((e) => DestinationModel.fromApi(e))
          .toList(),
      stops: (role['stops'] as List<dynamic>? ?? [])
          .map((e) => DonationModel.fromApi(e))
          .toList(),
    );
  }
   Map<String, dynamic> toJson() {
    return {
      "phone": phone,
      "area": area,
    };
  }

  /// 🔹 עדכון שדות
  DriverProfile copyWith({
    UserModel? user,
    String? phone,
    String? area,
    List<DestinationModel>? destinations,
    List<DonationModel>? stops,
  }) {
    return DriverProfile(
      user: user ?? this.user,
      phone: phone ?? this.phone,
      area: area ?? this.area,
      destinations: destinations ?? this.destinations,
      stops: stops ?? this.stops,
    );
  }
}
