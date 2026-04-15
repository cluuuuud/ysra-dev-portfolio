import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'class_details_screen.dart';

class ClassesScreen extends StatelessWidget {
  const ClassesScreen({super.key});

  final List<Map<String, String>> classes = const [
    {"name": "Group G1", "time": "08:00 - 10:00", "room": "Room 101"},
    {"name": "Group G2", "time": "10:00 - 12:00", "room": "Room 102"},
    {"name": "Group G3", "time": "13:00 - 15:00", "room": "Room 103"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("Classes", style: GoogleFonts.poppins(color: Colors.white)),
      ),

      body: ListView.builder(
        itemCount: classes.length,
        itemBuilder: (context, index) {
          return _buildClassItem(context, classes[index]);
        },
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add),
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Add Class coming soon")),
          );
        },
      ),
    );
  }

  // 🔥 Class Item مع Navigation
  Widget _buildClassItem(BuildContext context, Map<String, String> classe) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ClassDetailsScreen(className: classe['name']!),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.blueAccent.withOpacity(0.2),
              child: const Icon(Icons.class_, color: Colors.blueAccent),
            ),

            const SizedBox(width: 15),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    classe['name']!,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Time: ${classe['time']}",
                    style: const TextStyle(color: Colors.white38),
                  ),
                  Text(
                    "Room: ${classe['room']}",
                    style: const TextStyle(color: Colors.white38),
                  ),
                ],
              ),
            ),

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
