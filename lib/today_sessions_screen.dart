import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SessionModel {
  String day;
  String time;
  String subject;
  String type;
  String className;

  SessionModel({
    required this.day,
    required this.time,
    required this.subject,
    required this.type,
    required this.className,
  });
}

class TodaySessionsScreen extends StatelessWidget {
  const TodaySessionsScreen({super.key});

  static const Color bg = Color(0xFFF8FAFC);
  static const Color cardBg = Colors.white;
  static const Color border = Color(0xFFE2E8F0);
  static const Color textMain = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF64748B);
  static const Color primary = Color(0xFF2563EB);

  @override
  Widget build(BuildContext context) {
    // 🔥 TEMP DATA (لاحقاً من DB)
    final sessions = [
      SessionModel(
        day: "Monday",
        time: "09:00 - 10:30",
        subject: "ASD1",
        type: "Lecture",
        className: "L3-SI-G1",
      ),
      SessionModel(
        day: "Tuesday",
        time: "11:00 - 12:30",
        subject: "GL",
        type: "TD",
        className: "L3-SI-G2",
      ),
    ];

    String today = _getToday();

    final todaySessions = sessions.where((s) => s.day == today).toList();

    return Scaffold(
      backgroundColor: bg,

      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        title: Text(
          "Today's Sessions",
          style: GoogleFonts.lexend(
            color: textMain,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: todaySessions.isEmpty
            ? Center(
                child: Text(
                  "No sessions today",
                  style: GoogleFonts.lexend(color: textMuted),
                ),
              )
            : ListView.builder(
                itemCount: todaySessions.length,
                itemBuilder: (context, index) {
                  final s = todaySessions[index];

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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                s.subject,
                                style: GoogleFonts.lexend(
                                  fontWeight: FontWeight.w600,
                                  color: textMain,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${s.className} • ${s.type}",
                                style: GoogleFonts.lexend(
                                  fontSize: 12,
                                  color: textMuted,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                s.time,
                                style: GoogleFonts.lexend(
                                  fontSize: 12,
                                  color: textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // 🚀 Start Attendance
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pushNamed(context, '/attendance');
                          },
                          child: const Text("Start"),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }

  // 📅 Get Today
  String _getToday() {
    final now = DateTime.now().weekday;

    switch (now) {
      case 1:
        return "Monday";
      case 2:
        return "Tuesday";
      case 3:
        return "Wednesday";
      case 4:
        return "Thursday";
      case 5:
        return "Friday";
      default:
        return "Sunday";
    }
  }
}
