import 'package:shared_preferences/shared_preferences.dart';

class OrgManager {
  static const _key = 'orgId';

  static String? _cachedOrgId;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();

    _cachedOrgId = prefs.getString(_key);

    final webOrgId = Uri.base.queryParameters['orgId'];
    if (webOrgId != null && webOrgId.isNotEmpty) {
      _cachedOrgId = webOrgId;
      await prefs.setString(_key, webOrgId);
    }
  }

  static String? get orgId => _cachedOrgId;

  static Future<void> saveOrgId(String orgId) async {
    _cachedOrgId = orgId;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, orgId);
  }

  static Future<String?> getOrgId() async {
    if (_cachedOrgId != null) return _cachedOrgId;

    final prefs = await SharedPreferences.getInstance();
    _cachedOrgId = prefs.getString(_key);
    return _cachedOrgId;
  }

  static Future<void> clear() async {
    _cachedOrgId = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}