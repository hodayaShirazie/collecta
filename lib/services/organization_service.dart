import '../data/repositories/organization_repository.dart';
import '../data/models/organization_model.dart';

class OrganizationService {
  final OrganizationRepository _repo = OrganizationRepository();

  Future<List<OrganizationModel>> fetchOrganizations() {
    return _repo.getOrganizations();
  }

  Future<OrganizationModel> fetchOrganization(String id) async {
    final orgs = await fetchOrganizations();
    return orgs.firstWhere((o) => o.id == id);
  }
}
