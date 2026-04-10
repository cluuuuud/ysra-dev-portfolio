import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/database_helper.dart';

class StudentsListScreen extends StatefulWidget {
  @override
  _StudentsListScreenState createState() => _StudentsListScreenState();
}

class _StudentsListScreenState extends State<StudentsListScreen> {
  List<Map<String, dynamic>> students = [];

  @override
  void initState() {
    super.initState();
    loadStudents();
  }

  Future<void> loadStudents() async {
    final data = await DatabaseHelper.instance.getStudents();
    setState(() {
      students = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text("Students", style: GoogleFonts.poppins()),
      ),
      body: students.isEmpty
          ? Center(
              child: Text("No Students", style: TextStyle(color: Colors.white)),
            )
          : ListView.builder(
              itemCount: students.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    students[index]['name'],
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    "ID: ${students[index]['studentId'] ?? ''}",
                    style: TextStyle(color: Colors.white54),
                  ),
                );
              },
            ),
    );
  }
}
