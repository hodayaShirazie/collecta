class OrganizationModel {
  final String id;
  final String name;
  final String logo;

  OrganizationModel({
    required this.id,
    required this.name,
    required this.logo,
  });

  factory OrganizationModel.fromMap(Map<String, dynamic> map) {
    return OrganizationModel(
      id: map['id'],
      name: map['name'],
      logo: map['logo'],
    );
  }
}
