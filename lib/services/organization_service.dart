import '../data/repositories/organization_repository.dart';
import '../data/models/organization_model.dart';

class OrganizationService {
  final OrganizationRepository _repo = OrganizationRepository();

  Future<List<OrganizationModel>> fetchOrganizations() {
    return _repo.getOrganizations();
  }
}
