import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../database/db_helper.dart';
import '../app_colors.dart';
import 'attendance_list_screen.dart';
import 'timetable_screen.dart';
import 'session_history_screen.dart';
import 'management_screen.dart';
import 'import_export_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // ── State ──────────────────────────────────────────────────────────────────
  Map<String, dynamic>? _currentSession;
  Map<String, dynamic>? _nextSession;
  Map<String, dynamic>? _lastSession;
  int _atRiskCount = 0;
  double _avgRate = 0;
  int _classCount = 0;
  double _weeklyRate = 0;
  List<Map<String, dynamic>> _todaySlots = [];
  List<Map<String, dynamic>> _atRiskList = [];

  // ✅ مفصول: أول تحميل يعرض spinner، الباقي يحدث في الخلفية
  bool _firstLoad = true;
  bool _refreshing = false;

  Timer? _timer;
  String _countdown = '';

  @override
  void initState() {
    super.initState();
    _load();
    // تحديث كل دقيقة بدون spinner
    _timer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => _silentRefresh(),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // ── تحميل أول مرة (مع spinner) ────────────────────────────────────────────
  Future<void> _load() async {
    if (!mounted) return;
    if (_firstLoad) setState(() => _firstLoad = true);

    await _fetchAll();

    if (mounted) setState(() => _firstLoad = false);
  }

  // ── تحديث صامت (بدون spinner) ─────────────────────────────────────────────
  Future<void> _silentRefresh() async {
    if (!mounted || _refreshing) return;
    _refreshing = true;
    await _fetchAll();
    _refreshing = false;
    if (mounted) setState(() {});
  }

  // ── جلب كل البيانات بالتوازي ─────────────────────────────────────────────
  Future<void> _fetchAll() async {
    try {
      // ✅ نقسم إلى مجموعتين: المهمة أولاً، ثم الأقل أهمية
      // المجموعة 1: الحصة الحالية والقادمة (الأسرع)
      final group1 =
          await Future.wait([
            DBHelper.getCurrentSession(), // 0
            DBHelper.getNextSession(), // 1
            DBHelper.getLastCompletedSession(), // 2
          ]).timeout(
            const Duration(seconds: 5),
            onTimeout: () => [null, null, null],
          );

      // المجموعة 2: الإحصائيات
      final group2 =
          await Future.wait([
            DBHelper.getAtRiskCount(), // 0
            DBHelper.getAtRiskStudents(), // 1
            DBHelper.getAvgClassRate(), // 2
            DBHelper.getClassCount(), // 3
            DBHelper.getWeeklyAttendanceRate(), // 4
            DBHelper.getWeeklySchedule(), // 5
          ]).timeout(
            const Duration(seconds: 5),
            onTimeout: () => [
              0,
              <Map<String, dynamic>>[],
              0.0,
              0,
              0.0,
              <Map<String, dynamic>>[],
            ],
          );

      if (!mounted) return;

      final today = _todayName();
      final allSlots = group2[5] as List<Map<String, dynamic>>;

      _currentSession = group1[0] as Map<String, dynamic>?;
      _nextSession = group1[1] as Map<String, dynamic>?;
      _lastSession = group1[2] as Map<String, dynamic>?;
      _atRiskCount = (group2[0] as int?) ?? 0;
      _atRiskList = ((group2[1] as List<Map<String, dynamic>>?) ?? [])
          .take(3)
          .toList();
      _avgRate = (group2[2] as double?) ?? 0;
      _classCount = (group2[3] as int?) ?? 0;
      _weeklyRate = (group2[4] as double?) ?? 0;
      _todaySlots = allSlots.where((s) => s['day_of_week'] == today).toList();

      _updateCountdown();
    } catch (e) {
      debugPrint('Dashboard _fetchAll error: $e');
    }
  }

  // ── عداد تنازلي ────────────────────────────────────────────────────────────
  void _updateCountdown() {
    if (_nextSession == null) {
      _countdown = '';
      return;
    }
    try {
      final startStr = _nextSession!['start_time'] as String? ?? '';
      final dateStr = _nextSession!['session_date'] as String? ?? '';
      final parts = startStr.split(':');
      final dateParts = dateStr.split('-');
      final now = DateTime.now();
      final start = DateTime(
        int.parse(dateParts[0]),
        int.parse(dateParts[1]),
        int.parse(dateParts[2]),
        int.parse(parts[0]),
        int.parse(parts[1]),
      );
      final diff = start.difference(now);
      if (diff.isNegative || diff.inSeconds < 0) {
        _countdown = '';
        return;
      }
      _countdown = diff.inHours > 0
          ? 'in ${diff.inHours}h ${diff.inMinutes.remainder(60)}m'
          : 'in ${diff.inMinutes}m';
    } catch (_) {
      _countdown = '';
    }
  }

  String _todayName() {
    const m = {
      1: 'Monday',
      2: 'Tuesday',
      3: 'Wednesday',
      4: 'Thursday',
      5: 'Friday',
      6: 'Saturday',
      7: 'Sunday',
    };
    return m[DateTime.now().weekday] ?? 'Saturday';
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  BUILD
  // ══════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    // أول تحميل فقط يعرض spinner
    if (_firstLoad) {
      return const Scaffold(
        backgroundColor: AppColors.bg,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          color: AppColors.primary,
          child: CustomScrollView(
            slivers: [
              _appBar(),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // ══ 1. LIVE SESSION — أعلى الصفحة دائماً ════════════
                    if (_currentSession != null) ...[
                      _liveBanner(_currentSession!),
                      const SizedBox(height: 14),
                    ]
                    // ══ 2. NEXT SESSION — إذا ما في حصة حالية ═══════════
                    else if (_nextSession != null) ...[
                      _nextSessionBanner(_nextSession!),
                      const SizedBox(height: 14),
                    ],

                    // ══ 3. AT-RISK ALERT ════════════════════════════════
                    if (_atRiskCount > 0) ...[
                      _atRiskAlert(),
                      const SizedBox(height: 14),
                    ],

                    // ══ 4. QUICK ACCESS ════════════════════════════════
                    _quickAccessSection(),
                    const SizedBox(height: 22),

                    // ══ 5. OVERVIEW ════════════════════════════════════
                    _sectionHeader('Overview', Icons.bar_chart_outlined),
                    const SizedBox(height: 10),
                    _overviewCards(),
                    const SizedBox(height: 10),
                    _weeklyRateBanner(),
                    const SizedBox(height: 22),

                    // ══ 6. LAST SESSION ════════════════════════════════
                    if (_lastSession != null) ...[
                      _sectionHeader('Last Session', Icons.history_outlined),
                      const SizedBox(height: 10),
                      _lastSessionCard(_lastSession!),
                    ],
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  APP BAR
  // ══════════════════════════════════════════════════════════════════════════
  Widget _appBar() => SliverToBoxAdapter(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_greeting()} 👋',
                style: GoogleFonts.lexend(
                  fontSize: 13,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'ATTENDIX',
                style: GoogleFonts.lexend(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textMain,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const Spacer(),
          // Refresh indicator خفي
          if (_refreshing)
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/settings'),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(
                Icons.settings_outlined,
                color: AppColors.textSub,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    ),
  );

  // ══════════════════════════════════════════════════════════════════════════
  //  1. LIVE BANNER
  // ══════════════════════════════════════════════════════════════════════════
  Widget _liveBanner(Map<String, dynamic> s) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AttendanceListScreen(
            preselectedClassId: _toInt(s['class_id']),
            preselectedSessionId: _toInt(s['session_id']),
          ),
        ),
      ).then((_) => _load()),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF16A34A),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Live dot
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'LIVE NOW',
                        style: GoogleFonts.lexend(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  '${s['start_time']} – ${s['end_time']}',
                  style: GoogleFonts.lexend(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              s['subject_shortname'] ?? s['subject_name'] ?? '—',
              style: GoogleFonts.lexend(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${s['class_name'] ?? '—'}  ·  ${s['room_name'] ?? 'No room'}',
              style: GoogleFonts.lexend(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 14),
            Container(
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  'Record Attendance Now →',
                  style: GoogleFonts.lexend(
                    color: const Color(0xFF16A34A),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  2. NEXT SESSION BANNER (يظهر فقط إذا ما في حصة حالية)
  // ══════════════════════════════════════════════════════════════════════════
  Widget _nextSessionBanner(Map<String, dynamic> s) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AttendanceListScreen()),
      ).then((_) => _load()),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.4),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.warningBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.schedule,
                color: AppColors.warning,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBg,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'NEXT',
                          style: GoogleFonts.lexend(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      if (_countdown.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        Text(
                          _countdown,
                          style: GoogleFonts.lexend(
                            color: AppColors.warning,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${s['subject_shortname'] ?? s['subject_name'] ?? '—'}  —  ${s['class_name'] ?? '—'}',
                    style: GoogleFonts.lexend(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textMain,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '${s['start_time']} – ${s['end_time']}  ·  ${s['room_name'] ?? 'No room'}',
                    style: GoogleFonts.lexend(
                      color: AppColors.textMuted,
                      fontSize: 12,
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

  // ══════════════════════════════════════════════════════════════════════════
  //  3. AT-RISK ALERT
  // ══════════════════════════════════════════════════════════════════════════
  Widget _atRiskAlert() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.dangerBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.danger.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: AppColors.danger,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '$_atRiskCount student${_atRiskCount > 1 ? 's' : ''} need attention',
                  style: GoogleFonts.lexend(
                    color: AppColors.danger,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ManagementScreen()),
                ),
                child: Text(
                  'View all',
                  style: GoogleFonts.lexend(
                    color: AppColors.danger,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
          if (_atRiskList.isNotEmpty) ...[
            const SizedBox(height: 10),
            ..._atRiskList.map((st) {
              final name = st['student_name'] as String? ?? '—';
              final rate = (st['attendance_rate'] as num?)?.toDouble() ?? 0;
              final riskType = st['attendance_risk'] != null
                  ? 'Low Attendance'
                  : 'Low Performance';
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.danger.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          name.isNotEmpty ? name[0].toUpperCase() : '?',
                          style: const TextStyle(
                            color: AppColors.danger,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        name,
                        style: GoogleFonts.lexend(
                          color: AppColors.textMain,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.danger.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${rate.toStringAsFixed(0)}%  ·  $riskType',
                        style: GoogleFonts.lexend(
                          color: AppColors.danger,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  4. QUICK ACCESS
  // ══════════════════════════════════════════════════════════════════════════
  Widget _quickAccessSection() => Column(
    children: [
      Row(
        children: [
          Expanded(
            child: _rowCard(
              'Attendance',
              Icons.edit_note_outlined,
              AppColors.success,
              AppColors.successBg,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AttendanceListScreen()),
              ).then((_) => _load()),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _rowCard(
              'Session History',
              Icons.history_outlined,
              AppColors.warning,
              AppColors.warningBg,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SessionHistoryScreen()),
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 10),
      Row(
        children: [
          Expanded(
            child: _rowCard(
              'Management',
              Icons.manage_accounts_outlined,
              AppColors.textSub,
              AppColors.divider,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ManagementScreen()),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _rowCard(
              'Import / Export',
              Icons.import_export_outlined,
              AppColors.danger,
              AppColors.dangerBg,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ImportExportScreen()),
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 10),
      _timetableCard(),
    ],
  );

  Widget _rowCard(
    String label,
    IconData icon,
    Color color,
    Color bg,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.lexend(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMain,
                  fontSize: 12,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textMuted,
              size: 15,
            ),
          ],
        ),
      ),
    );
  }

  Widget _timetableCard() {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const TimetableScreen()),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.calendar_today_outlined,
                    color: AppColors.primary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Timetable',
                        style: GoogleFonts.lexend(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMain,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        _todayName(),
                        style: GoogleFonts.lexend(
                          color: AppColors.textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_todaySlots.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${_todaySlots.length} sessions',
                      style: GoogleFonts.lexend(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                const SizedBox(width: 6),
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.textMuted,
                  size: 15,
                ),
              ],
            ),
            if (_todaySlots.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  'No sessions today',
                  style: GoogleFonts.lexend(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
              )
            else ...[
              const SizedBox(height: 10),
              const Divider(height: 1, color: AppColors.border),
              const SizedBox(height: 10),
              ..._todaySlots.map(_miniSlot),
            ],
          ],
        ),
      ),
    );
  }

  Widget _miniSlot(Map<String, dynamic> slot) {
    final type = slot['session_type'] as String? ?? '';
    Color tc, tb;
    switch (type) {
      case 'TD':
        tc = AppColors.primary;
        tb = AppColors.primaryBg;
        break;
      case 'TP':
        tc = AppColors.success;
        tb = AppColors.successBg;
        break;
      case 'Lecture':
        tc = AppColors.warning;
        tb = AppColors.warningBg;
        break;
      default:
        tc = AppColors.textMuted;
        tb = AppColors.divider;
    }
    final subject = slot['subject_shortname'] as String? ?? '—';
    final cls = slot['class_name'] as String? ?? '—';
    final start = slot['start_time'] as String? ?? '';
    final end = slot['end_time'] as String? ?? '';
    final room = slot['room_name'] as String?;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 82,
            child: Text(
              '$start\n$end',
              style: GoogleFonts.lexend(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Container(
            width: 2,
            height: 36,
            decoration: BoxDecoration(
              color: tc.withOpacity(0.35),
              borderRadius: BorderRadius.circular(2),
            ),
            margin: const EdgeInsets.only(right: 10),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      subject,
                      style: GoogleFonts.lexend(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textMain,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: tb,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        type,
                        style: GoogleFonts.lexend(
                          color: tc,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  room != null ? '$cls  ·  $room' : cls,
                  style: GoogleFonts.lexend(
                    color: AppColors.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  5. OVERVIEW
  // ══════════════════════════════════════════════════════════════════════════
  Widget _overviewCards() => Row(
    children: [
      Expanded(
        child: _statCard(
          icon: Icons.warning_amber_outlined,
          iconColor: _atRiskCount > 0 ? AppColors.danger : AppColors.textMuted,
          iconBg: _atRiskCount > 0 ? AppColors.dangerBg : AppColors.divider,
          label: 'At-risk students',
          value: '$_atRiskCount',
          sub: _atRiskCount == 0 ? 'None flagged' : '$_atRiskCount flagged',
          subColor: _atRiskCount > 0 ? AppColors.danger : AppColors.textMuted,
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: _statCard(
          icon: Icons.bar_chart_outlined,
          iconColor: _avgRate >= 75 ? AppColors.success : AppColors.danger,
          iconBg: _avgRate >= 75 ? AppColors.successBg : AppColors.dangerBg,
          label: 'Avg class rate',
          value: '${_avgRate.toStringAsFixed(1)}%',
          sub: '$_classCount classes',
          subColor: AppColors.textMuted,
        ),
      ),
    ],
  );

  Widget _statCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String label,
    required String value,
    required String sub,
    required Color subColor,
  }) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: GoogleFonts.lexend(color: AppColors.textMuted, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.lexend(
            fontWeight: FontWeight.bold,
            color: AppColors.textMain,
            fontSize: 26,
          ),
        ),
        Text(sub, style: GoogleFonts.lexend(color: subColor, fontSize: 12)),
      ],
    ),
  );

  Widget _weeklyRateBanner() {
    final pct = _weeklyRate.clamp(0.0, 100.0);
    final Color rc = pct >= 80
        ? AppColors.success
        : pct >= 60
        ? AppColors.warning
        : AppColors.danger;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weekly attendance',
            style: GoogleFonts.lexend(
              color: AppColors.textMuted,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '${pct.toStringAsFixed(1)}%',
                style: GoogleFonts.lexend(
                  color: rc,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Icon(
                pct >= 80
                    ? Icons.trending_up
                    : pct >= 60
                    ? Icons.trending_flat
                    : Icons.trending_down,
                color: rc,
                size: 32,
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct / 100,
              minHeight: 6,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(rc),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  6. LAST SESSION
  // ══════════════════════════════════════════════════════════════════════════
  Widget _lastSessionCard(Map<String, dynamic> s) {
    final present = (s['students_present'] as int?) ?? 0;
    final recorded = (s['students_recorded'] as int?) ?? 0;
    final pct = recorded > 0 ? present / recorded : 0.0;
    final pctColor = pct >= 0.75 ? AppColors.success : AppColors.warning;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SessionHistoryScreen()),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.successBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.check_circle_outline,
                color: AppColors.success,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${s['subject_shortname'] ?? '—'}  —  ${s['class_name'] ?? '—'}',
                    style: GoogleFonts.lexend(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textMain,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    s['session_date'] ?? '—',
                    style: GoogleFonts.lexend(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: pct,
                      minHeight: 4,
                      backgroundColor: AppColors.border,
                      valueColor: AlwaysStoppedAnimation<Color>(pctColor),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${(pct * 100).toStringAsFixed(0)}%',
                  style: GoogleFonts.lexend(
                    fontWeight: FontWeight.bold,
                    color: pctColor,
                    fontSize: 18,
                  ),
                ),
                Text(
                  '$present/$recorded',
                  style: GoogleFonts.lexend(
                    color: AppColors.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  Widget _sectionHeader(String title, IconData icon) => Row(
    children: [
      Icon(icon, size: 15, color: AppColors.textMuted),
      const SizedBox(width: 6),
      Text(
        title,
        style: GoogleFonts.lexend(
          fontWeight: FontWeight.bold,
          color: AppColors.textMain,
          fontSize: 14,
        ),
      ),
    ],
  );

  int? _toInt(dynamic v) => v is int ? v : int.tryParse(v?.toString() ?? '');
}
