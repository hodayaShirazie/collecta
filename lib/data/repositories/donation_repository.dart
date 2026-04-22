// import '../datasources/remote/api_source.dart';
import '../datasources/remote/donation_api.dart';
import '../models/donation_model.dart';
import '../models/donation_list_item_model.dart';

class DonationRepository {
  final DonationApi _source = DonationApi();

  Future<String> reportDonationRaw(Map<String, dynamic> body) {
    return _source.reportDonationRaw(body);
  }

  Future<List<DonationListItemModel>> getMyDonations() async {
    final data = await _source.getMyDonations();

    return data
        .map<DonationListItemModel>((json) => DonationListItemModel.fromApi(json))
        .toList();
  }
  
  Future<DonationModel> getDonationById(String donationId) async {
    final data = await _source.getDonationById(donationId);
    return DonationModel.fromApi(data['donation']);
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

  Future<String> updateDonation(Map<String, dynamic> body) {
    return _source.updateDonation(body);
  }

  Future<String> cancelDonation(String donationId) {
    return _source.cancelDonation(donationId);
  }

  Future<String> uploadDonationReceipt({
    required String donationId,
    required List<int> fileBytes,
    required String fileName,
  }) {
    return _source.uploadDonationReceipt(
      donationId: donationId,
      fileBytes: fileBytes,
      fileName: fileName,
    );
  }


  Future<List<DonationModel>> getDriverDonationsById() async {
    final data = await _source.getDriverDonationsById();

    return data
        .map<DonationModel>((json) => DonationModel.fromApi(json))
        .toList();
  }


  Future<String> assignDriverToDonation({
    required String donationId,
    required String driverId,
  }) {
    return _source.assignDriverToDonation(
      donationId: donationId,
      driverId: driverId,
    );
  }

  Future<String> submitPickup({
    required String donationId,
    required String donorId,
    required List<Map<String, dynamic>> products,
  }) {
    return _source.submitPickup(donationId: donationId, donorId: donorId, products: products);
  }

  






}


