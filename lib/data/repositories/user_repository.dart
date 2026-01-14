import '../datasources/remote/firestore_source.dart';
import '../models/user_model.dart';

class UserRepository {
  final FirestoreSource _source = FirestoreSource();

  Future<List<UserModel>> getUsers() async {
    final data = await _source.getCollection('user');
    return data.map((e) => UserModel.fromMap(e)).toList();
  }
}
