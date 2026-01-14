import 'package:flutter/material.dart';
import 'package:collecta/ui/screens/entering.dart';
import 'package:collecta/ui/screens/debug_firestore_screen.dart';


class Routes {
  static const entering = '/entering';
  static const debug = '/debug';

  static Map<String, WidgetBuilder> routesMap = {
    entering: (context) => const EnteringScreen(),
    debug: (context) => const DebugFirestoreScreen(),
  };
}
