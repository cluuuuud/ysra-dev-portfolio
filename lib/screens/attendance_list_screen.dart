import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../database/db_helper.dart';
import '../app_colors.dart';
import 'attendance_flow_screen.dart';

class AttendanceListScreen extends StatefulWidget {
  final int? preselectedClassId;
  final int? preselectedSessionId;

  const AttendanceListScreen({
    super.key,
    this.preselectedClassId,
    this.preselectedSessionId,
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
      final results = await Future.wait([
        DBHelper.getTodaySessions(),
        DBHelper.getClasses(),
      ]);
      setState(() {
        _todaySessions = results[0] as List<Map<String, dynamic>>;
        _allClasses = results[1] as List<Map<String, dynamic>>;
        _loading = false;
      });

      // Auto-navigate إذا جاء من Dashboard
      if (widget.preselectedClassId != null &&
          widget.preselectedSessionId != null) {
        final cls = _allClasses.firstWhere(
          (c) => c['class_id'] == widget.preselectedClassId,
          orElse: () => {},
        );
        if (cls.isNotEmpty && mounted) {
          _openFlow(
            classId: widget.preselectedClassId!,
            className: cls['class_name'] ?? 'Class',
            sessionId: widget.preselectedSessionId!,
          );
        }
      }
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  void _openFlow({
    required int classId,
    required String className,
    required int sessionId,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AttendanceFlowScreen(
          classId: classId,
          className: className,
          sessionId: sessionId,
        ),
      ),
    ).then((_) => _load());
  }

  Future<void> _startNewSession(Map<String, dynamic> cls) async {
    // نجيب timetable slot للقسم
    final schedule = await DBHelper.getWeeklySchedule();
    final slot = schedule.firstWhere(
      (s) => s['class_id'] == cls['class_id'],
      orElse: () => {},
    );

    if (slot.isEmpty) {
      _showError('No timetable slot found for ${cls['class_name']}');
      return;
    }

    final sessionId = await DBHelper.getOrCreateSession(
      timetableId: slot['timetable_id'] as int,
      startTime: slot['start_time'] as String,
    );

    _openFlow(
      classId: cls['class_id'] as int,
      className: cls['class_name'] as String,
      sessionId: sessionId,
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.danger),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textMain),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Take Attendance',
          style: GoogleFonts.lexend(
            color: AppColors.textMain,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : RefreshIndicator(
              onRefresh: _load,
              color: AppColors.primary,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // ── Today's Sessions ──
                  if (_todaySessions.isNotEmpty) ...[
                    _sectionLabel("Today's Sessions"),
                    const SizedBox(height: 10),
                    ..._todaySessions.map(_todayCard),
                    const SizedBox(height: 28),
                  ],

                  // ── All Classes ──
                  _sectionLabel("All Classes"),
                  const SizedBox(height: 10),
                  ..._allClasses.map(_classCard),
                ],
              ),
            ),
    );
  }

  Widget _todayCard(Map<String, dynamic> s) {
    final total = (s['students_recorded'] as int?) ?? 0;
    final isDone = s['session_status'] == 'Completed';
    final present = (s['students_present'] as int?) ?? 0;
    final pct = total > 0 ? present / total : 0.0;

    return GestureDetector(
      onTap: () => _openFlow(
        classId: s['class_id'] as int,
        className: s['class_name'] as String,
        sessionId: s['session_id'] as int,
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDone
                ? AppColors.border
                : AppColors.primary.withOpacity(0.4),
            width: isDone ? 1 : 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isDone ? AppColors.successBg : AppColors.primaryBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isDone ? Icons.check_circle : Icons.edit_note,
                color: isDone ? AppColors.success : AppColors.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${s['subject_shortname'] ?? s['subject_name']} — ${s['class_name']}',
                    style: GoogleFonts.lexend(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textMain,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: pct,
                      minHeight: 4,
                      backgroundColor: AppColors.border,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isDone ? AppColors.success : AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$present / $total recorded  ·  ${s['start_time']}',
                    style: GoogleFonts.lexend(
                      color: AppColors.textMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textMuted,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _classCard(Map<String, dynamic> cls) {
    final name = cls['class_name'] as String? ?? '?';
    return GestureDetector(
      onTap: () => _startNewSession(cls),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  name.substring(0, 1),
                  style: GoogleFonts.lexend(
                    color: AppColors.textSub,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.lexend(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textMain,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '${cls['unilevel'] ?? ''} · ${cls['academic_year'] ?? ''} · ${cls['session_type'] ?? ''}',
                    style: GoogleFonts.lexend(
                      color: AppColors.textMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.play_arrow_outlined,
              color: AppColors.primary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(
    text,
    style: GoogleFonts.lexend(
      fontWeight: FontWeight.bold,
      color: AppColors.textMain,
      fontSize: 14,
    ),
  );
}
