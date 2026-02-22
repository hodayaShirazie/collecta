import '../data/repositories/user_repository.dart';
import '../data/models/user_model.dart';

class UserService {
  final UserRepository _repo = UserRepository();

  Future<List<UserModel>> fetchUsers() {
    return _repo.getUsers();
  }

  Future<String> syncUserWithRole({
    required String name,
    required String mail,
    required String img,
    required String role,
    required String organizationId,
  }) async {
    return await _repo.syncUserWithRole(
      name: name,
      mail: mail,
      img: img,
      role: role,
      organizationId: organizationId,
    );
  }
  
  Future<Map<String, dynamic>> fetchMyProfile(String role) {
    return _repo.fetchMyProfile(role);
  }

  Future<String> updateDonorProfile({
    required String businessName,
    required String businessPhone,
    required String businessAddressId,
    required String contactName,
    required String contactPhone,
    required String crn,
  }) {
    return _repo.updateDonorProfile(
      businessName: businessName,
      businessPhone: businessPhone,
      businessAddressId: businessAddressId,
      contactName: contactName,
      contactPhone: contactPhone,
      crn: crn,
    );
  }

  //   Future<String> updateDriverProfile({
  //   required String phone,
  //   required String area,
  //   required List<dynamic> destination,
  // }) {
  //   return _repo.updateDriverProfile(
  //     phone: phone,
  //     area: area,
  //     destination: destination,
  //   );
  // }


} 

