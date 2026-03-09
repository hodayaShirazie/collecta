import 'package:flutter/material.dart';
import '../../services/driver_service.dart';
import '../../data/models/driver_model.dart';

class DriverEditProfileScreen extends StatefulWidget {
  const DriverEditProfileScreen({super.key});

  @override
  State<DriverEditProfileScreen> createState() => _DriverEditProfileScreenState();
}

class _DriverEditProfileScreenState extends State<DriverEditProfileScreen> {

  final DriverService _driverService = DriverService();

  DriverProfile? driver;

  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final areaCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadDriverProfile();
  }

  Future<void> _loadDriverProfile() async {

    try {

      driver = await _driverService.getMyDriverProfile();

      /// מילוי השדות
      nameCtrl.text = driver!.user.name;
      phoneCtrl.text = driver!.phone;
      areaCtrl.text = driver!.area;

      setState(() {});

    } catch (e) {

      print("Error loading driver profile: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("שגיאה בטעינת הפרופיל")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,

      body: driver == null
          ? const Center(child: CircularProgressIndicator())

          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),

                child: Column(
                  children: [

                    const SizedBox(height: 50),

                    const Text(
                      "עריכת פרטי נהג",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 30),

                    _buildLabeledField("שם משתמש:", nameCtrl),

                    _buildLabeledField("פלאפון:", phoneCtrl),

                    _buildLabeledField("אזור:", areaCtrl),

                    const SizedBox(height: 30),

                    const Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        "יעדים",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: driver!.destinations.isEmpty
                          ? const Text("אין יעדים")
                          : Column(
                              children: driver!.destinations.map((destination) {

                                return Card(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  child: ListTile(
                                    title: Text(
                                      destination.address.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Text(
                                      "${destination.day} • ${destination.name}",
                                    ),
                                  ),
                                );

                              }).toList(),
                            ),
                    ),

                    const SizedBox(height: 40),

                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildLabeledField(
    String label,
    TextEditingController ctrl,
  ) {

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,

        children: [

          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 4),

          Directionality(
            textDirection: TextDirection.rtl,

            child: TextFormField(
              controller: ctrl,
              textAlign: TextAlign.center,

              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}