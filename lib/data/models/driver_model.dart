import 'user_model.dart';


class DriverProfile {

  final UserModel user;
  final String phone;
  final String area;
  final List<DestinationModel> destinations;
  final List<String> stops;

  DriverProfile({
    required this.user,
    required this.phone,
    required this.area,
    required this.destination,
    required this.stops,
  });

  factory DriverProfile.fromApi(Map<String, dynamic> json) {
      final role = json['role'] as Map<String, dynamic>;
    return DriverProfile(
      user: UserModel.fromMap(json['user']),
      phone: role['phone'] ?? '',
      area: role['area'] ?? '',
      // destination: role['destination'] ?? [],
      // stops: role['stops'] ?? [],
      destinations: (json['destinations'] as List<dynamic>? ?? [])
          .map((e) => DestinationModel.fromApi(e))
          .toList(),
      stops: role['stops'] != null
          ? List<String>.from(role['stops'])
          : <String>[],
    );
  }
}
