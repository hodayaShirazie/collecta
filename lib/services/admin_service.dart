import '../data/repositories/admin_repository.dart';

class AdminService {
  final AdminRepository _repo = AdminRepository();
  static String? _cachedOrgId;

  static void invalidate() => _cachedOrgId = null;

  Future<String> verifyAndGetOrgId() async {
    if (_cachedOrgId != null) return _cachedOrgId!;
    final data = await _repo.verifyAdmin();
    _cachedOrgId = data['organizationId'] as String;
    return _cachedOrgId!;
  }

  Future<bool> isAdmin() async {
    try {
      await verifyAndGetOrgId();
      return true;
    } catch (_) {
      return false;
    }
  }
}
