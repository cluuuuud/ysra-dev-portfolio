import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'database/db_helper.dart';

class SessionDetailsScreen extends StatelessWidget {
  const SessionDetailsScreen({super.key});

  static const Color bg = Color(0xFFF8FAFC);
  static const Color cardBg = Colors.white;
  static const Color border = Color(0xFFE2E8F0);
  static const Color textMain = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    final session = ModalRoute.of(context)!.settings.arguments as Map;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        title: Text(
          session["class_name"] ?? "",
          style: GoogleFonts.lexend(
            color: textMain,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      // 🔥 هنا التغيير الحقيقي
      body: FutureBuilder(
        future: DBHelper.getStudentsBySession(session["session_id"]),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final students = snapshot.data as List<Map<String, dynamic>>;
          if (students.isEmpty) {
            return const Center(child: Text("No students 😴"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: students.length,
            itemBuilder: (context, i) {
              final s = students[i];

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: border),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        s["student_name"] ?? "",
                        style: GoogleFonts.lexend(
                          color: textMain,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    // 🔥 الحالة من DB
                    Text(
                      s["status"] ?? "Absent",
                      style: GoogleFonts.lexend(color: textMuted),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
