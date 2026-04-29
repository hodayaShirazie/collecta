import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:collecta/app/theme.dart';
import 'package:collecta/ui/screens/admin_homepage.dart';
import 'package:collecta/ui/screens/all_donation_admin.dart';
import 'package:collecta/ui/screens/all_driver_admin.dart';
import 'package:collecta/ui/screens/activity_zones_admin.dart';
import 'package:collecta/ui/screens/admin_entering.dart';
import 'package:collecta/ui/guards/admin_guard.dart';
import 'package:collecta/services/org_manager.dart';
import 'package:collecta/services/notification_service.dart';
import 'package:collecta/data/models/notification_model.dart';

class AdminApp extends StatefulWidget {
  const AdminApp({super.key});

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  @override
  State<AdminApp> createState() => _AdminAppState();
}

class _AdminAppState extends State<AdminApp> {
  StreamSubscription<NotificationModel>? _notifSub;

  @override
  void initState() {
    super.initState();
    _notifSub =
        NotificationService().newNotifications.listen(_onNewNotification);
  }

  void _onNewNotification(NotificationModel notification) {
    final context = AdminApp.navigatorKey.currentContext;
    if (context == null) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _CancelledDonationPopup(notification: notification),
    );
  }

  @override
  void dispose() {
    _notifSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: AdminApp.navigatorKey,
      title: 'Collecta Admin',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      locale: const Locale('he'),
      supportedLocales: const [Locale('he')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      initialRoute: '/entering',
      routes: {
        '/entering': (context) => const AdminEnteringScreen(),
        '/admin': (context) => const AdminGuard(child: AdminHomepage()),
        '/admin/all-donations': (context) =>
            const AdminGuard(child: AllDonationsAdmin()),
        '/admin/all-drivers': (context) => AdminGuard(
              child: AllDriverAdmin(organizationId: OrgManager.orgId ?? ''),
            ),
        '/admin/activity-zones': (context) => AdminGuard(
              child:
                  ActivityZonesAdmin(organizationId: OrgManager.orgId ?? ''),
            ),
      },
      onUnknownRoute: (settings) => MaterialPageRoute(
        builder: (context) => const AdminEnteringScreen(),
        settings: settings,
      ),
    );
  }
}

class _CancelledDonationPopup extends StatelessWidget {
  final NotificationModel notification;

  const _CancelledDonationPopup({required this.notification});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.cancel_outlined,
                        color: Colors.red, size: 24),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'תרומה בוטלה',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Divider(height: 1),
                const SizedBox(height: 14),
                _InfoRow(
                    label: 'שם עסק', value: notification.businessName),
                const SizedBox(height: 8),
                _InfoRow(
                    label: 'איש קשר', value: notification.contactName),
                const SizedBox(height: 8),
                _InfoRow(
                    label: 'טלפון', value: notification.contactPhone),
                const SizedBox(height: 8),
                _InfoRow(
                    label: 'סיבת ביטול',
                    value: notification.cancelingReason),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        Expanded(
          child: Text(
            value.isNotEmpty ? value : '—',
            style: const TextStyle(color: Colors.black87),
          ),
        ),
      ],
    );
  }
}
