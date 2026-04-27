import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'attendance_record_screen.dart';

class SessionsHistoryScreen extends StatelessWidget {
  const SessionsHistoryScreen({super.key});

  // 🎨 COLORS
  static const Color bg = Color(0xFFF9FAFB);
  static const Color cardBg = Colors.white;
  static const Color border = Color(0xFFE5E7EB);

  static const Color textMain = Color(0xFF111827);
  static const Color textMuted = Color(0xFF6B7280);

  static const Color presentColor = Color(0xFF10B981);
  static const Color lateColor = Color(0xFFF59E0B);
  static const Color absentColor = Color(0xFFEF4444);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,

      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        iconTheme: const IconThemeData(color: textMain),
        title: Text(
          "Sessions History",
          style: GoogleFonts.lexend(
            color: textMain,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: sessions.isEmpty
          ? const Center(child: Text("No sessions yet 😴"))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sessions.length,
              itemBuilder: (context, index) {
                final s = sessions[index];

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s["className"],
                        style: GoogleFonts.lexend(
                          fontWeight: FontWeight.bold,
                          color: textMain,
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        s["date"],
                        style: GoogleFonts.lexend(
                          fontSize: 12,
                          color: textMuted,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _chip("Present", s["present"], presentColor),
                          _chip("Late", s["late"], lateColor),
                          _chip("Absent", s["absent"], absentColor),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _chip(String label, int value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        "$label: $value",
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}
