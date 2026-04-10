import '../services/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AddStudentScreen extends StatefulWidget {
  const AddStudentScreen({super.key});

  @override
  State<AddStudentScreen> createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  final TextEditingController _nameController = TextEditingController();
  int? _selectedGroupId;

  final List<Map<String, dynamic>> groups = [
    {'id': 1, 'name': 'L3-SI-G1'},
    {'id': 2, 'name': 'L3-SI-G2'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),

      appBar: AppBar(
        title: Text("Add New Student", style: GoogleFonts.poppins()),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),

      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration("Full Name", Icons.person_add),
            ),

            const SizedBox(height: 20),

            DropdownButtonFormField<int>(
              dropdownColor: const Color(0xFF16213E),
              value: _selectedGroupId,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration("Select Group", Icons.group),
              items: groups.map((g) {
                return DropdownMenuItem<int>(
                  value: g['id'],
                  child: Text(g['name']),
                );
              }).toList(),
              onChanged: (val) => setState(() => _selectedGroupId = val),
            ),

            const SizedBox(height: 40),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 55),
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onPressed: _saveStudent,
              child: const Text(
                "SAVE STUDENT",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔥 هنا التغيير الحقيقي (Database)
  void _saveStudent() async {
    if (_nameController.text.isNotEmpty && _selectedGroupId != null) {
      await DatabaseHelper.instance.insertStudent({
        'name': _nameController.text,
        'studentId': _selectedGroupId.toString(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Student ${_nameController.text} Added!")),
      );

      Navigator.pop(context);
    }
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: Colors.blueAccent),
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white30),
      filled: true,
      fillColor: Colors.white.withOpacity(0.05),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
    );
  }
}
