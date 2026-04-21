import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SessionHistoryScreen extends StatelessWidget {
  const SessionHistoryScreen({super.key});

  static const Color bg = Color(0xFFF8FAFC);
  static const Color cardBg = Colors.white;
  static const Color border = Color(0xFFE2E8F0);
  static const Color textMain = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    final sessions = [
      {"class": "L3-SI-G1", "date": "2026-04-20", "p": 25, "a": 5},
      {"class": "M1-ISIL", "date": "2026-04-18", "p": 20, "a": 3},
    ];

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        title: Text(
          "Session History",
          style: GoogleFonts.lexend(
            color: textMain,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: sessions.length,
        itemBuilder: (context, i) {
          final s = sessions[i];

          return GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/session_details', arguments: s);
            },
            child: Container(
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
                          s["class"].toString(),
                          style: GoogleFonts.lexend(
                            fontWeight: FontWeight.w600,
                            color: textMain,
                          ),
                        ),
                        Text(
                          s["date"].toString(),
                          style: GoogleFonts.lexend(
                            color: textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    "P:${s["p"]}  A:${s["a"]}",
                    style: GoogleFonts.lexend(color: textMuted),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
