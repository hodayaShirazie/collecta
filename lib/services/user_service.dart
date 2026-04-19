import '../data/repositories/user_repository.dart';
import '../data/models/user_model.dart';

class UserService {
  final UserRepository _repo = UserRepository();

  // Cache: פרופיל משתמש
  static Map<String, dynamic>? _cachedProfile;
  static String? _cachedProfileRole;
  static DateTime? _profileCacheTime;
  static const _profileTTL = Duration(minutes: 5);

  static void invalidateProfileCache() {
    _cachedProfile = null;
    _cachedProfileRole = null;
    _profileCacheTime = null;
  }

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

  Future<Map<String, dynamic>> fetchMyProfile(String role) async {
    final now = DateTime.now();
    if (_cachedProfile != null &&
        _cachedProfileRole == role &&
        _profileCacheTime != null &&
        now.difference(_profileCacheTime!) < _profileTTL) {
      return _cachedProfile!;
    }
    final result = await _repo.fetchMyProfile(role);
    _cachedProfile = result;
    _cachedProfileRole = role;
    _profileCacheTime = now;
    return result;
  }

  Future<String> updateUserProfile({
    required String name,
  }) async {
    final result = await _repo.updateUserProfile(name: name);
    invalidateProfileCache();
    return result;
  }
}
