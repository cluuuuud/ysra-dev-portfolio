import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'database/db_helper.dart';

class StudentsScreen extends StatefulWidget {
  final int classId;
  final String className;

  const StudentsScreen({
    super.key,
    required this.classId,
    required this.className,
  });

  static const Color bg = Color(0xFFF8FAFC);
  static const Color cardBg = Colors.white;
  static const Color border = Color(0xFFE5E7EB);
  static const Color primary = Color(0xFF3B82F6);
  static const Color textMain = Color(0xFF111827);
  static const Color textMuted = Color(0xFF6B7280);

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  List students = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadStudents();
  }

  Future<void> loadStudents() async {
    try {
      final data = await DBHelper.getStudentsByClass(widget.classId);

      setState(() {
        students = data;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: StudentsScreen.bg,

      appBar: AppBar(
        backgroundColor: StudentsScreen.bg,
        elevation: 0,
        title: Text(
          "Students - ${widget.className}",
          style: GoogleFonts.lexend(
            color: StudentsScreen.textMain,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: students.isEmpty
          ? const Center(child: Text("No students found"))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: students.length,
              itemBuilder: (context, index) {
                final s = students[index];

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: StudentsScreen.cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: StudentsScreen.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: StudentsScreen.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.person,
                          color: StudentsScreen.primary,
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Text(
                          s["student_name"],
                          style: GoogleFonts.lexend(
                            fontWeight: FontWeight.w600,
                            color: StudentsScreen.textMain,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

      // ➕ ADD STUDENT
      floatingActionButton: FloatingActionButton(
        backgroundColor: StudentsScreen.primary,
        onPressed: _addStudent,
        child: const Icon(Icons.add),
      ),
    );
  }

  // =========================
  // ➕ ADD STUDENT
  // =========================
  void _addStudent() {
    final controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Add Student",
                style: GoogleFonts.lexend(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: controller,
                decoration: const InputDecoration(labelText: "Student Name"),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () async {
                  if (controller.text.isEmpty) return;

                  await DBHelper.insertStudent(controller.text, widget.classId);

                  Navigator.pop(context);
                  loadStudents();
                },
                child: const Text("Save"),
              ),
            ],
          ),
        );
      },
    );
  }
}
