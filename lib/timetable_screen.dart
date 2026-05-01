import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'database/db_helper.dart';

class TimetableScreen extends StatefulWidget {
  const TimetableScreen({super.key});

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  List<Map<String, dynamic>> timetable = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadTimetable();
  }

  Future<void> loadTimetable() async {
    try {
      final data = await DBHelper.getTimetable();

      setState(() {
        timetable = data;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (timetable.isEmpty) {
      return const Scaffold(body: Center(child: Text("No timetable yet")));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Timetable")),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: timetable.length,
        itemBuilder: (context, index) {
          final t = timetable[index];

          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t["subject_name"],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  "${t["day_of_week"]} • ${t["start_time"]} - ${t["end_time"]}",
                  style: const TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 10),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    t["session_type"],
                    style: const TextStyle(fontSize: 12, color: Colors.blue),
                  ),
                ),
              ],
            ),
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _addTimetable,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _addTimetable() {
    final subject = TextEditingController();
    final day = TextEditingController();
    final start = TextEditingController();
    final end = TextEditingController();
    final type = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            left: 16,
            right: 16,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Add Timetable"),

              TextField(
                controller: subject,
                decoration: const InputDecoration(labelText: "Subject"),
              ),
              TextField(
                controller: day,
                decoration: const InputDecoration(labelText: "Day"),
              ),
              TextField(
                controller: start,
                decoration: const InputDecoration(labelText: "Start"),
              ),
              TextField(
                controller: end,
                decoration: const InputDecoration(labelText: "End"),
              ),
              TextField(
                controller: type,
                decoration: const InputDecoration(
                  labelText: "Type (TP/TD/Lecture)",
                ),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () async {
                  await DBHelper.insertTimetable(
                    subject: subject.text,
                    day: day.text,
                    start: start.text,
                    end: end.text,
                    type: type.text,
                  );

                  Navigator.pop(context);
                  loadTimetable();
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
