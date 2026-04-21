import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ExportScreen extends StatelessWidget {
  const ExportScreen({super.key});

  static const Color primary = Color(0xFF2563EB);
  static const Color bg = Color(0xFFF8FAFC);
  static const Color cardBg = Colors.white;
  static const Color border = Color(0xFFE2E8F0);
  static const Color textMain = Color(0xFF0F172A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        title: Text(
          "Export",
          style: GoogleFonts.lexend(
            color: textMain,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _exportCard("Export as PDF", Icons.picture_as_pdf),
            const SizedBox(height: 12),
            _exportCard("Export as CSV", Icons.table_chart),
          ],
        ),
      ),
    );
  }

  Widget _exportCard(String title, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Icon(icon, color: primary),
          const SizedBox(width: 15),
          Text(
            title,
            style: GoogleFonts.lexend(
              fontWeight: FontWeight.w600,
              color: textMain,
            ),
          ),
          const Spacer(),
          const Icon(Icons.arrow_forward_ios, size: 16),
        ],
      ),
    );
  }
}
