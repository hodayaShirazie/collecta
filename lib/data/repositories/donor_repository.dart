// lib/data/repositories/donor_repository.dart
import '../datasources/remote/api_source.dart';
import '../models/donor_model.dart';

class DonorRepository {
  final ApiSource _source = ApiSource();

  Future<DonorProfile> getDonorProfile() async {
    final data = await _source.getDonorProfile();
    return DonorProfile.fromApi(data);
  }
}