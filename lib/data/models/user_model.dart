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


  Map<String, dynamic> toJson() {
    return {
      'uid': id,
      'name': name,
      'mail': mail,
      'img': img,
      'organization_id': organizationId,
      'created_at': createdAt.toIso8601String(),
      'last_login': lastLogin.toIso8601String(),
    };
  }

  /// 🔹 תוספת – מאפשר לעדכן שדות בקלות
  UserModel copyWith({
    String? name,
    String? mail,
    String? img,
    String? organizationId,
    DateTime? lastLogin,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      mail: mail ?? this.mail,
      img: img ?? this.img,
      organizationId: organizationId ?? this.organizationId,
      createdAt: createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }
}
