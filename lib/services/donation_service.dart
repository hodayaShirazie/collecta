import '../data/models/donation_model.dart';
import '../data/repositories/donation_repository.dart';
import '../data/models/donation_list_item_model.dart';

class DonationService {
  final DonationRepository _repo = DonationRepository();

  // Cache: רשימת תרומות אדמין
  static List<DonationModel>? _cachedOrgDonations;
  static DateTime? _orgDonationsCacheTime;
  static const _orgDonationsTTL = Duration(minutes: 2);

  // Cache: תרומות תורם
  static List<DonationListItemModel>? _cachedMyDonations;
  static DateTime? _myDonationsCacheTime;
  static const _myDonationsTTL = Duration(minutes: 2);

  // Cache: תרומות נהג
  static List<DonationModel>? _cachedDriverDonations;
  static DateTime? _driverDonationsCacheTime;
  static const _driverDonationsTTL = Duration(minutes: 2);

  static void _invalidateDonationCaches() {
    _cachedOrgDonations = null;
    _orgDonationsCacheTime = null;
    _cachedMyDonations = null;
    _myDonationsCacheTime = null;
    _cachedDriverDonations = null;
    _driverDonationsCacheTime = null;
  }

  Future<String> reportDonationRaw(Map<String, dynamic> body) async {
    final result = await _repo.reportDonationRaw(body);
    _invalidateDonationCaches();
    return result;
  }

  Future<List<DonationListItemModel>> getMyDonations() async {
    final now = DateTime.now();
    if (_cachedMyDonations != null &&
        _myDonationsCacheTime != null &&
        now.difference(_myDonationsCacheTime!) < _myDonationsTTL) {
      return _cachedMyDonations!;
    }
    final result = await _repo.getMyDonations();
    _cachedMyDonations = result;
    _myDonationsCacheTime = now;
    return result;
  }

  Future<DonationModel> getDonationById(String donationId) async {
    final donation = await _repo.getDonationById(donationId);
    return donation;
  }

  Future<List<DonationModel>> getDonationsByOrganization(
      String organizationId) async {
    final now = DateTime.now();
    if (_cachedOrgDonations != null &&
        _orgDonationsCacheTime != null &&
        now.difference(_orgDonationsCacheTime!) < _orgDonationsTTL) {
      return _cachedOrgDonations!;
    }
    final result = await _repo.getDonationsByOrganization(organizationId);
    _cachedOrgDonations = result;
    _orgDonationsCacheTime = now;
    return result;
  }

  Future<int> getDonationsCountByMonth({
    required String organizationId,
    required int monthOffset,
  }) {
    return _repo.getDonationsCountByMonth(
      organizationId: organizationId,
      monthOffset: monthOffset,
    );
  }

  Future<int> getDonationsPendingCount(String organizationId) {
    return _repo.getDonationsPendingCount(organizationId);
  }

  Future<int> getDonationsCount(String organizationId) {
    return _repo.getDonationsCount(organizationId);
  }

  Future<int> getDonationsCanceledCount(String organizationId) {
    return _repo.getDonationsCanceledCount(organizationId);
  }

  Future<int> getDonationsConfirmedCount(String organizationId) {
    return _repo.getDonationsConfirmedCount(organizationId);
  }

  Future<String> updateDonation(Map<String, dynamic> body) async {
    final result = await _repo.updateDonation(body);
    _invalidateDonationCaches();
    return result;
  }

  Future<String> cancelDonation(String donationId) async {
    final result = await _repo.cancelDonation(donationId);
    _invalidateDonationCaches();
    return result;
  }

  Future<String> uploadDonationReceipt({
    required String donationId,
    required List<int> fileBytes,
    required String fileName,
  }) {
    return _repo.uploadDonationReceipt(
      donationId: donationId,
      fileBytes: fileBytes,
      fileName: fileName,
    );
  }

  Future<List<DonationModel>> getDriverDonationsById() async {
    final now = DateTime.now();
    if (_cachedDriverDonations != null &&
        _driverDonationsCacheTime != null &&
        now.difference(_driverDonationsCacheTime!) < _driverDonationsTTL) {
      return _cachedDriverDonations!;
    }
    final result = await _repo.getDriverDonationsById();
    _cachedDriverDonations = result;
    _driverDonationsCacheTime = now;
    return result;
  }

  Future<String> submitPickup({
    required String donationId,
    required String donorId,
    required List<Map<String, dynamic>> products,
  }) async {
    final result = await _repo.submitPickup(
        donationId: donationId, donorId: donorId, products: products);
    _invalidateDonationCaches();
    return result;
  }
}
