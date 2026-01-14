import 'package:flutter/material.dart';
import '../../services/user_service.dart';
import '../../services/organization_service.dart';

class DebugFirestoreScreen extends StatelessWidget {
  const DebugFirestoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userService = UserService();
    final orgService = OrganizationService();

    return Scaffold(
      appBar: AppBar(title: const Text('Firestore Debug')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Text('Organizations', style: TextStyle(fontSize: 20)),
            FutureBuilder(
              future: orgService.fetchOrganizations(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }
                final orgs = snapshot.data!;
                return Column(
                  children: orgs
                      .map((o) => ListTile(
                            title: Text(o.name),
                            subtitle: Text(o.id),
                          ))
                      .toList(),
                );
              },
            ),
            const Divider(),
            const Text('Users', style: TextStyle(fontSize: 20)),
            FutureBuilder(
              future: userService.fetchUsers(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }
                final users = snapshot.data!;
                return Column(
                  children: users
                      .map((u) => ListTile(
                            title: Text(u.name),
                            subtitle: Text(u.mail),
                          ))
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
