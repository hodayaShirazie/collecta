import 'package:shared_preferences/shared_preferences.dart';

class OrgManager {
  static const _key = 'orgId';

  static Future<void> saveOrgId(String orgId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, orgId);
  }

  static Future<String?> getOrgId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}