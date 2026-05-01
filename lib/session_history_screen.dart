import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'database/db_helper.dart';

class SessionsHistoryScreen extends StatelessWidget {
  const SessionsHistoryScreen({super.key});

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

      body: FutureBuilder(
        future: DBHelper.getSessions(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final sessions = snapshot.data as List<Map<String, dynamic>>;
          if (sessions.isEmpty) {
            return const Center(child: Text("No sessions yet 😴"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sessions.length,
            itemBuilder: (context, index) {
              final s = sessions[index];

              return GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/session_details',
                    arguments: s,
                  );
                },
                child: Container(
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
                        s["class_name"] ?? "",
                        style: GoogleFonts.lexend(
                          fontWeight: FontWeight.bold,
                          color: textMain,
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        s["session_date"] ?? "",
                        style: GoogleFonts.lexend(
                          fontSize: 12,
                          color: textMuted,
                        ),
                      ),

                      const SizedBox(height: 10),

                      // 🔥 counts من DB
                      FutureBuilder(
                        future: DBHelper.getAttendanceCount(s["session_id"]),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const SizedBox();
                          }

                          final counts = snapshot.data as Map<String, int>;

                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _chip(
                                "Present",
                                counts["present"] ?? 0,
                                presentColor,
                              ),
                              _chip("Late", 0, lateColor),
                              _chip(
                                "Absent",
                                counts["absent"] ?? 0,
                                absentColor,
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
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
