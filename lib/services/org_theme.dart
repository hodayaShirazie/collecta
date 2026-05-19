import 'package:flutter/material.dart';
import 'org_manager.dart';

class OrgColors {
  final Color primary;
  final Color accent;
  final Color bgStart;

  const OrgColors({
    required this.primary,
    required this.accent,
    required this.bgStart,
  });
}

class OrgTheme {
  static const _latetId = 'xFKMWqidL2uZ5wnksdYX';
  static const _patahonLevId = 'EHYlWjRIC4T68q2MCDmu';

  static const _latetColors = OrgColors(
    primary: Color(0xFF1E5DAA),
    accent: Color(0xFFFFF9C4),
    bgStart: Color(0xFFEAF2FF),
  );

  static const _patahonLevColors = OrgColors(
    primary: Color(0xFF7B2D8B),
    accent: Color(0xFFE0E0E0),
    bgStart: Color(0xFFF3E5F5),
  );

  static OrgColors get colors {
    switch (OrgManager.orgId) {
      case _patahonLevId:
        return _patahonLevColors;
      default:
        return _latetColors;
    }
  }

  static Color get primaryColor => colors.primary;
  static Color get accentColor => colors.accent;
  static Color get bgStartColor => colors.bgStart;
}
