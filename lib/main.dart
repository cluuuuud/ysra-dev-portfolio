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

/// Global notifier — أي شاشة تقدر تستعملو
final themeModeNotifier = ValueNotifier<ThemeMode>(ThemeMode.light);

void main() {
  runApp(const AttendixApp());
}

class AttendixApp extends StatelessWidget {
  const AttendixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeModeNotifier,
      builder: (_, mode, __) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'ATTENDIX',
        themeMode: mode,

        // ── Light theme ────────────────────────────────────────────────────
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2A7BF1),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          fontFamily: 'Lexend',
          scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        ),

        // ── Dark theme ─────────────────────────────────────────────────────
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2A7BF1),
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
          fontFamily: 'Lexend',
          scaffoldBackgroundColor: const Color(0xFF0F172A),
        ),

        initialRoute: '/splash',
        routes: {
          '/splash': (_) => const SplashScreen(),
          '/': (_) => const OnboardingScreen(),
          '/login': (_) => const LoginScreen(),
          '/dashboard': (_) => const DashboardScreen(),
          '/attendance': (_) => const AttendanceListScreen(),
          '/settings': (_) => const SettingScreen(),
          '/profile': (_) => const ProfileScreen(),
          '/history': (_) => const SessionHistoryScreen(),
          '/import-export': (_) => const ImportExportScreen(),
          '/timetable': (_) => const TimetableScreen(),
          '/today_sessions': (_) => const TodaySessionsScreen(),
          '/management': (_) => const ManagementScreen(),
        },
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
      ),
    );
  }
}
