import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:attendance_app/database/db_helper.dart';
import 'package:attendance_app/app_colors.dart';
import 'package:attendance_app/screens/attendance_flow_screen.dart';

class TodaySessionsScreen extends StatefulWidget {
  const TodaySessionsScreen({super.key});

  @override
  State<TodaySessionsScreen> createState() => _TodaySessionsScreenState();
}

class _TodaySessionsScreenState extends State<TodaySessionsScreen> {
  List<Map<String, dynamic>> _sessions = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final d = await DBHelper.getTodaySessions();
      setState(() {
        _sessions = d;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  void _open(Map<String, dynamic> s) {
    final cid = DBHelper.parseId(s['class_id']);
    final sid = DBHelper.parseId(s['session_id']);
    final name = (s['class_name'] ?? 'Class').toString();
    if (cid == null || sid == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Cannot open: missing ids')));
      return;
    }
    if (s['session_status'] == 'Completed') return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            AttendanceFlowScreen(classId: cid, className: name, sessionId: sid),
      ),
    ).then((_) => _load());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        title: Text(
          "Today's Sessions",
          style: GoogleFonts.lexend(fontWeight: FontWeight.bold),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _sessions.length,
              itemBuilder: (_, i) {
                final s = _sessions[i];
                final done = s['session_status'] == 'Completed';
                return Card(
                  child: ListTile(
                    title: Text(
                      '${s['class_name']} · ${s['start_time']}',
                      style: GoogleFonts.lexend(),
                    ),
                    subtitle: Text('${s['session_status']}'),
                    trailing: done ? null : const Icon(Icons.play_arrow),
                    onTap: () => _open(s),
                  ),
                );
              },
            ),
    );
  }
}
