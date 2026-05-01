import 'package:flutter/material.dart';

import 'onboarding_screen.dart';
import 'login_screen.dart';
import 'dashboard_screen.dart';
import 'attendance_list_screen.dart';
import 'profile_screen.dart';
import 'session_history_screen.dart';
import 'setting_screen.dart';
import 'session_details_screen.dart';
import 'export_screen.dart';
import 'class_list_screen.dart';
import 'timetable_screen.dart';
import 'today_sessions_screen.dart';
import 'student_list_screen.dart';

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
        '/attendance': (context) => const AttendanceListScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/history': (context) => const SessionsHistoryScreen(),
        '/session_details': (context) => const SessionDetailsScreen(),
        '/export': (context) => const ExportScreen(),
        '/classes': (context) => const ClassListScreen(),
        '/timetable': (context) => const TimetableScreen(),
        '/today_sessions': (context) => const TodaySessionsScreen(),
        '/students': (context) => const StudentListScreen(),
      },
    );
  }
}
