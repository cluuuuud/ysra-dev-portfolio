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
  Map<String, dynamic>? _currentOrNextSession;
  bool _isCurrent = false;
  int _atRiskCount = 0;
  double _avgRate = 0;
  int _classCount = 0;
  double _weeklyRate = 0;
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
        DBHelper.getCurrentSession(),
        DBHelper.getNextSession(),
        DBHelper.getAtRiskCount(),
        DBHelper.getAvgClassRate(),
        DBHelper.getClassCount(),
        DBHelper.getWeeklyAttendanceRate(),
      ]);

      final current = results[0] as Map<String, dynamic>?;
      final next = results[1] as Map<String, dynamic>?;

      setState(() {
        _isCurrent = current != null;
        _currentOrNextSession = current ?? next;
        _atRiskCount = results[2] as int;
        _avgRate = results[3] as double;
        _classCount = results[4] as int;
        _weeklyRate = results[5] as double;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          color: AppColors.primary,
          child: _loading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                )
              : CustomScrollView(
                  slivers: [
                    _buildAppBar(),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          // 1. Quick Access — مطابق للصورة
                          _quickAccessList(),
                          const SizedBox(height: 28),

                          // 2. Overview section header
                          _sectionHeader(
                            'Overview',
                            Icons.trending_up_outlined,
                          ),
                          const SizedBox(height: 12),

                          // 3. Overview cards row (At-risk + Avg class rate)
                          _overviewCards(),
                          const SizedBox(height: 12),

                          // 4. Weekly attendance banner
                          _weeklyRateBanner(),
                          const SizedBox(height: 28),

                          // 5. Current / Next session (إذا توفّر)
                          if (_currentOrNextSession != null) ...[
                            _sectionHeader(
                              _isCurrent ? 'Current Session' : 'Next Session',
                              _isCurrent
                                  ? Icons.radio_button_on
                                  : Icons.schedule_outlined,
                            ),
                            const SizedBox(height: 12),
                            _sessionCard(_currentOrNextSession!),
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

  // ── AppBar ─────────────────────────────────────────────────────────────────
  Widget _buildAppBar() => SliverToBoxAdapter(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
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
              const SizedBox(height: 2),
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

  // ── Quick Access List — مطابق للصورة (قائمة عمودية بكاردز) ────────────────
  Widget _quickAccessList() {
    final items = [
      // Timetable — أولاً حسب الأستاذ (لكن في الصورة Attendance أول)
      _QItem(
        'Attendance',
        Icons.edit_note_outlined,
        AppColors.success,
        AppColors.successBg,
        () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AttendanceListScreen()),
        ),
      ),
      _QItem(
        'Session History',
        Icons.history_outlined,
        AppColors.warning,
        AppColors.warningBg,
        () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SessionHistoryScreen()),
        ),
      ),
      _QItem(
        'Management',
        Icons.manage_accounts_outlined,
        AppColors.textSub,
        AppColors.divider,
        () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ManagementScreen()),
        ),
      ),
      _QItem(
        'Import / Export',
        Icons.import_export_outlined,
        AppColors.danger,
        AppColors.dangerBg,
        () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ImportExportScreen()),
        ),
      ),
    ];

    return Column(
      children: items
          .map(
            (item) => GestureDetector(
              onTap: item.onTap,
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: item.bg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(item.icon, color: item.color, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Text(
                      item.label,
                      style: GoogleFonts.lexend(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMain,
                        fontSize: 15,
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.chevron_right,
                      color: AppColors.textMuted,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  // ── Overview Cards Row ─────────────────────────────────────────────────────
  // مطابق للصورة: At-risk (view) | Avg class rate
  Widget _overviewCards() => Row(
    children: [
      // At-risk card
      Expanded(
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
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.warning_amber_outlined,
                  color: AppColors.textMuted,
                  size: 20,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'At-risk (view)',
                style: GoogleFonts.lexend(
                  color: AppColors.textMuted,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$_atRiskCount',
                style: GoogleFonts.lexend(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textMain,
                  fontSize: 26,
                ),
              ),
              Text(
                _atRiskCount == 0 ? 'None flagged' : '$_atRiskCount flagged',
                style: GoogleFonts.lexend(
                  color: _atRiskCount > 0
                      ? AppColors.danger
                      : AppColors.textMuted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(width: 10),

      // Avg class rate card
      Expanded(
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
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.dangerBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.bar_chart_outlined,
                  color: AppColors.danger,
                  size: 20,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Avg class rate',
                style: GoogleFonts.lexend(
                  color: AppColors.textMuted,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${_avgRate.toStringAsFixed(1)}%',
                style: GoogleFonts.lexend(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textMain,
                  fontSize: 26,
                ),
              ),
              Text(
                '$_classCount classes',
                style: GoogleFonts.lexend(
                  color: AppColors.textMuted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );

  // ── Weekly Rate Banner ─────────────────────────────────────────────────────
  // مطابق للصورة: بطاقة بيضاء بدون خلفية زرقاء
  Widget _weeklyRateBanner() {
    final pct = _weeklyRate.clamp(0.0, 100.0);
    final Color rateColor = pct >= 80
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
                  color: rateColor,
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
                color: rateColor,
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
              valueColor: AlwaysStoppedAnimation<Color>(rateColor),
            ),
          ),
        ],
      ),
    );
  }

  // ── Current / Next Session Card ────────────────────────────────────────────
  Widget _sessionCard(Map<String, dynamic> s) {
    final isDone = s['session_status'] == 'Completed';

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AttendanceListScreen(
            preselectedClassId: s['class_id'] as int?,
            preselectedSessionId: s['session_id'] as int?,
          ),
        ),
      ).then((_) => _load()),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isCurrent
                ? AppColors.primary.withOpacity(0.4)
                : AppColors.border,
            width: _isCurrent ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _pill(
                  s['subject_shortname'] ?? '—',
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
                if (_isCurrent)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.dangerBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: AppColors.danger,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Live',
                          style: GoogleFonts.lexend(
                            color: AppColors.danger,
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
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
              style: GoogleFonts.lexend(
                color: AppColors.textMuted,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              height: 38,
              decoration: BoxDecoration(
                color: isDone ? AppColors.successBg : AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  isDone ? 'View Details →' : 'Take Attendance →',
                  style: GoogleFonts.lexend(
                    color: isDone ? AppColors.success : Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  Widget _sectionHeader(String title, IconData icon) => Row(
    children: [
      Icon(icon, size: 16, color: AppColors.textMuted),
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

class _QItem {
  final String label;
  final IconData icon;
  final Color color, bg;
  final VoidCallback onTap;
  const _QItem(this.label, this.icon, this.color, this.bg, this.onTap);
}
