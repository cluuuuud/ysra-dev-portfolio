import 'package:flutter/material.dart';
import 'attendance_record_screen.dart';

class AttendanceListScreen extends StatelessWidget {
  final String day;
  final String time;
  final String subject;

  const AttendanceListScreen({
    super.key,
    required this.day,
    required this.time,
    required this.subject,
  });

  // 🔹 Dummy Students
  final List<String> students = const [
    "Maria Inas",
    "Yasmine",
    "Yousra",
    "Lina",
    "Mohammed",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text("$subject • $time"),
      ),

      body: ListView.builder(
        itemCount: students.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(
              students[index],
              style: const TextStyle(color: Colors.white),
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white38,
            ),

            // 🔥 الضغط على طالب → تسجيل الحضور
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      AttendanceRecordScreen(studentName: students[index]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
