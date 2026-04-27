import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TimetableScreen extends StatelessWidget {
  const TimetableScreen({super.key});

  // 🎨 نفس ستايل التطبيق
  static const Color bg = Color(0xFFF9FAFB);
  static const Color cardBg = Colors.white;
  static const Color border = Color(0xFFE5E7EB);
  static const Color primary = Color(0xFF3B82F6);

  static const Color textMain = Color(0xFF111827);
  static const Color textMuted = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    // 📅 بيانات بسيطة (مرتبطة بالكلاسات)
    final timetable = [
      {"class": "L3-SI-G1", "day": "Sunday", "time": "08:00 - 10:00"},
      {"class": "L3-SI-G2", "day": "Monday", "time": "10:00 - 12:00"},
      {"class": "M1-ISIL-G1", "day": "Tuesday", "time": "09:00 - 11:00"},
      {"class": "L2-INFO-G3", "day": "Wednesday", "time": "11:00 - 13:00"},
    ];

    return Scaffold(
      backgroundColor: bg,

      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        title: Text(
          "Timetable",
          style: GoogleFonts.lexend(
            color: textMain,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: timetable.length,
        itemBuilder: (context, index) {
          final t = timetable[index];

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
                // 📘 ICON
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.schedule, color: primary),
                ),

                const SizedBox(width: 15),

                // 📄 INFO
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t["class"]!,
                        style: GoogleFonts.lexend(
                          fontWeight: FontWeight.bold,
                          color: textMain,
                        ),
                      ),
                      Text(
                        "${t["day"]} • ${t["time"]}",
                        style: GoogleFonts.lexend(
                          fontSize: 12,
                          color: textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
