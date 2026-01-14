class UserModel {
  final String id;
  final String name;
  final String mail;
  final String img;

  UserModel({
    required this.id,
    required this.name,
    required this.mail,
    required this.img,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      name: map['name'],
      mail: map['mail'],
      img: map['img'],
    );
  }
}
