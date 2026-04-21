import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // 🎨 نفس الـ palette
  static const Color primary = Color(0xFF2563EB);
  static const Color bg = Color(0xFFF8FAFC);
  static const Color cardBg = Colors.white;
  static const Color border = Color(0xFFE2E8F0);

  static const Color textMain = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,

      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        title: Text(
          "Profile",
          style: GoogleFonts.lexend(
            color: textMain,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(color: textMain),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 👤 PROFILE CARD
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: primary.withOpacity(0.1),
                    child: const Icon(Icons.person, size: 40, color: primary),
                  ),

                  const SizedBox(height: 15),

                  // Name
                  Text(
                    "Dr. Yousra Bouslah",
                    style: GoogleFonts.lexend(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: textMain,
                    ),
                  ),

                  const SizedBox(height: 5),

                  // Email
                  Text(
                    "yousra@univ.edu",
                    style: GoogleFonts.lexend(fontSize: 13, color: textMuted),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 📄 INFO CARD
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: border),
              ),
              child: Column(
                children: [
                  _infoRow("Department", "Computer Science"),
                  const Divider(),
                  _infoRow("University", "University of Algiers"),
                  const Divider(),
                  _infoRow("Role", "Professor"),
                ],
              ),
            ),

            const Spacer(),

            // ✏️ EDIT BUTTON
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {},
                child: const Text("EDIT PROFILE"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Text(
            title,
            style: GoogleFonts.lexend(color: textMuted, fontSize: 13),
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.lexend(
              color: textMain,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
