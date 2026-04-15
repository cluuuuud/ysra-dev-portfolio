import 'dart:ui';
import 'package:flutter/material.dart';

// 🔥 استدعاء الشاشات
import 'login_screen.dart';
import 'dashboard_screen.dart';
import 'student_screen.dart';
import 'class_screen.dart';
import 'class_details_screen.dart';
import 'timetable_screen.dart';
import 'sessions_screen.dart';
import 'attendance_record_screen.dart';

void main() {
  runApp(const AttendanceApp());
}

class AttendanceApp extends StatelessWidget {
  const AttendanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Student Attendance System',

      theme: ThemeData(brightness: Brightness.dark),

      // 🟢 البداية
      initialRoute: '/login',

      // 🔥 هنا الربط الحقيقي
      routes: {
        '/login': (context) => LoginScreen(),
        '/dashboard': (context) => DashboardScreen(),
        '/classes': (context) => ClassesScreen(),
        '/students': (context) => StudentsScreen(),
        '/timetable': (context) => TimetableScreen(),
        '/attendance': (context) => AttendanceRecordScreen(studentName: "Test"),
      },
    );
  }
}
