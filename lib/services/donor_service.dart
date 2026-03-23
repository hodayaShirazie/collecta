// lib/data/services/donor_service.dart
import '../data/repositories/donor_repository.dart';
import '../data/models/donor_model.dart';

class DonorService {
  final DonorRepository _repo = DonorRepository();

  Future<DonorProfile> getMyDonorProfile() {
    return _repo.getDonorProfile();
  }

    Future<String> updateDonorProfile(DonorProfile donor) {
    return _repo.updateDonorProfile(donor);
  }

  Future<DonorProfile> getDonorProfileById(String donorId) {
    return _repo.getDonorProfileById(donorId);
  }
}