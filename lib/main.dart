import 'package:flutter/material.dart';
import 'onboarding_screen.dart';
import 'login_screen.dart';
import 'dashboard_screen.dart';
import 'class_screen.dart';
import 'attendance_list_screen.dart';
import 'profile_screen.dart';
import 'session_history_screen.dart';
import 'setting_screen.dart';
import 'sessions_details_screen.dart';
import 'Export_screen.dart';

void main() {
  runApp(const AttendixApp());
}

class AttendixApp extends StatelessWidget {
  const AttendixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ATTENDIX',

      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Lexend',
      ),

      initialRoute: '/',

      routes: {
        '/': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/classes': (context) => const ClassesScreen(),
        '/attendance': (context) => const AttendanceListScreen(),
        '/settings': (context) => SettingsScreen(),
        '/profile': (context) => ProfileScreen(),
        '/history': (context) => SessionHistoryScreen(),
        '/session_details': (context) => SessionDetailsScreen(),
        '/export': (context) => ExportScreen(),
      },
    );
  }
}
