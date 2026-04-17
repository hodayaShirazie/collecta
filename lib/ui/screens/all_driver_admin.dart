import 'package:flutter/material.dart';
import '../../services/driver_service.dart';
import '../../services/impersonation_manager.dart';
import '../../data/models/driver_model.dart';
import '../../ui/screens/driver_homepage.dart';
import '../../ui/utils/validators/phone_validator.dart';
import '../../ui/utils/validators/email_validator.dart';
import '../../ui/widgets/custom_popup_dialog.dart';

class AllDriverAdmin extends StatefulWidget {
  final String organizationId;

  const AllDriverAdmin({super.key, required this.organizationId});

  @override
  State<AllDriverAdmin> createState() => _AllDriverAdminState();
}

class _AllDriverAdminState extends State<AllDriverAdmin> {
  final TextEditingController _searchController = TextEditingController();
  final DriverService _service = DriverService();

  String searchQuery = "";
  List<DriverProfile> drivers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
     print("ORG ID: ${widget.organizationId}");
    _loadDrivers();
  }

  Future<void> _loadDrivers() async {
    try {
      final result = await _service
          .fetchDriversByOrganization(widget.organizationId);

      setState(() {
        drivers = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _showAddDriverDialog() async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    bool isSubmitting = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text(
              "הוספת נהג חדש",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C5AA0),
              ),
            ),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    keyboardType: TextInputType.name,
                    decoration: InputDecoration(
                      labelText: "שם מלא",
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty) ? "שדה חובה" : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    textDirection: TextDirection.ltr,
                    decoration: InputDecoration(
                      labelText: "כתובת מייל",
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: validateEmail,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    textDirection: TextDirection.ltr,
                    decoration: InputDecoration(
                      labelText: "מספר טלפון",
                      prefixIcon: const Icon(Icons.phone_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: validatePhone,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: isSubmitting ? null : () => Navigator.pop(ctx),
                child: const Text("ביטול"),
              ),
              ElevatedButton(
                onPressed: isSubmitting
                    ? null
                    : () async {
                        if (!formKey.currentState!.validate()) return;
                        setDialogState(() => isSubmitting = true);
                        try {
                          await _service.addDriverByAdmin(
                            name: nameController.text.trim(),
                            email: emailController.text.trim(),
                            phone: phoneController.text.trim(),
                            organizationId: widget.organizationId,
                          );
                          if (ctx.mounted) Navigator.pop(ctx);
                          await _loadDrivers();
                          if (mounted) {
                            showDialog(
                              context: context,
                              builder: (_) => Directionality(
                                textDirection: TextDirection.rtl,
                                child: CustomPopupDialog(
                                  title: "הנהג נוסף בהצלחה",
                                  message: "הנהג נוסף למערכת בהצלחה.",
                                  buttonText: "סגור",
                                ),
                              ),
                            );
                          }
                        } catch (e) {
                          setDialogState(() => isSubmitting = false);
                          if (mounted) {
                            showDialog(
                              context: context,
                              builder: (_) => Directionality(
                                textDirection: TextDirection.rtl,
                                child: CustomPopupDialog(
                                  title: "שגיאה",
                                  message: e.toString().replaceFirst("Exception: ", ""),
                                  buttonText: "סגור",
                                ),
                              ),
                            );
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2C5AA0),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text("הוסף נהג"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<DriverProfile> get filteredDrivers {
    if (searchQuery.isEmpty) return drivers;

    return drivers.where((driver) {
      return driver.user.name.contains(searchQuery) ||
          driver.phone.contains(searchQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFE8EDF6),
        floatingActionButton: FloatingActionButton(
          onPressed: _showAddDriverDialog,
          backgroundColor: const Color(0xFF2C5AA0),
          child: const Icon(Icons.add, color: Colors.white),
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 650),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 30),

                    const Text(
                      "נהגים שלי",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C5AA0),
                      ),
                    ),

                    const SizedBox(height: 30),

                    /// חיפוש
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 20),
                      height: 55,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search,
                              color: Colors.grey),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              onChanged: (value) {
                                setState(() {
                                  searchQuery = value;
                                });
                              },
                              decoration: const InputDecoration(
                                hintText: "חיפוש נהג...",
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 35),

                    /// רשימה
                    Expanded(
                      child: isLoading
                          ? const Center(
                              child: CircularProgressIndicator(),
                            )
                          : filteredDrivers.isEmpty
                              ? const Center(
                                  child: Text("אין נהגים להצגה"),
                                )
                              : ListView.separated(
                                  itemCount:
                                      filteredDrivers.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: 15),
                                  itemBuilder: (context, index) {
                                    final driver =
                                        filteredDrivers[index];


                                    return InkWell(
                                        borderRadius: BorderRadius.circular(24),
                                        onTap: () async {
                                          ImpersonationManager.instance.start(
                                            driver.user.id,
                                            driverName: driver.user.name,
                                          );
                                          await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => DriverHomepage(
                                                driver: driver,
                                                isAdminImpersonating: true,
                                              ),
                                            ),
                                          );
                                          ImpersonationManager.instance.stop();
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(24),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.05),
                                                blurRadius: 16,
                                                offset: const Offset(0, 6),
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            children: [

                                              /// 👤 אייקון נהג (במקום תמונה)
                                              Container(
                                                width: 52,
                                                height: 52,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: const Color(0xFFE8EDF6),
                                                ),
                                                child: const Icon(
                                                  Icons.person_outline_rounded,
                                                  size: 28,
                                                  color: Color(0xFF2C5AA0),
                                                ),
                                              ),

                                              const SizedBox(width: 16),

                                              /// פרטים
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [

                                                    /// שם הנהג – מודגש ויפה
                                                    Text(
                                                      driver.user.name,
                                                      style: const TextStyle(
                                                        fontSize: 20,
                                                        fontWeight: FontWeight.w700,
                                                        fontFamily: 'Assistant',
                                                        color: Color(0xFF1E2A38),
                                                      ),
                                                    ),

                                                    const SizedBox(height: 6),

                                                    /// טלפון
                                                    Text(
                                                      driver.phone.isEmpty
                                                          ? "אין מספר טלפון"
                                                          : driver.phone,
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                        fontFamily: 'Roboto',
                                                        fontWeight: FontWeight.w500,
                                                        color: Colors.black87,
                                                        letterSpacing: 0.8,
                                                      ),
                                                      textDirection: TextDirection.ltr,
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              /// ➜ חץ כמו בקוד הישן
                                              const Icon(
                                                Icons.chevron_right,
                                                color: Colors.blueGrey,
                                              ),
                                            ],
                                          ),
                                        ),
                                      );

                                  },
                                ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
