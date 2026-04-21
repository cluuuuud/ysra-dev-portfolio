import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StudentsScreen extends StatelessWidget {
  final String className;

  const StudentsScreen({super.key, required this.className});

  final List<String> students = const [
    "Ahmed",
    "Sara",
    "Yacine",
    "Lina",
    "Omar",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Students - $className",
          style: GoogleFonts.poppins(color: Colors.white),
        ),
      ),

      body: ListView.builder(
        itemCount: students.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              students[index],
              style: const TextStyle(color: Colors.white),
            ),
          );
        },
      ),
    );
  }
}
