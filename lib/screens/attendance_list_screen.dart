import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:attendance_app/database/db_helper.dart';
import 'package:attendance_app/app_colors.dart';
import 'package:attendance_app/screens/attendance_flow_screen.dart';

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
  List<Map<String, dynamic>> _todaySlots = [];
  List<Map<String, dynamic>> _todaySessions = [];
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
        DBHelper.getTodayTimetableSlots(),
        DBHelper.getTodaySessions(),
      ]);
      setState(() {
        _todaySlots = results[0] as List<Map<String, dynamic>>;
        _todaySessions = results[1] as List<Map<String, dynamic>>;
        _loading = false;
      });

      if (widget.preselectedClassId != null &&
          widget.preselectedSessionId != null &&
          mounted) {
        _openFlow(
          classId: widget.preselectedClassId!,
          className: '',
          sessionId: widget.preselectedSessionId!,
        );
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

  // ── الأستاذ ضغط على حصة ──────────────────────────────────────────────────
  Future<void> _onSlotTap(Map<String, dynamic> slot) async {
    final subjectId = slot['subject_id'] as int?;
    final dayOfWeek = slot['day_of_week'] as String?;
    final startTime = slot['start_time'] as String?;
    final timetableId = slot['timetable_id'] as int?;

    if (subjectId == null ||
        dayOfWeek == null ||
        startTime == null ||
        timetableId == null)
      return;

    final classes = await DBHelper.getClassesForSlot(
      subjectId: subjectId,
      dayOfWeek: dayOfWeek,
      startTime: startTime,
    );

    if (!mounted) return;

    if (classes.isEmpty) {
      _showSnack('No classes found for this slot', isError: true);
      return;
    }

    if (classes.length == 1) {
      await _handleClassTap(classes.first, slot);
    } else {
      _showClassPicker(classes, slot);
    }
  }

  // ── بعد اختيار القروب: هل في جلسة مسجّلة مسبقاً؟ ───────────────────────
  Future<void> _handleClassTap(
    Map<String, dynamic> cls,
    Map<String, dynamic> slot,
  ) async {
    final timetableId = cls['timetable_id'] as int?;
    final classId = cls['class_id'] as int?;
    final className = cls['class_name'] as String? ?? 'Class';
    final startTime = cls['start_time'] as String? ?? '00:00';

    if (timetableId == null || classId == null) {
      _showSnack('Missing session data', isError: true);
      return;
    }

    // هل في جلسة مكتملة اليوم لهذا الـ timetable؟
    final existingSession = _todaySessions
        .where(
          (s) =>
              s['timetable_id'] == timetableId &&
              s['session_status'] == 'Completed',
        )
        .toList();

    if (existingSession.isNotEmpty && mounted) {
      // ✅ الملاحظة الأولى: اعرض Dialog للاختيار
      final sid = existingSession.first['session_id'] is int
          ? existingSession.first['session_id'] as int
          : int.tryParse(existingSession.first['session_id'].toString());

      final choice = await _showSessionChoiceDialog(className);

      if (!mounted || choice == null) return;

      if (choice == 'view') {
        // عرض التسجيل السابق
        _openFlow(classId: classId, className: className, sessionId: sid!);
      } else {
        // جلسة جديدة
        await _createAndOpen(
          timetableId: timetableId,
          classId: classId,
          className: className,
          startTime: startTime,
          forceNew: true,
        );
      }
    } else {
      // لا يوجد جلسة مسجّلة → أنشئ مباشرة
      await _createAndOpen(
        timetableId: timetableId,
        classId: classId,
        className: className,
        startTime: startTime,
        forceNew: false,
      );
    }
  }

  // ── Dialog: عرض السابق أم جلسة جديدة؟ ───────────────────────────────────
  Future<String?> _showSessionChoiceDialog(String className) {
    return showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          className,
          style: GoogleFonts.lexend(
            fontWeight: FontWeight.bold,
            color: AppColors.textMain,
          ),
        ),
        content: Text(
          'A session was already recorded for this class today.',
          style: GoogleFonts.lexend(color: AppColors.textMuted, fontSize: 13),
        ),
        actions: [
          // عرض التسجيل السابق
          OutlinedButton.icon(
            onPressed: () => Navigator.pop(context, 'view'),
            icon: const Icon(
              Icons.visibility_outlined,
              color: AppColors.primary,
              size: 18,
            ),
            label: Text(
              'View previous',
              style: GoogleFonts.lexend(color: AppColors.primary),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          // جلسة جديدة
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context, 'new'),
            icon: const Icon(Icons.add, color: Colors.white, size: 18),
            label: Text(
              'New session',
              style: GoogleFonts.lexend(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── إنشاء جلسة وفتح الحضور ───────────────────────────────────────────────
  Future<void> _createAndOpen({
    required int timetableId,
    required int classId,
    required String className,
    required String startTime,
    required bool forceNew,
  }) async {
    try {
      int sessionId;

      if (forceNew) {
        // إنشاء جلسة جديدة دائماً
        final d = await DBHelper.db;
        final now = DateTime.now();
        final dateStr =
            "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
        sessionId = await d.insert("Sessions", {
          "timetable_id": timetableId,
          "session_date": dateStr,
          "start_time": startTime,
          "status": "Scheduled",
        });
      } else {
        sessionId = await DBHelper.getOrCreateSession(
          timetableId: timetableId,
          startTime: startTime,
        );
      }

      _openFlow(classId: classId, className: className, sessionId: sessionId);
    } catch (e) {
      _showSnack('Error: $e', isError: true);
    }
  }

  // ── Bottom Sheet: اختيار القروب ───────────────────────────────────────────
  void _showClassPicker(
    List<Map<String, dynamic>> classes,
    Map<String, dynamic> slot,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    slot['subject_shortname'] ?? '—',
                    style: GoogleFonts.lexend(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${slot['start_time']} – ${slot['end_time']}',
                  style: GoogleFonts.lexend(
                    color: AppColors.textMuted,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Select a group',
              style: GoogleFonts.lexend(
                fontWeight: FontWeight.bold,
                color: AppColors.textMain,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            ...classes.map((cls) {
              final count = (cls['student_count'] as int?) ?? 0;
              return GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  _handleClassTap(cls, slot);
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.bg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.primaryBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            (cls['class_name'] as String? ?? '?')
                                .substring(0, 1)
                                .toUpperCase(),
                            style: GoogleFonts.lexend(
                              color: AppColors.primary,
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
                              cls['class_name'] ?? '—',
                              style: GoogleFonts.lexend(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textMain,
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              '$count students  ·  ${cls['session_type'] ?? ''}',
                              style: GoogleFonts.lexend(
                                color: AppColors.textMuted,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.play_arrow_outlined,
                        color: AppColors.primary,
                        size: 22,
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.lexend()),
        backgroundColor: isError ? AppColors.danger : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  BUILD
  // ══════════════════════════════════════════════════════════════════════════
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
                  if (_todaySlots.isEmpty)
                    _emptyState()
                  else ...[
                    _sectionLabel("Today's Schedule", Icons.today_outlined),
                    const SizedBox(height: 10),
                    ..._todaySlots.map(_slotCard),
                  ],

                  if (_todaySessions
                      .where((s) => s['session_status'] == 'Completed')
                      .isNotEmpty) ...[
                    const SizedBox(height: 28),
                    _sectionLabel("Recorded Today", Icons.check_circle_outline),
                    const SizedBox(height: 10),
                    ..._todaySessions
                        .where((s) => s['session_status'] == 'Completed')
                        .map(_completedCard),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _slotCard(Map<String, dynamic> slot) {
    final timetableId = slot['timetable_id'] as int?;
    final isRecorded = _todaySessions.any(
      (s) =>
          s['timetable_id'] == timetableId &&
          s['session_status'] == 'Completed',
    );
    final type = slot['session_type'] as String? ?? '';

    return GestureDetector(
      onTap: () => _onSlotTap(slot),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isRecorded
                ? AppColors.border
                : AppColors.primary.withOpacity(0.3),
            width: isRecorded ? 1 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: isRecorded ? AppColors.success : AppColors.primary,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            slot['start_time'] ?? '',
                            style: GoogleFonts.lexend(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textMain,
                              fontSize: 13,
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 12,
                            color: AppColors.border,
                            margin: const EdgeInsets.symmetric(vertical: 2),
                          ),
                          Text(
                            slot['end_time'] ?? '',
                            style: GoogleFonts.lexend(
                              color: AppColors.textMuted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              slot['subject_shortname'] ??
                                  slot['subject_name'] ??
                                  '—',
                              style: GoogleFonts.lexend(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textMain,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                if (slot['room_name'] != null) ...[
                                  const Icon(
                                    Icons.room_outlined,
                                    size: 12,
                                    color: AppColors.textMuted,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    slot['room_name'],
                                    style: GoogleFonts.lexend(
                                      color: AppColors.textMuted,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                ],
                                _typePill(type),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        isRecorded
                            ? Icons.check_circle
                            : Icons.play_circle_outline,
                        color: isRecorded
                            ? AppColors.success
                            : AppColors.primary,
                        size: 26,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _completedCard(Map<String, dynamic> s) {
    final present = (s['students_present'] as int?) ?? 0;
    final recorded = (s['students_recorded'] as int?) ?? 0;
    final pct = recorded > 0 ? present / recorded : 0.0;
    final classId = s['class_id'] is int
        ? s['class_id'] as int
        : int.tryParse(s['class_id'].toString());
    final sessionId = s['session_id'] is int
        ? s['session_id'] as int
        : int.tryParse(s['session_id'].toString());

    return GestureDetector(
      onTap: () {
        if (classId == null || sessionId == null) return;
        _openFlow(
          classId: classId,
          className: s['class_name'] as String? ?? 'Class',
          sessionId: sessionId,
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.successBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.check_circle,
                color: AppColors.success,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${s['subject_shortname'] ?? '—'}  ·  ${s['class_name'] ?? '—'}',
                    style: GoogleFonts.lexend(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMain,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: pct,
                      minHeight: 4,
                      backgroundColor: AppColors.border,
                      valueColor: const AlwaysStoppedAnimation(
                        AppColors.success,
                      ),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '$present / $recorded present',
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

  Widget _emptyState() => Padding(
    padding: const EdgeInsets.symmetric(vertical: 60),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.event_busy_outlined,
          size: 56,
          color: AppColors.textMuted.withOpacity(0.4),
        ),
        const SizedBox(height: 16),
        Text(
          'No sessions scheduled today',
          style: GoogleFonts.lexend(color: AppColors.textMuted, fontSize: 15),
        ),
        const SizedBox(height: 6),
        Text(
          'Check the timetable for upcoming sessions',
          style: GoogleFonts.lexend(color: AppColors.textMuted, fontSize: 12),
        ),
      ],
    ),
  );

  Widget _sectionLabel(String text, IconData icon) => Row(
    children: [
      Icon(icon, size: 15, color: AppColors.textMuted),
      const SizedBox(width: 6),
      Text(
        text,
        style: GoogleFonts.lexend(
          fontWeight: FontWeight.bold,
          color: AppColors.textMain,
          fontSize: 14,
        ),
      ),
    ],
  );

  Widget _typePill(String type) {
    Color color, bg;
    switch (type) {
      case 'TD':
        color = AppColors.primary;
        bg = AppColors.primaryBg;
        break;
      case 'TP':
        color = AppColors.success;
        bg = AppColors.successBg;
        break;
      case 'Lecture':
        color = AppColors.warning;
        bg = AppColors.warningBg;
        break;
      default:
        color = AppColors.textMuted;
        bg = AppColors.divider;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        type,
        style: GoogleFonts.lexend(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }
}
