import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'attendance_record_screen.dart';

class AttendanceListScreen extends StatelessWidget {
  const AttendanceListScreen({super.key});

  // 🎨 SAME PRO PALETTE
  static const Color primary = Color(0xFF2563EB);
  static const Color bg = Color(0xFFF5F7FA);
  static const Color cardBg = Colors.white;
  static const Color border = Color(0xFFE6EAF0);

  static const Color textMain = Color(0xFF0B1220);
  static const Color textMuted = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    final classes = ["L3-SI-G1", "L3-SI-G2", "M1-ISIL-G1", "L2-INFO-G3"];

    return Scaffold(
      backgroundColor: bg,

      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        iconTheme: const IconThemeData(color: textMain),
        title: Text(
          "Classes",
          style: GoogleFonts.lexend(
            color: textMain,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView.builder(
          itemCount: classes.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        AttendanceRecordScreen(className: classes[index]),
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // 📘 ICON
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.menu_book_rounded,
                        color: primary,
                        size: 20,
                      ),
                    ),

                    const SizedBox(width: 15),

                    // 📄 CLASS NAME
                    Expanded(
                      child: Text(
                        classes[index],
                        style: GoogleFonts.lexend(
                          fontWeight: FontWeight.w600,
                          color: textMain,
                        ),
                      ),
                    ),

                    // ➡️ ARROW
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
