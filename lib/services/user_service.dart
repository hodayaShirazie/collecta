import '../data/repositories/user_repository.dart';
import '../data/models/user_model.dart';

class UserService {
  final UserRepository _repo = UserRepository();

  Future<List<UserModel>> fetchUsers() {
    return _repo.getUsers();
  }
} 
