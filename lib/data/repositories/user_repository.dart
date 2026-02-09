
import '../datasources/remote/api_source.dart';
import '../models/user_model.dart';

class UserRepository {
  final ApiSource _source = ApiSource();

  Future<List<UserModel>> getUsers() async {
    final data = await _source.getUsers();
    return data.map((e) => UserModel.fromMap(e)).toList();
  }
}

