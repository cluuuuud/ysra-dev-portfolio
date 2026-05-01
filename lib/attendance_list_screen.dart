import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'database/db_helper.dart';
import 'attendance_record_screen.dart';

class AttendanceListScreen extends StatefulWidget {
  const AttendanceListScreen({super.key});

  // 🎨 PRO STYLE (كما كان)
  static const Color primary = Color(0xFF2563EB);
  static const Color bg = Color(0xFFF5F7FA);
  static const Color cardBg = Colors.white;
  static const Color border = Color(0xFFE6EAF0);

  static const Color textMain = Color(0xFF0B1220);
  static const Color textMuted = Color(0xFF6B7280);

  @override
  State<AttendanceListScreen> createState() => _AttendanceListScreenState();
}

class _AttendanceListScreenState extends State<AttendanceListScreen> {
  List<Map<String, dynamic>> classes = [];
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
      print("ERROR LOADING CLASSES ❌");
      print(e);
      loading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AttendanceListScreen.bg,

      appBar: AppBar(
        backgroundColor: AttendanceListScreen.bg,
        elevation: 0,
        iconTheme: const IconThemeData(color: AttendanceListScreen.textMain),
        title: Text(
          "Classes",
          style: GoogleFonts.lexend(
            color: AttendanceListScreen.textMain,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: classes.isEmpty
            ? const Center(child: Text("No classes 😴"))
            : ListView.builder(
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
                      padding: const EdgeInsets.all(18),

                      decoration: BoxDecoration(
                        color: AttendanceListScreen.cardBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AttendanceListScreen.border),
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
                          // 📘 ICON (رجعناه كيما قبل)
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AttendanceListScreen.primary.withOpacity(
                                0.08,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.menu_book_rounded,
                              color: AttendanceListScreen.primary,
                              size: 20,
                            ),
                          ),

                          const SizedBox(width: 15),

                          // 📄 CLASS NAME
                          Expanded(
                            child: Text(
                              c["class_name"] ?? "",
                              style: GoogleFonts.lexend(
                                fontWeight: FontWeight.w600,
                                color: AttendanceListScreen.textMain,
                              ),
                            ),
                          ),

                          // ➡️ ARROW
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
    );
  }
}
