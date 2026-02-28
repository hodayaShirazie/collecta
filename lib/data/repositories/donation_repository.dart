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

}
