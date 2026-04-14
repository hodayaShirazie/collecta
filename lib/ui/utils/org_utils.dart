import '../../services/org_manager.dart';
import '../../services/organization_service.dart';

class OrgUtils {

  static Future<dynamic> loadOrganization() async {
    final orgId = await OrgManager.getOrgId();

    if (orgId == null) {
      print("No organization found - user must enter via link");
      return null;
    }

    final org = await OrganizationService().fetchOrganization(orgId);
    return org;
  }

  static Future<String?> getOrgId() async {
    return OrgManager.getOrgId();
  }
}