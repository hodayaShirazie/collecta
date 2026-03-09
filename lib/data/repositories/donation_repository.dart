import '../datasources/remote/api_source.dart';
import '../models/donation_model.dart';

class DonationRepository {
  final ApiSource _source = ApiSource();

  // Future<String> reportDonation(DonationModel donation) {
  //   return _source.reportDonation(donation);
  // }

  Future<String> reportDonationRaw(Map<String, dynamic> body) {
    return _source.reportDonationRaw(body);
  }

  Future<List<DonationModel>> getMyDonations() async {
    final data = await _source.getMyDonations();

    return data
        .map<DonationModel>((json) => DonationModel.fromApi(json))
        .toList();
  }

  Future<List<DonationModel>> getDonationsByOrganization(
    String organizationId) async {

    final data = await _source.getDonationsByOrganization(organizationId);

    return data
        .map<DonationModel>((json) => DonationModel.fromApi(json))
        .toList();
  }


  Future<int> getDonationsCountByMonth({
    required String organizationId,
    required int monthOffset,
  }) {
    return _source.getDonationsCountByMonth(
      organizationId: organizationId,
      monthOffset: monthOffset,
    );
  }

  Future<int> getDonationsPendingCount(String organizationId) {
    return _source.getDonationsPendingCount(organizationId);
  }


  Future<int> getDonationsCount(String organizationId) {
    return _source.getDonationsCount(organizationId);
  }


  Future<int> getDonationsCanceledCount(String organizationId) {
    return _source.getDonationsCanceledCount(organizationId);
  }


  Future<int> getDonationsConfirmedCount(String organizationId) {
    return _source.getDonationsConfirmedCount(organizationId);
  }

  






}


