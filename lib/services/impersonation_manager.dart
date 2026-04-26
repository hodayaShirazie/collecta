/// Manages admin impersonation of a driver.
/// When active, [AuthHeaders] automatically adds the
/// X-Impersonate-User header to every API request so the
/// backend treats the call as if it came from the driver.
class ImpersonationManager {
  ImpersonationManager._();
  static final ImpersonationManager instance = ImpersonationManager._();

  String? _driverId;
  String? _driverName;
  // Holds the admin's Firebase ID token when impersonating cross-site
  // (admin site → driver site). Null when impersonating within admin app.
  String? _adminToken;

  /// The UID of the driver currently being impersonated, or null.
  String? get impersonatedDriverId => _driverId;

  /// Display name of the impersonated driver (used for the admin banner).
  String? get impersonatedDriverName => _driverName;

  /// True while an admin is viewing as a driver.
  bool get isImpersonating => _driverId != null;

  /// Admin's Firebase ID token, used for cross-site API calls.
  String? get adminToken => _adminToken;

  /// Call this before navigating to the driver interface (within admin app).
  void start(String driverId, {String? driverName}) {
    _driverId = driverId;
    _driverName = driverName;
    _adminToken = null;
  }

  /// Call this when admin opens driver site cross-site.
  /// [adminToken] is the Firebase ID token passed via URL.
  void startWithToken(String driverId, String adminToken,
      {String? driverName}) {
    _driverId = driverId;
    _driverName = driverName;
    _adminToken = adminToken;
  }

  /// Call this when the admin leaves the driver interface.
  void stop() {
    _driverId = null;
    _driverName = null;
    _adminToken = null;
  }
}
