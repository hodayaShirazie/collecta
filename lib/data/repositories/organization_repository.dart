// import '../datasources/remote/firestore_source.dart';
// import '../models/organization_model.dart';

// class OrganizationRepository {
//   final FirestoreSource _source = FirestoreSource();

//   Future<List<OrganizationModel>> getOrganizations() async {
//     final data = await _source.getCollection('organization');
//     return data.map((e) => OrganizationModel.fromMap(e)).toList();
//   }
// }


import '../datasources/remote/api_source.dart';
import '../models/organization_model.dart';

class OrganizationRepository {
  final ApiSource _source = ApiSource();

  Future<List<OrganizationModel>> getOrganizations() async {
    final data = await _source.getOrganizations();
    return data.map((e) => OrganizationModel.fromMap(e)).toList();
  }
}
