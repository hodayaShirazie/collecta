// lib/app/routes.dart
import 'package:flutter/material.dart';
import 'package:collecta/ui/screens/entering.dart';
//import 'package:collecta/ui/screens/home.dart';

class Routes {
  static const entering = '/entering';
  static const home = '/home';

  static Map<String, WidgetBuilder> routesMap = {
    entering: (context) => const EnteringScreen(),
    //home: (context) => const HomeScreen(),
  };
}
