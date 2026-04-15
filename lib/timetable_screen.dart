import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Session {
  final String day;
  final String time;
  final String subject;

  Session({required this.day, required this.time, required this.subject});
}

class TimetableScreen extends StatelessWidget {
  const TimetableScreen({super.key});

  final List<String> days = const ["Mon", "Tue", "Wed", "Thu", "Fri"];

  final List<String> times = const [
    "08:00 - 09:30",
    "09:30 - 11:00",
    "11:00 - 12:30",
    "13:00 - 14:30",
    "14:30 - 16:00",
    "16:00 - 17:30",
  ];

  final List<Session> sessions = const [
    Session(day: "Mon", time: "08:00 - 09:30", subject: "Algorithms"),
    Session(day: "Mon", time: "09:30 - 11:00", subject: "Data Structures"),
    Session(day: "Tue", time: "08:00 - 09:30", subject: "Operating Systems"),
    Session(day: "Wed", time: "11:00 - 12:30", subject: "Databases"),
    Session(day: "Thu", time: "13:00 - 14:30", subject: "Networks"),
    Session(day: "Fri", time: "14:30 - 16:00", subject: "AI"),
  ];

  Session? getSession(String day, String time) {
    try {
      return sessions.firstWhere((s) => s.day == day && s.time == time);
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Timetable",
          style: GoogleFonts.poppins(color: Colors.white),
        ),
      ),

      body: Column(
        children: [
          // Header (days)
          Row(
            children: [
              const SizedBox(width: 80),
              ...days.map(
                (day) => Expanded(
                  child: Center(
                    child: Text(
                      day,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Grid
          Expanded(
            child: ListView.builder(
              itemCount: times.length,
              itemBuilder: (context, index) {
                final time = times[index];

                return Row(
                  children: [
                    // time column
                    SizedBox(
                      width: 80,
                      child: Text(
                        time,
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 11,
                        ),
                      ),
                    ),

                    // cells
                    ...days.map((day) {
                      final session = getSession(day, time);

                      return Expanded(
                        child: GestureDetector(
                          onTap: session == null
                              ? null
                              : () => _openAttendance(context, session),
                          child: Container(
                            height: 70,
                            margin: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: session != null
                                  ? Colors.blueAccent.withOpacity(0.2)
                                  : Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                session?.subject ?? "",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // 🔥 Bottom Sheet (Attendance مباشرة)
  void _openAttendance(BuildContext context, Session session) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      isScrollControlled: true,
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                session.subject,
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),

              const SizedBox(height: 20),

              _studentRow("Ahmed"),
              _studentRow("Sara"),
              _studentRow("Yacine"),

              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _studentRow(String name) {
    String status = "Present";

    return StatefulBuilder(
      builder: (context, setState) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 5),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(name, style: const TextStyle(color: Colors.white)),
              ),

              DropdownButton<String>(
                value: status,
                dropdownColor: const Color(0xFF1A1A2E),
                items: ["Present", "Absent", "Late"]
                    .map(
                      (e) => DropdownMenuItem(
                        value: e,
                        child: Text(
                          e,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (val) {
                  setState(() => status = val!);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
