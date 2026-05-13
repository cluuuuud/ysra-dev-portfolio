import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:attendance_app/app_colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        title: Text(
          'Settings',
          style: GoogleFonts.lexend(fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: Text(
          'Settings',
          style: GoogleFonts.lexend(color: AppColors.textMuted),
        ),
      ),
    );
  }
}
