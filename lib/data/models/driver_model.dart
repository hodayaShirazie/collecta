import 'user_model.dart';
import 'destination_model.dart';
import 'donation_model.dart';

class DriverProfile {
  final UserModel user;
  final String phone;
  final List<String> areas;
  final List<DestinationModel> destinations;
  final List<DonationModel> stops;

  DriverProfile({
    required this.user,
    required this.phone,
    required this.areas,
    required this.destinations,
    required this.stops,
  });

  factory DriverProfile.fromApi(Map<String, dynamic> json) {
    final role = json['role'] as Map<String, dynamic>;
    return DriverProfile(
      user: UserModel.fromMap(json['user']),
      phone: role['phone'] ?? '',
      areas: (role['areas'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
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
      "areas": areas,
    };
  }

  List<String> missingFields() {
    final missing = <String>[];
    if (user.name.isEmpty) missing.add("name");
    if (phone.isEmpty) missing.add("phone");
    if (areas.isEmpty) missing.add("area");
    return missing;
  }

  DriverProfile copyWith({
    UserModel? user,
    String? phone,
    List<String>? areas,
    List<DestinationModel>? destinations,
    List<DonationModel>? stops,
  }) {
    return DriverProfile(
      user: user ?? this.user,
      phone: phone ?? this.phone,
      areas: areas ?? this.areas,
      destinations: destinations ?? this.destinations,
      stops: stops ?? this.stops,
    );
  }
}
