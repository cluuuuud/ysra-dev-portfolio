import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum Status { present, late, absent }

// 📦 GLOBAL SESSIONS LIST
List<Map<String, dynamic>> sessions = [];

// 👤 STUDENT MODEL
class Student {
  String name;
  String id;
  Status status;

  Student({required this.name, required this.id, this.status = Status.present});
}

class AttendanceRecordScreen extends StatefulWidget {
  final String className;

  const AttendanceRecordScreen({super.key, required this.className});

  @override
  State<AttendanceRecordScreen> createState() => _AttendanceRecordScreenState();
}

class _AttendanceRecordScreenState extends State<AttendanceRecordScreen> {
  // 🎨 COLORS
  static const Color primary = Color(0xFF3B82F6);
  static const Color bg = Color(0xFFF9FAFB);
  static const Color cardBg = Colors.white;
  static const Color border = Color(0xFFE5E7EB);

  static const Color textMain = Color(0xFF111827);
  static const Color textMuted = Color(0xFF6B7280);

  static const Color presentColor = Color(0xFF10B981);
  static const Color lateColor = Color(0xFFF59E0B);
  static const Color absentColor = Color(0xFFEF4444);

  List<Student> students = [
    Student(name: "Yousra", id: "2024IT1001"),
    Student(name: "Amine", id: "2024IT1002"),
    Student(name: "Asma", id: "2024IT1003"),
    Student(name: "Mohamed", id: "2024IT1004"),
  ];

  // 🔁 CHANGE STATUS
  void toggleStatus(int index) {
    setState(() {
      students[index].status = nextStatus(students[index].status);
    });
  }

  Status nextStatus(Status current) {
    switch (current) {
      case Status.present:
        return Status.late;
      case Status.late:
        return Status.absent;
      case Status.absent:
        return Status.present;
    }
  }

  // 📊 COUNT
  int count(Status s) => students.where((e) => e.status == s).length;

  Color getColor(Status status) {
    switch (status) {
      case Status.present:
        return presentColor;
      case Status.late:
        return lateColor;
      case Status.absent:
        return absentColor;
    }
  }

  String getText(Status status) {
    switch (status) {
      case Status.present:
        return "Present";
      case Status.late:
        return "Late";
      case Status.absent:
        return "Absent";
    }
  }

  void markAll(Status status) {
    setState(() {
      for (var s in students) {
        s.status = status;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    int present = count(Status.present);
    int late = count(Status.late);
    int absent = count(Status.absent);

    double progress = present / students.length;

    return Scaffold(
      backgroundColor: bg,

      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        iconTheme: const IconThemeData(color: textMain),
        title: Text(
          widget.className,
          style: GoogleFonts.lexend(
            color: textMain,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 📊 STATS
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _stat("Present", present, presentColor),
                  _stat("Late", late, lateColor),
                  _stat("Absent", absent, absentColor),
                ],
              ),
            ),

            const SizedBox(height: 15),

            // 📈 PROGRESS
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: border,
                color: primary,
                minHeight: 8,
              ),
            ),

            const SizedBox(height: 15),

            // ⚡ ACTIONS
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => markAll(Status.present),
                    child: const Text("All Present"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => markAll(Status.absent),
                    child: const Text("All Absent"),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 👥 LIST
            Expanded(
              child: ListView.builder(
                itemCount: students.length,
                itemBuilder: (context, index) {
                  final s = students[index];

                  return GestureDetector(
                    onTap: () => toggleStatus(index),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: border),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  s.name,
                                  style: GoogleFonts.lexend(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  s.id,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: getColor(s.status).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              getText(s.status),
                              style: TextStyle(
                                color: getColor(s.status),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // 🔘 HISTORY BUTTON
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/history');
                },
                child: const Text("View History"),
              ),
            ),

            const SizedBox(height: 10),

            // 💾 SAVE BUTTON
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  sessions.add({
                    "className": widget.className,
                    "date": DateTime.now().toString(),
                    "present": present,
                    "late": late,
                    "absent": absent,
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Session Saved ✅")),
                  );
                },
                child: const Text("SAVE SESSION"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stat(String title, int value, Color color) {
    return Column(
      children: [
        Text(
          "$value",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(title, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}
