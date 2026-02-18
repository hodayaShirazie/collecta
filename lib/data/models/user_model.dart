class UserModel {
  final String id;
  final String name;
  final String mail;
  final String img;
  final String organizationId;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.mail,
    required this.img,
    required this.organizationId,
    required this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['uid'],
      name: map['name'],
      mail: map['mail'],
      img: map['img'],
      organizationId: map['organization_id'] ?? '',
      // createdAt: map['created_at']?.toDate(),
      createdAt: DateTime.parse(map['created_at']), // ✅ במקום toDate()
    );
  }
}
