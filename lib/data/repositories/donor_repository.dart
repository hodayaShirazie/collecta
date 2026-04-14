// lib/data/repositories/donor_repository.dart
// import '../datasources/remote/api_source.dart';
import '../datasources/remote/donor_api.dart';
import '../models/donor_model.dart';

class DonorRepository {
  // final ApiSource _source = ApiSource();
  final DonorApi _source = DonorApi();

  Future<DonorProfile> getDonorProfile() async {
    final data = await _source.getDonorProfile();
    return DonorProfile.fromApi(data);
  }

  Future<String> updateDonorProfile(DonorProfile donor) {
    // Extract address ID, defaulting to empty string if null or empty
    final addressId = donor.businessAddress?.id ?? '';

    return _source.updateDonorProfile(
      businessName: donor.businessName,
      businessPhone: donor.businessPhone,
      businessAddress: addressId,
      contactName: donor.contactName,
      contactPhone: donor.contactPhone,
      crn: donor.crn,
    );
  }

  Future<DonorProfile> getDonorProfileById(String donorId) async {
    final data = await _source.getDonorProfileById(donorId);
    return DonorProfile.fromApi(data);
  }


}