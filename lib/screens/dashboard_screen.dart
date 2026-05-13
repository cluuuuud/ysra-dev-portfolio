import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:attendance_app/database/db_helper.dart';
import 'package:attendance_app/app_colors.dart';
import 'package:attendance_app/screens/attendance_flow_screen.dart';
import 'package:attendance_app/screens/attendance_list_screen.dart';
import 'package:attendance_app/screens/timetable_screen.dart';
import 'package:attendance_app/screens/session_history_screen.dart';
import 'package:attendance_app/screens/management_screen.dart';
import 'package:attendance_app/screens/export_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Map<String, dynamic>> _today = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final t = await DBHelper.getTodaySessions();
      setState(() {
        _today = t;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  void _openSession(Map<String, dynamic> s) {
    final cid = DBHelper.parseId(s['class_id']);
    final sid = DBHelper.parseId(s['session_id']);
    final name = (s['class_name'] ?? 'Class').toString();
    if (cid == null || sid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Missing class or session id')),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AttendanceFlowScreen(classId: cid, className: name, sessionId: sid),
      ),
    ).then((_) => _load());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        title: Text('ATTENDIX', style: GoogleFonts.lexend(fontWeight: FontWeight.bold)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Text("Today's sessions", style: GoogleFonts.lexend(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  if (_today.isEmpty)
                    Text('No sessions today', style: GoogleFonts.lexend(color: AppColors.textMuted))
                  else
                    ..._today.map(
                      (s) => Card(
                        child: ListTile(
                          title: Text(
                            '${s['class_name']} · ${s['start_time']}',
                            style: GoogleFonts.lexend(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text('${s['session_status']}'),
                          onTap: () => _openSession(s),
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _btn('Timetable', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TimetableScreen()))),
                      _btn('Attendance', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AttendanceListScreen()))),
                      _btn('History', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SessionHistoryScreen()))),
                      _btn('Management', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ManagementScreen()))),
                      _btn('Import/Export', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ImportExportScreen()))),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _btn(String t, VoidCallback onTap) => ActionChip(
        label: Text(t, style: GoogleFonts.lexend()),
        onPressed: onTap,
      );
}
