// lib/app/app.dart
import 'package:flutter/material.dart';
import 'package:collecta/app/routes.dart';
import 'package:collecta/app/theme.dart';
import 'package:collecta/ui/screens/entering.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Collecta Firebase App',
      theme: AppTheme.lightTheme,           // Theme אחיד
      darkTheme: AppTheme.darkTheme,        // Optional: Dark mode
      initialRoute: Routes.entering,        // route התחלה
      routes: Routes.routesMap,             // כל המסכים
      debugShowCheckedModeBanner: false,
    );
  }
}
