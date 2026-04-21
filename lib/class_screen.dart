import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ClassesScreen extends StatelessWidget {
  const ClassesScreen({super.key});

  static const Color primaryBlue = Color(0xFF2A7BF1);
  static const Color textMain = Color(0xFF1F2937);
  static const Color textMuted = Color(0xFF6B7280);
  static const Color cardBg = Color(0xFFF3F4F6);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: textMain),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Classes",
          style: GoogleFonts.lexend(
            color: textMain,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: primaryBlue),
            onPressed: () {
              // ➕ Add Class (نخدموها من بعد)
            },
          ),
          const SizedBox(width: 10),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            /// 🔍 Search
            Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Search classes...",
                  hintStyle: GoogleFonts.lexend(color: textMuted),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// 📚 Grid Classes
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 1.1,
                children: [
                  _classCard(context, "L3-SI-G1", "Algorithms", 28),
                  _classCard(context, "L3-SI-G2", "Algorithms", 25),
                  _classCard(context, "M1-ISIL-G1", "Software Eng", 22),
                  _classCard(context, "L2-INFO-G3", "OS", 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 📦 Class Card
  Widget _classCard(
    BuildContext context,
    String title,
    String subject,
    int count,
  ) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, '/attendance');
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.lexend(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subject,
              style: GoogleFonts.lexend(color: textMuted, fontSize: 12),
            ),
            const Spacer(),
            Row(
              children: [
                const Icon(Icons.people, size: 16, color: primaryBlue),
                const SizedBox(width: 5),
                Text(
                  "$count students",
                  style: GoogleFonts.lexend(fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
