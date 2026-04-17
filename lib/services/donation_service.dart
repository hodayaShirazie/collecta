import '../data/models/donation_model.dart';
import '../data/repositories/donation_repository.dart';
import '../data/models/donation_list_item_model.dart';
import '../data/models/address_model.dart';
import '../data/models/product_model.dart';


class DonationService {
  final DonationRepository _repo = DonationRepository();

  Future<String> reportDonationRaw(Map<String, dynamic> body) {
    return _repo.reportDonationRaw(body);
  }

  Future<List<DonationListItemModel>> getMyDonations() {
    return _repo.getMyDonations();
  }

  Future<DonationModel> getDonationById(String donationId) async {
    final donation = await _repo.getDonationById(donationId);
    return donation;
  }

  
  Future<List<DonationModel>> getDonationsByOrganization(
    String organizationId) {

    return _repo.getDonationsByOrganization(organizationId);
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

  Future<String> updateDonation(Map<String, dynamic> body) {
    return _repo.updateDonation(body);
  }

  Future<String> cancelDonation(String donationId) {
    return _repo.cancelDonation(donationId);
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

  Future<List<DonationModel>> getDriverDonationsById() {
    return _repo.getDriverDonationsById();
  }


  Future<String> submitPickup({
    required String donationId,
    required String donorId,
    required List<Map<String, dynamic>> products,
  }) {
    return _repo.submitPickup(donationId: donationId, donorId: donorId, products: products);
  }






}
