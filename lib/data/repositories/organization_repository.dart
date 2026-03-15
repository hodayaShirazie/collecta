// import '../datasources/remote/api_source.dart';
import '../datasources/remote/organization_api.dart';
import '../models/organization_model.dart';

class OrganizationRepository {
  // final ApiSource _source = ApiSource();
  final OrganizationApi _source = OrganizationApi();

  Future<List<OrganizationModel>> getOrganizations() async {
    final data = await _source.getOrganizations();
    return data.map((e) => OrganizationModel.fromMap(e)).toList();
  }
}
