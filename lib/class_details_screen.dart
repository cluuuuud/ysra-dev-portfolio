import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ClassDetailsScreen extends StatelessWidget {
  final String className;

  const ClassDetailsScreen({super.key, required this.className});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(className, style: GoogleFonts.poppins(color: Colors.white)),
      ),

      body: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            _buildButton(context, "Students", Icons.people, () {
              Navigator.pushNamed(context, '/students');
            }),

            const SizedBox(height: 20),

            _buildButton(context, "Timetable", Icons.schedule, () {
              Navigator.pushNamed(context, '/timetable');
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.blueAccent),
            const SizedBox(width: 15),
            Text(
              title,
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
            ),
            const Spacer(),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white38,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
