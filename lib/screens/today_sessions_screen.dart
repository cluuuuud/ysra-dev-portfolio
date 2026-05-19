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
      final data = await DBHelper.getTodaySessions();
      setState(() {
        _sessions = data;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  // ── فتح شاشة تسجيل الحضور ────────────────────────────────────────────────
  void _openAttendance(Map<String, dynamic> s) {
    final classId = s['class_id'] is int
        ? s['class_id'] as int
        : int.tryParse(s['class_id'].toString());
    final sessionId = s['session_id'] is int
        ? s['session_id'] as int
        : int.tryParse(s['session_id'].toString());
    final className = (s['class_name'] ?? 'Class').toString();

    if (classId == null || sessionId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Cannot open: missing IDs')));
      return;
    }

    if (s['session_status'] == 'Completed') return;

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

  // ── Color helpers ─────────────────────────────────────────────────────────
  Color _statusColor(String? s) {
    switch (s) {
      case 'Completed':
        return AppColors.success;
      case 'Cancelled':
        return AppColors.danger;
      default:
        return AppColors.warning;
    }
  }

  Color _statusBg(String? s) {
    switch (s) {
      case 'Completed':
        return AppColors.successBg;
      case 'Cancelled':
        return AppColors.dangerBg;
      default:
        return AppColors.warningBg;
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────
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
          "Today's Sessions",
          style: GoogleFonts.lexend(
            color: AppColors.textMain,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textMuted),
            onPressed: _load,
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : RefreshIndicator(
              onRefresh: _load,
              color: AppColors.primary,
              child: _sessions.isEmpty
                  ? _emptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: _sessions.length,
                      itemBuilder: (_, i) => _sessionCard(_sessions[i]),
                    ),
            ),
    );
  }

  // ── Empty State ────────────────────────────────────────────────────────────
  Widget _emptyState() => Center(
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
          'No sessions today',
          style: GoogleFonts.lexend(color: AppColors.textMuted, fontSize: 16),
        ),
        const SizedBox(height: 6),
        Text(
          'Check the timetable for upcoming sessions',
          style: GoogleFonts.lexend(color: AppColors.textMuted, fontSize: 12),
        ),
      ],
    ),
  );

  // ── Session Card ───────────────────────────────────────────────────────────
  Widget _sessionCard(Map<String, dynamic> s) {
    final isDone = s['session_status'] == 'Completed';
    final present = (s['students_present'] as int?) ?? 0;
    final recorded = (s['students_recorded'] as int?) ?? 0;
    final pct = recorded > 0 ? present / recorded : 0.0;
    final status = s['session_status'] as String? ?? 'Scheduled';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDone ? AppColors.border : AppColors.primary.withOpacity(0.3),
          width: isDone ? 1 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Row 1: badges + status ──────────────────────────────────────────
          Row(
            children: [
              _pill(
                s['subject_shortname'] ?? s['subject_name'] ?? '—',
                AppColors.primary,
                AppColors.primaryBg,
              ),
              const SizedBox(width: 6),
              _pill(
                s['session_type'] ?? '',
                AppColors.textSub,
                AppColors.divider,
              ),
              const Spacer(),
              _pill(status, _statusColor(status), _statusBg(status)),
            ],
          ),
          const SizedBox(height: 12),

          // ── Row 2: class name + time ────────────────────────────────────────
          Text(
            s['class_name'] ?? '—',
            style: GoogleFonts.lexend(
              fontWeight: FontWeight.bold,
              color: AppColors.textMain,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${s['start_time']} – ${s['end_time']}  •  ${s['room_name'] ?? 'No room'}',
            style: GoogleFonts.lexend(color: AppColors.textMuted, fontSize: 12),
          ),
          const SizedBox(height: 12),

          // ── Row 3: progress bar (إذا مكتمل) أو زر Start ────────────────────
          if (isDone) ...[
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: pct,
                      minHeight: 5,
                      backgroundColor: AppColors.border,
                      valueColor: const AlwaysStoppedAnimation(
                        AppColors.success,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '$present / $recorded present',
                  style: GoogleFonts.lexend(
                    color: AppColors.textSub,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ] else ...[
            GestureDetector(
              onTap: () => _openAttendance(s),
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    'Start Attendance →',
                    style: GoogleFonts.lexend(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Pill badge ─────────────────────────────────────────────────────────────
  Widget _pill(String text, Color color, Color bg) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      text,
      style: GoogleFonts.lexend(
        color: color,
        fontWeight: FontWeight.w600,
        fontSize: 11,
      ),
    ),
  );
}
