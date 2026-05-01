import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'database/db_helper.dart';
import 'attendance_record_screen.dart';

class ClassListScreen extends StatefulWidget {
  const ClassListScreen({super.key});

  static const Color bg = Color(0xFFF5F7FA);
  static const Color cardBg = Colors.white;
  static const Color border = Color(0xFFE6EAF0);
  static const Color primary = Color(0xFF2563EB);

  static const Color textMain = Color(0xFF0B1220);
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
    final data = await DBHelper.getClasses();

    setState(() {
      classes = data;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: ClassListScreen.bg,

      appBar: AppBar(
        backgroundColor: ClassListScreen.bg,
        elevation: 0,
        iconTheme: const IconThemeData(color: ClassListScreen.textMain),
        title: Text(
          "Classes",
          style: GoogleFonts.lexend(
            color: ClassListScreen.textMain,
            fontWeight: FontWeight.w700, // 🔥 نفس القديم
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView.builder(
          itemCount: classes.length,
          itemBuilder: (context, index) {
            final c = classes[index];

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AttendanceRecordScreen(
                      classId: c["class_id"],
                      className: c["class_name"],
                    ),
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(18), // 🔥 كان 18 مشي 16
                decoration: BoxDecoration(
                  color: ClassListScreen.cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: ClassListScreen.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // 📘 ICON (نفس Attendance)
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: ClassListScreen.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.menu_book_rounded, // 🔥 نفس الأيقونة
                        color: ClassListScreen.primary,
                        size: 20,
                      ),
                    ),

                    const SizedBox(width: 15),

                    // 📄 TEXT
                    Expanded(
                      child: Text(
                        c["class_name"],
                        style: GoogleFonts.lexend(
                          fontWeight: FontWeight.w600,
                          color: ClassListScreen.textMain,
                        ),
                      ),
                    ),

                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),

      // ➕ ADD CLASS
      floatingActionButton: FloatingActionButton(
        backgroundColor: ClassListScreen.primary,
        onPressed: _openAddClass,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _openAddClass() {
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
