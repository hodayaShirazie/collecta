// lib/data/services/donor_service.dart
import '../data/repositories/donor_repository.dart';
import '../data/models/donor_model.dart';

class DonorService {
  final DonorRepository _repo = DonorRepository();

  // Cache: פרופיל תורם
  static DonorProfile? _cachedProfile;
  static DateTime? _profileCacheTime;
  static const _profileTTL = Duration(minutes: 5);

  static void invalidateProfileCache() {
    _cachedProfile = null;
    _profileCacheTime = null;
  }

  Future<DonorProfile> getMyDonorProfile() async {
    final now = DateTime.now();
    if (_cachedProfile != null &&
        _profileCacheTime != null &&
        now.difference(_profileCacheTime!) < _profileTTL) {
      return _cachedProfile!;
    }
    final result = await _repo.getDonorProfile();
    _cachedProfile = result;
    _profileCacheTime = now;
    return result;
  }

  Future<String> updateDonorProfile(DonorProfile donor) async {
    final result = await _repo.updateDonorProfile(donor);
    invalidateProfileCache();
    return result;
  }

  Future<DonorProfile> getDonorProfileById(String donorId) {
    return _repo.getDonorProfileById(donorId);
  }
}
