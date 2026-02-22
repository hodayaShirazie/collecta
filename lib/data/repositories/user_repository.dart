
import '../datasources/remote/api_source.dart';
import '../models/user_model.dart';

class UserRepository {
  final ApiSource _source = ApiSource();

  Future<List<UserModel>> getUsers() async {
    final data = await _source.getUsers();
    return data.map((e) => UserModel.fromMap(e)).toList();
  }

  Future<String> syncUserWithRole({
    required String name,
    required String mail,
    required String img,
    required String role,
    required String organizationId,
  }) async {
    return await _source.syncUserWithRole(
      name: name,
      mail: mail,
      img: img,
      role: role,
      organizationId: organizationId,
    );
  }

  Future<Map<String, dynamic>> fetchMyProfile(String role) {
    return _source.getMyProfile(role);
  }

  Future<String> updateDonorProfile({
    required String businessName,
    required String businessPhone,
    required String businessAddressId,
    required String contactName,
    required String contactPhone,
    required String crn,
  }) {
    return _source.updateDonorProfile(
      businessName: businessName,
      businessPhone: businessPhone,
      businessAddressId: businessAddressId,
      contactName: contactName,
      contactPhone: contactPhone,
      crn: crn,
    );
  }

  Future<String> updateDriverProfile({
    required String phone,
    required String area,
    required List<dynamic> destination,

  }) {
    return _source.updateDriverProfile(
      phone: phone,
      area: area,
      destination: destination,
    );
  }

}




