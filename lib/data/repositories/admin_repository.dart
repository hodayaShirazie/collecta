import '../datasources/remote/admin_api.dart';

class AdminRepository {
  final AdminApi _source = AdminApi();

  Future<Map<String, dynamic>> verifyAdmin() {
    return _source.verifyAdmin();
  }
}
