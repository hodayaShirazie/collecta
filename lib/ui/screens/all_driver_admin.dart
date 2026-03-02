import 'package:flutter/material.dart';
import '../../services/driver_service.dart';
import '../../data/models/driver_model.dart';
import '../../ui/screens/driver_homepage.dart';

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
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => DriverHomepage(driver: driver),
                                            ),
                                          );
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
