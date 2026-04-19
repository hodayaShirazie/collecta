/// Manages admin impersonation of a driver.
/// When active, [AuthHeaders] automatically adds the
/// X-Impersonate-User header to every API request so the
/// backend treats the call as if it came from the driver.
class ImpersonationManager {
  ImpersonationManager._();
  static final ImpersonationManager instance = ImpersonationManager._();

  String? _driverId;
  String? _driverName;

  /// The UID of the driver currently being impersonated, or null.
  String? get impersonatedDriverId => _driverId;

  /// Display name of the impersonated driver (used for the admin banner).
  String? get impersonatedDriverName => _driverName;

  /// True while an admin is viewing as a driver.
  bool get isImpersonating => _driverId != null;

  /// Call this before navigating to the driver interface.
  void start(String driverId, {String? driverName}) {
    _driverId = driverId;
    _driverName = driverName;
  }

  /// Call this when the admin leaves the driver interface.
  void stop() {
    _driverId = null;
    _driverName = null;
  }
}
