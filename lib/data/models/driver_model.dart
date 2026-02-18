import 'user_model.dart';


class DriverProfile {

  final UserModel user;
  final String phone;
  final String area;
  final List<dynamic> destination;
  final List<dynamic> stops;
  final DateTime createdAt;

  DriverProfile({
    required this.user,
    required this.phone,
    required this.area,
    required this.destination,
    required this.stops,
    required this.createdAt,
  });

  factory DriverProfile.fromApi(Map<String, dynamic> json) {
    return DriverProfile(
      user: UserModel.fromMap(json['user']),
      phone: json['role']['phone'] ?? '',
      area: json['role']['area'] ?? '',
      destination: json['role']['destination'] ?? [],
      stops: json['role']['stops'] ?? [],
      createdAt: DateTime.parse(json['role']['created_at']),

    );
  }
}
