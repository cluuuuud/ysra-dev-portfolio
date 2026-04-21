import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

    final students = [
      {"name": "Yousra", "status": "Present"},
      {"name": "Amine", "status": "Absent"},
    ];

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        title: Text(
          session["class"],
          style: GoogleFonts.lexend(
            color: textMain,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: ListView.builder(
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
                    s["name"]!,
                    style: GoogleFonts.lexend(
                      color: textMain,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Text(s["status"]!, style: GoogleFonts.lexend(color: textMuted)),
              ],
            ),
          );
        },
      ),
    );
  }
}
