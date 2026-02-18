import '../data/repositories/user_repository.dart';
import '../data/models/user_model.dart';

class UserService {
  final UserRepository _repo = UserRepository();

  Future<List<UserModel>> fetchUsers() {
    return _repo.getUsers();
  }

  Future<String> syncUserWithRole({
    required String name,
    required String mail,
    required String img,
    required String role,
    required String organizationId,
  }) async {
    return await _repo.syncUserWithRole(
      name: name,
      mail: mail,
      img: img,
      role: role,
      organizationId: organizationId,
    );
  }
  
  Future<Map<String, dynamic>> fetchMyProfile(String role) {
    return _repo.fetchMyProfile(role);
  }

} 

