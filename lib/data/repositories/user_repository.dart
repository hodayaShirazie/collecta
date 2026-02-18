
import '../datasources/remote/api_source.dart';
import '../models/user_model.dart';

class UserRepository {
  final ApiSource _source = ApiSource();

  Future<List<UserModel>> getUsers() async {
    final data = await _source.getUsers();
    return data.map((e) => UserModel.fromMap(e)).toList();
  }

  Future<String> syncUserWithRole({
    required String name,
    required String mail,
    required String img,
    required String role,
    required String organizationId,
  }) async {
    return await _source.syncUserWithRole(
      name: name,
      mail: mail,
      img: img,
      role: role,
      organizationId: organizationId,
    );
  }

  Future<Map<String, dynamic>> fetchMyProfile(String role) {
    return _source.getMyProfile(role);
  }

}




