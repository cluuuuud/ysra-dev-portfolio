import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'database/db_helper.dart';
import 'student_screen.dart';
import 'attendance_record_screen.dart';

class ClassListScreen extends StatefulWidget {
  const ClassListScreen({super.key});

  static const Color bg = Color(0xFFF8FAFC);
  static const Color cardBg = Colors.white;
  static const Color border = Color(0xFFE5E7EB);
  static const Color primary = Color(0xFF3B82F6);
  static const Color textMain = Color(0xFF111827);
  static const Color textMuted = Color(0xFF6B7280);

  @override
  State<ClassListScreen> createState() => _ClassListScreenState();
}

class _ClassListScreenState extends State<ClassListScreen> {
  List classes = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadClasses();
  }

  Future<void> loadClasses() async {
    try {
      final data = await DBHelper.getClasses();

      setState(() {
        classes = data;
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

    if (classes.isEmpty) {
      return const Scaffold(body: Center(child: Text("No classes found")));
    }

    return Scaffold(
      backgroundColor: ClassListScreen.bg,

      appBar: AppBar(
        backgroundColor: ClassListScreen.bg,
        elevation: 0,
        title: Text(
          "Classes",
          style: GoogleFonts.lexend(
            color: ClassListScreen.textMain,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: classes.length,
        itemBuilder: (context, index) {
          final c = classes[index];

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ClassListScreen.cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: ClassListScreen.border),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: ClassListScreen.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.class_,
                    color: ClassListScreen.primary,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        c["class_name"],
                        style: GoogleFonts.lexend(
                          fontWeight: FontWeight.w600,
                          color: ClassListScreen.textMain,
                        ),
                      ),
                      Text(
                        "ID: ${c["class_id"]}",
                        style: GoogleFonts.lexend(
                          fontSize: 12,
                          color: ClassListScreen.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),

                // 👇 ACTIONS
                PopupMenuButton(
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: "students",
                      child: Text("Students"),
                    ),
                    const PopupMenuItem(
                      value: "attendance",
                      child: Text("Attendance"),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == "students") {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => StudentsScreen(
                            classId: c["class_id"],
                            className: c["class_name"],
                          ),
                        ),
                      );
                    }

                    if (value == "attendance") {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AttendanceRecordScreen(
                            classId: c["class_id"],
                            className: c["class_name"],
                          ),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),

      // ➕ ADD CLASS
      floatingActionButton: FloatingActionButton(
        backgroundColor: ClassListScreen.primary,
        onPressed: _addClass,
        child: const Icon(Icons.add),
      ),
    );
  }

  // =========================
  // ➕ ADD CLASS
  // =========================
  void _addClass() {
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
                "Add Class",
                style: GoogleFonts.lexend(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: controller,
                decoration: const InputDecoration(labelText: "Class Name"),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () async {
                  if (controller.text.isEmpty) return;

                  await DBHelper.insertClass(controller.text);

                  Navigator.pop(context);
                  loadClasses();
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
