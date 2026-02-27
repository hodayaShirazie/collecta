import 'package:flutter/material.dart';
import '../../services/organization_service.dart';
import '../theme/edit_profile_donor_theme.dart';
import '../theme/homepage_theme.dart';
import '../../services/user_service.dart';
import '../../data/models/donor_model.dart';

const String kOrganizationId = 'xFKMWqidL2uZ5wnksdYX';

class DonorEditProfileScreen extends StatefulWidget {
  const DonorEditProfileScreen({super.key});

  @override
  State<DonorEditProfileScreen> createState() => _DonorEditProfileScreenState();
}

class _DonorEditProfileScreenState extends State<DonorEditProfileScreen> {
  final orgService = OrganizationService();
  final userService = UserService();

  late Future _profileFuture;

  final nameCtrl = TextEditingController();
  final businessNameCtrl = TextEditingController();
  final businessPhoneCtrl = TextEditingController();
  final businessAddressCtrl = TextEditingController();
  final contactNameCtrl = TextEditingController();
  final contactPhoneCtrl = TextEditingController();
  final crnCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _profileFuture = _loadProfile();
  }

  Future _loadProfile() async {
    final data = await userService.fetchMyProfile("donor");
    final donor = DonorProfile.fromApi(data);
    
    nameCtrl.text = donor.user.name;
    businessNameCtrl.text = donor.businessName;
    businessPhoneCtrl.text = donor.businessPhone;
    // businessAddressCtrl.text = donor.businessAddressId;
    contactNameCtrl.text = donor.contactName;
    contactPhoneCtrl.text = donor.contactPhone;
    crnCtrl.text = donor.crn;

    return donor;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder(
        future: Future.wait([
          orgService.fetchOrganization(kOrganizationId),
          _profileFuture,
        ]),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final org = snapshot.data![0];

          return Container(
            decoration: BoxDecoration(gradient: HomepageTheme.pageGradient),
            child: SafeArea(
              child: Stack(
                children: [
                  Positioned(
                    top: -100,
                    right: -60,
                    child: Container(
                      width: 260,
                      height: 260,
                      decoration: HomepageTheme.decorativeCircle,
                    ),
                  ),

                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                      child: Column(
                        children: [
                          const SizedBox(height: HomepageTheme.topPadding),

                          Image.network(org.logo, height: HomepageTheme.logoHeight),
                          const SizedBox(height: 10),

                          Text('עריכת פרטים אישיים', style: DonorEditProfileTheme.headerStyle),
                          const SizedBox(height: 8),
                          Container(
                            width: 120,
                            height: 6,
                            decoration: BoxDecoration(
                              color: HomepageTheme.latetYellow,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 14),

                          Text(
                            '!שמחים לראות אותך שוב',
                            style: HomepageTheme.subtitleTextStyle.copyWith(
                              color: HomepageTheme.latetBlue.withOpacity(0.8),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Centered proportional form
                          LayoutBuilder(builder: (context, constraints) {
                            final screenWidth = constraints.maxWidth;
                            final widthFactor = screenWidth > 900 ? 0.6 : (screenWidth > 600 ? 0.8 : 0.95);

                            return Center(
                              child: FractionallySizedBox(
                                widthFactor: widthFactor,
                                child: Container(
                                  decoration: DonorEditProfileTheme.containerDecoration,
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // yellow accent stripe
                                      Container(
                                        width: 8,
                                        decoration: BoxDecoration(
                                          color: HomepageTheme.latetYellow,
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(18),
                                            bottomLeft: Radius.circular(18),
                                          ),
                                        ),
                                        height: 1,
                                      ),

                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(18),
                                          child: Column(
                                            children: [
                                              _buildLabeledField('שם משתמש:', nameCtrl),
                                              _buildLabeledField('שם העסק:', businessNameCtrl),
                                              _buildLabeledField('פלאפון עסק:', businessPhoneCtrl),
                                              _buildLabeledField('כתובת העסק:', businessAddressCtrl),
                                              _buildLabeledField('שם איש קשר:', contactNameCtrl),
                                              _buildLabeledField('פלאפון איש קשר:', contactPhoneCtrl),
                                              _buildLabeledField('ח"פ/עוסק מורשה:', crnCtrl),

                                              const SizedBox(height: 18),

                                              SizedBox(
                                                width: double.infinity,
                                                child: ElevatedButton(
                                                  onPressed: _save,
                                                  style: DonorEditProfileTheme.saveButtonStyle,
                                                  child: const Text('שמור'),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),

                          const SizedBox(height: 30),
                          Image.network(org.departmentLogo, height: HomepageTheme.deptLogoHeight),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _save() async {
    try {
      await userService.updateUserProfile(
      name: nameCtrl.text,
      // img: "", // או להשאיר את הישן אם תרצי
      );
      await userService.updateDonorProfile(
        businessName: businessNameCtrl.text,
        businessPhone: businessPhoneCtrl.text,
        businessAddressId: businessAddressCtrl.text,
        contactName: contactNameCtrl.text,
        contactPhone: contactPhoneCtrl.text,
        crn: crnCtrl.text,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("הפרטים נשמרו בהצלחה")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("שגיאה בשמירה: $e")),
      );
    }
  }

  Widget _buildLabeledField(String label, TextEditingController ctrl) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(label, style: DonorEditProfileTheme.labelStyle),
          const SizedBox(height: 4),
          Directionality(
            textDirection: TextDirection.rtl,
            child: TextFormField(
              controller: ctrl,
              textAlign: TextAlign.center,
              decoration: DonorEditProfileTheme.inputDecoration,
            ),
          ),
        ],
      ),
    );
  }
}
