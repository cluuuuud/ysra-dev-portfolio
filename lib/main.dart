import 'package:flutter/material.dart';
import 'package:attendance_app/screens/onboarding_screen.dart';
import 'package:attendance_app/screens/login_screen.dart';
import 'package:attendance_app/screens/dashboard_screen.dart';
import 'package:attendance_app/screens/attendance_list_screen.dart';
import 'package:attendance_app/screens/profile_screen.dart';
import 'package:attendance_app/screens/session_history_screen.dart';
import 'package:attendance_app/screens/setting_screen.dart';
import 'package:attendance_app/screens/session_details_screen.dart';
import 'package:attendance_app/screens/import_export_screen.dart';
import 'package:attendance_app/screens/timetable_screen.dart';
import 'package:attendance_app/screens/today_sessions_screen.dart';
import 'package:attendance_app/screens/management_screen.dart';
import 'package:attendance_app/screens/splash_screen.dart';

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
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2A7BF1)),
        useMaterial3: true,
        fontFamily: 'Lexend',
      ),

      // ── أول شاشة تظهر: Splash ──────────────────────────────────────────
      initialRoute: '/splash',

      routes: {
        '/splash': (context) => const SplashScreen(),
        '/': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/attendance': (context) => const AttendanceListScreen(),
        '/settings': (context) => const SettingScreen(), // ✅ SettingScreen
        '/profile': (context) => const ProfileScreen(),
        '/history': (context) => const SessionHistoryScreen(),
        '/import-export': (context) =>
            const ImportExportScreen(), // ✅ ImportExportScreen
        '/timetable': (context) => const TimetableScreen(),
        '/today_sessions': (context) => const TodaySessionsScreen(),
        '/management': (context) =>
            const ManagementScreen(), // ✅ ManagementScreen
      },

      // ── Routes with arguments ─────────────────────────────────────────────
      onGenerateRoute: (settings) {
        if (settings.name == '/session_details') {
          final id = settings.arguments;
          final sid = id is int ? id : int.tryParse('$id');
          if (sid == null) return null;
          return MaterialPageRoute(
            builder: (_) => SessionDetailsScreen(sessionId: sid),
          );
        }
        return null;
      },
    );
  }
}
