import 'package:flutter/material.dart';

/// ألوان موحّدة مع شاشة التعريف — خلفية بيضاء وهادئة.
class AppColors {
  AppColors._();

  static const Color bg = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE5E7EB);
  static const Color divider = Color(0xFFF3F4F6);
  static const Color primary = Color(0xFF2A7BF1);
  static const Color primaryBg = Color(0xFFEFF6FF);
  static const Color textMain = Color(0xFF1F2937);
  static const Color textSub = Color(0xFF4B5563);
  static const Color textMuted = Color(0xFF6B7280);
  static const Color success = Color(0xFF059669);
  static const Color successBg = Color(0xFFECFDF5);
  static const Color warning = Color(0xFFB45309);
  static const Color warningBg = Color(0xFFFFFBEB);
  static const Color danger = Color(0xFFC2410C);
  static const Color dangerBg = Color(0xFFFFF7ED);
  static const Color purple = Color(0xFF6D28D9);
  static const Color purpleBg = Color(0xFFF5F3FF);

  static Color statusColor(String? s) {
    switch (s) {
      case 'Present':
        return success;
      case 'Absent':
        return danger;
      case 'Late':
        return warning;
      case 'Excused':
        return purple;
      default:
        return textMuted;
    }
  }

  static Color statusBg(String? s) {
    switch (s) {
      case 'Present':
        return successBg;
      case 'Absent':
        return dangerBg;
      case 'Late':
        return warningBg;
      case 'Excused':
        return purpleBg;
      default:
        return divider;
    }
  }
}
