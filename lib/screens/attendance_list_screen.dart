import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:attendance_app/database/db_helper.dart';
import 'package:attendance_app/app_colors.dart';
import 'package:attendance_app/screens/attendance_flow_screen.dart';

class AttendanceListScreen extends StatefulWidget {
  final int? preselectedClassId;
  final int? preselectedSessionId;
  final String? preselectedClassName;

  const AttendanceListScreen({
    super.key,
    this.preselectedClassId,
    this.preselectedSessionId,
    this.preselectedClassName,
  });

  @override
  State<AttendanceListScreen> createState() => _AttendanceListScreenState();
}

class _AttendanceListScreenState extends State<AttendanceListScreen> {
  List<Map<String, dynamic>> _todaySessions = [];
  List<Map<String, dynamic>> _allClasses = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final today = await DBHelper.getTodaySessions();
      final classes = await DBHelper.getClasses();
      setState(() {
        _todaySessions = today;
        _allClasses = classes;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  void _openFlow({
    required int classId,
    required String className,
    required int sessionId,
  }) {
    Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => AttendanceFlowScreen(
          classId: classId,
          className: className,
          sessionId: sessionId,
        ),
      ),
    ).then((result) {
      _load();
      if (!mounted) return;
      final m = ScaffoldMessenger.of(context);
      if (result == AttendanceFlowScreen.popCompleted) {
        m.showSnackBar(SnackBar(content: Text('Session completed.', style: GoogleFonts.lexend())));
      } else if (result == AttendanceFlowScreen.popSavedExit) {
        m.showSnackBar(SnackBar(content: Text('Attendance saved.', style: GoogleFonts.lexend())));
      }
    });
  }

  Future<void> _offerTodaySession(Map<String, dynamic> s) async {
    final subject = '${s['subject_shortname'] ?? s['subject_name'] ?? 'Session'}';
    final clsName = s['class_name'] as String? ?? '';
    final start = s['start_time'] as String? ?? '';
    final end = s['end_time'] as String? ?? '';
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(subject, style: GoogleFonts.lexend(fontWeight: FontWeight.bold, fontSize: 18)),
            Text(clsName, style: GoogleFonts.lexend(color: AppColors.textSub)),
            Text('$start – $end', style: GoogleFonts.lexend(color: AppColors.textMuted, fontSize: 13)),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                final cid = DBHelper.parseId(s['class_id']);
                final sid = DBHelper.parseId(s['session_id']);
                if (cid == null || sid == null) return;
                _openFlow(classId: cid, className: clsName.isEmpty ? 'Class' : clsName, sessionId: sid);
              },
              child: const Text('Open attendance'),
            ),
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ],
        ),
      ),
    );
  }

  Future<void> _offerNewSessionForClass(Map<String, dynamic> cls) async {
    final cid = DBHelper.parseId(cls['class_id']);
    if (cid == null) return;
    final slots = await DBHelper.getTimetableSlotsForClassToday(cid);
    if (!mounted) return;
    if (slots.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No timetable for ${cls['class_name']} today', style: GoogleFonts.lexend())),
      );
      return;
    }
    Map<String, dynamic> pick() {
      final now = DBHelper.sqlLocalTime();
      for (final s in slots) {
        final st = (s['start_time'] as String?) ?? '';
        final en = (s['end_time'] as String?) ?? '';
        if (st.isNotEmpty && en.isNotEmpty && now.compareTo(st) >= 0 && now.compareTo(en) < 0) return s;
      }
      for (final s in slots) {
        final st = (s['start_time'] as String?) ?? '';
        if (st.isNotEmpty && now.compareTo(st) < 0) return s;
      }
      return slots.last;
    }

    final slot = pick();
    final tid = DBHelper.parseId(slot['timetable_id']);
    final start = slot['start_time'] as String?;
    if (tid == null || start == null) return;
    final name = cls['class_name'] as String? ?? 'Class';
    final sessionId = await DBHelper.getOrCreateSession(timetableId: tid, startTime: start);
    if (!mounted) return;
    _openFlow(classId: cid, className: name, sessionId: sessionId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        title: Text('Take Attendance', style: GoogleFonts.lexend(fontWeight: FontWeight.bold)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  if (_todaySessions.isNotEmpty) ...[
                    Text("Today's Sessions", style: GoogleFonts.lexend(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ..._todaySessions.map(
                      (s) => Card(
                        child: ListTile(
                          title: Text(
                            '${s['subject_shortname'] ?? s['subject_name']} — ${s['class_name']}',
                            style: GoogleFonts.lexend(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text('${s['start_time']} · ${s['session_status']}'),
                          onTap: () => _offerTodaySession(s),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  Text('All Classes', style: GoogleFonts.lexend(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ..._allClasses.map(
                    (c) => Card(
                      child: ListTile(
                        title: Text(c['class_name']?.toString() ?? '', style: GoogleFonts.lexend()),
                        onTap: () => _offerNewSessionForClass(c),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
