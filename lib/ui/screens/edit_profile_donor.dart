import 'package:flutter/material.dart';
import '../../services/organization_service.dart';
import '../theme/edit_profile_donor_theme.dart';
import '../../services/user_service.dart';
import '../../data/models/donor_model.dart';

// class DonorEditProfileScreen extends StatelessWidget {
//   const DonorEditProfileScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final orgService = OrganizationService();

//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: FutureBuilder(
//         future: orgService.fetchOrganization('xFKMWqidL2uZ5wnksdYX'),
//         builder: (context, snapshot) {
//           if (!snapshot.hasData) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           final org = snapshot.data!;

//           return SafeArea(
//             child: SingleChildScrollView( // מאפשר גלילה כשהמקלדת נפתחת
//               child: Column(
//                 children: [
//                   const SizedBox(height: 20),
//                   // לוגו עליון
//                   Image.network(org.logo, height: 80),
//                   const SizedBox(height: 10),
//                   const Text('עריכת פרטים אישיים', style: DonorEditProfileTheme.headerStyle),
//                   const SizedBox(height: 20),

//                   // תיבת הטופס עם המסגרת הכחולה
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 30),
//                     child: Container(
//                       decoration: DonorEditProfileTheme.containerDecoration,
//                       padding: const EdgeInsets.all(16),
//                       child: Column(
//                         children: [
//                           _buildLabeledField('שם התורם:', 'בני גרין'),
//                           _buildLabeledField('שם העסק:', 'בני ובניו'),
//                           _buildLabeledField('פלאפון עסק:', '088664668'),
//                           _buildLabeledField('כתובת העסק:', 'אחד העם 2 רמת גן'),
//                           _buildLabeledField('ח"פ/עוסק מורשה:', '51103545'),
//                           _buildLabeledField('שם איש קשר:', 'גיל רצון'),
//                           _buildLabeledField('פלאפון איש קשר:', '0525388026'),
                          
//                           const SizedBox(height: 20),
                          
//                           // כפתור שמור
//                           ElevatedButton(
//                             onPressed: () => print('נתונים נשמרו'),
//                             style: DonorEditProfileTheme.saveButtonStyle,
//                             child: const Text('שמור'),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),

//                   const SizedBox(height: 30),
//                   // לוגו תחתון
//                   Image.network(org.departmentLogo, height: 60),
//                   const SizedBox(height: 20),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   // פונקציית עזר לבניית שדה עם כותרת מעליו
//   Widget _buildLabeledField(String label, String initialValue) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.end, // יישור טקסט לימין (עברית)
//         children: [
//           Text(label, style: DonorEditProfileTheme.labelStyle),
//           const SizedBox(height: 4),
//           Directionality(
//             textDirection: TextDirection.rtl,
//             child: TextFormField(
//               initialValue: initialValue,
//               textAlign: TextAlign.center,
//               style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.blueGrey),
//               decoration: DonorEditProfileTheme.inputDecoration,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
const String kOrganizationId = 'xFKMWqidL2uZ5wnksdYX';

// const kOrganizationId = 'demo';

class DonorEditProfileScreen extends StatefulWidget {
  const DonorEditProfileScreen({super.key});

  @override
  State<DonorEditProfileScreen> createState() => _DonorEditProfileScreenState();
}

class _DonorEditProfileScreenState extends State<DonorEditProfileScreen> {
  final orgService = OrganizationService();
  final userService = UserService();

  late Future _profileFuture;

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

    businessNameCtrl.text = donor.businessName;
    businessPhoneCtrl.text = donor.businessPhone;
    businessAddressCtrl.text = donor.businessAddressId;
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

          return SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Image.network(org.logo, height: 80),
                  const SizedBox(height: 10),
                  const Text('עריכת פרטים אישיים', style: DonorEditProfileTheme.headerStyle),
                  const SizedBox(height: 20),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Container(
                      decoration: DonorEditProfileTheme.containerDecoration,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildLabeledField('שם העסק:', businessNameCtrl),
                          _buildLabeledField('פלאפון עסק:', businessPhoneCtrl),
                          _buildLabeledField('כתובת העסק:', businessAddressCtrl),
                          _buildLabeledField('שם איש קשר:', contactNameCtrl),
                          _buildLabeledField('פלאפון איש קשר:', contactPhoneCtrl),
                          _buildLabeledField('ח"פ/עוסק מורשה:', crnCtrl),

                          const SizedBox(height: 20),

                          ElevatedButton(
                            onPressed: _save,
                            style: DonorEditProfileTheme.saveButtonStyle,
                            child: const Text('שמור'),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                  Image.network(org.departmentLogo, height: 60),
                  const SizedBox(height: 20),
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
