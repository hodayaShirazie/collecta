class UserModel {
  final String id;
  final String name;
  final String mail;
  final String img;
  final String organizationId;
  final DateTime createdAt;
  final DateTime lastLogin;

  UserModel({
    required this.id,
    required this.name,
    required this.mail,
    required this.img,
    required this.organizationId,
    required this.createdAt,
    required this.lastLogin,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['uid'],
      name: map['name'],
      mail: map['mail'],
      img: map['img'],
      organizationId: map['organization_id'] ?? '',
      createdAt: DateTime.parse(map['created_at']),
      lastLogin: DateTime.parse(map['last_login'])
    );
  }
}
