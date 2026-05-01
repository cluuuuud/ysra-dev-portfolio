import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'database/db_helper.dart';

class AppColors {
  static const bg = Color(0xFFF7F8FA);
  static const card = Colors.white;

  static const primary = Color(0xFF6366F1);
  static const primaryLight = Color(0xFFE0E7FF);

  static const success = Color(0xFF22C55E);
  static const warning = Color(0xFFF59E0B);
  static const danger = Color(0xFFEF4444);

  static const textMain = Color(0xFF111827);
  static const textMuted = Color(0xFF6B7280);
  static const border = Color(0xFFE5E7EB);
}

class AttendanceRecordScreen extends StatefulWidget {
  final int classId;
  final String className;

  const AttendanceRecordScreen({
    super.key,
    required this.classId,
    required this.className,
  });

  @override
  State<AttendanceRecordScreen> createState() => _AttendanceRecordScreenState();
}

class _AttendanceRecordScreenState extends State<AttendanceRecordScreen> {
  List<Map<String, dynamic>> students = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadStudents();
  }

  Future<void> loadStudents() async {
    try {
      final data = await DBHelper.getStudentsByClass(widget.classId);

      students = data
          .map<Map<String, dynamic>>((s) => {...s, "status": "Present"})
          .toList();

      setState(() => loading = false);
    } catch (e) {
      setState(() => loading = false);
    }
  }

  Future<void> _autoSave() async {
    try {
      final sessionId = await DBHelper.insertSession(widget.classId);
      await DBHelper.insertAttendance(sessionId, students);
    } catch (_) {}
  }

  void _cycleStatus(Map s) {
    const order = ["Present", "Late", "Absent"];

    int index = order.indexOf(s["status"]);
    index = (index + 1) % order.length;

    setState(() {
      s["status"] = order[index];
    });

    _autoSave();
    _showToast(s["status"]);
  }

  void _showToast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        duration: const Duration(milliseconds: 500),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.textMain,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (students.isEmpty) {
      return const Scaffold(body: Center(child: Text("No students yet")));
    }

    return Scaffold(
      backgroundColor: AppColors.bg,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          widget.className,
          style: GoogleFonts.lexend(
            color: AppColors.textMain,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Column(
        children: [
          _buildHeader(),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: students.length,
              itemBuilder: (context, index) {
                final s = students[index];

                return Dismissible(
                  key: Key(s["student_id"].toString()),

                  background: _swipeBg(
                    AppColors.success,
                    Icons.check,
                    "Present",
                  ),
                  secondaryBackground: _swipeBg(
                    AppColors.danger,
                    Icons.close,
                    "Absent",
                  ),

                  onDismissed: (direction) {
                    setState(() {
                      s["status"] = direction == DismissDirection.startToEnd
                          ? "Present"
                          : "Absent";
                    });

                    _autoSave();
                  },

                  child: _studentCard(s),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ================= HEADER =================

  Widget _buildHeader() {
    int present = students.where((s) => s["status"] == "Present").length;
    int late = students.where((s) => s["status"] == "Late").length;
    int absent = students.where((s) => s["status"] == "Absent").length;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Today Overview",
            style: GoogleFonts.lexend(
              fontWeight: FontWeight.bold,
              color: AppColors.textMain,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _statBox("Present", present, AppColors.success),
              _statBox("Late", late, AppColors.warning),
              _statBox("Absent", absent, AppColors.danger),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statBox(String title, int value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            value.toString(),
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          ),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  // ================= CARD =================

  Widget _studentCard(Map<String, dynamic> s) {
    return GestureDetector(
      onTap: () => _cycleStatus(s),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primaryLight,
              child: Text(
                s["student_name"][0],
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s["student_name"],
                    style: GoogleFonts.lexend(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMain,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Tap to change status",
                    style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),

            _statusBadge(s["status"]),
          ],
        ),
      ),
    );
  }

  Widget _statusBadge(String status) {
    Color color;

    switch (status) {
      case "Present":
        color = AppColors.success;
        break;
      case "Late":
        color = AppColors.warning;
        break;
      case "Absent":
        color = AppColors.danger;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  // ================= SWIPE =================

  Widget _swipeBg(Color color, IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      alignment: Alignment.centerLeft,
      color: color.withOpacity(0.15),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 8),
          Text(text, style: TextStyle(color: color)),
        ],
      ),
    );
  }
}
