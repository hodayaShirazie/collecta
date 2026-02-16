import '../data/repositories/user_repository.dart';
import '../data/models/user_model.dart';

class UserService {
  final UserRepository _repo = UserRepository();

  Future<List<UserModel>> fetchUsers() {
    return _repo.getUsers();
  }

  //  Future<void> createUser(String name, String mail, String img) {
  //   return _repo.createUser(name, mail, img);
  // }

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
  
} 

