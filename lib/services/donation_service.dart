import '../data/models/donation_model.dart';
import '../data/repositories/donation_repository.dart';

class DonationService {
  final DonationRepository _repo = DonationRepository();

  // Future<String> reportDonation(DonationModel donation) {
  //   return _repo.reportDonation(donation);
  // }

  Future<String> reportDonationRaw(Map<String, dynamic> body) {
    return _repo.reportDonationRaw(body);
  }

  Future<List<DonationModel>> getMyDonations() {
    return _repo.getMyDonations();
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






}
