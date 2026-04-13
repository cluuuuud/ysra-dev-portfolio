import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'attendance_record_screen.dart';

class StudentsScreen extends StatelessWidget {
  final List<Map<String, String>> students = [
    {"name": "Yousra", "id": "2021001", "status": "Excellent"},
    {"name": "Yasmine Halib", "id": "2021002", "status": "Good"},
    {"name": "Sheima", "id": "2021003", "status": "Average"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A1A2E),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Students",
          style: GoogleFonts.poppins(color: Colors.white),
        ),
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: TextField(
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Search student...",
                hintStyle: TextStyle(color: Colors.white30),
                prefixIcon: Icon(Icons.search, color: Colors.blueAccent),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(
                  "Total Students: ",
                  style: TextStyle(color: Colors.white70),
                ),
                Text(
                  "${students.length}",
                  style: TextStyle(
                    color: Colors.blueAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 10),

          Expanded(
            child: ListView.builder(
              itemCount: students.length,
              itemBuilder: (context, index) {
                return _buildStudentItem(context, students[index]);
              },
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        child: Icon(Icons.add),
        onPressed: () {},
      ),
    );
  }

  // 🔥 هنا الحل: ضفنا context
  Widget _buildStudentItem(BuildContext context, Map<String, String> student) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white10),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(15),

        leading: CircleAvatar(
          backgroundColor: Colors.blueAccent.withOpacity(0.2),
          child: Text(
            student['name']![0],
            style: TextStyle(
              color: Colors.blueAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        title: Text(student['name']!, style: TextStyle(color: Colors.white)),

        subtitle: Text(
          "ID: ${student['id']}",
          style: TextStyle(color: Colors.white38),
        ),

        trailing: Text(
          student['status']!,
          style: TextStyle(color: Colors.blueAccent),
        ),

        // 🔥 هنا التنقل
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  AttendanceRecordScreen(studentName: student['name']!),
            ),
          );
        },
      ),
    );
  }
}
