
class OrganizationModel {
  final String id;
  final String name;
  final String logo;
  final String departmentLogo;
  final String backgroundImg;
  final List<String> activityZoneIds;

  OrganizationModel({
    required this.id,
    required this.name,
    required this.logo,
    required this.departmentLogo,
    required this.backgroundImg,
    this.activityZoneIds = const [],
  });

  factory OrganizationModel.fromMap(Map<String, dynamic> map) {
    return OrganizationModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      logo: map['logo'] ?? '',
      departmentLogo: map['department_logo'] ?? '',
      backgroundImg: map['background_img'] ?? '',
      activityZoneIds: List<String>.from(map['activityZoneIds'] ?? []),
    );
  }
}

