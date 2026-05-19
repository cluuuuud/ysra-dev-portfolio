import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../database/db_helper.dart';
import '../app_colors.dart';

class SessionHistoryScreen extends StatefulWidget {
  const SessionHistoryScreen({super.key});

  @override
  State<SessionHistoryScreen> createState() => _SessionHistoryScreenState();
}

class _SessionHistoryScreenState extends State<SessionHistoryScreen> {
  List<Map<String, dynamic>> _sessions = [];
  List<Map<String, dynamic>> _classes = [];
  bool _loading = true;
  int? _filterClassId;
  String? _filterStatus;

  static const _statuses = ['Completed', 'Scheduled', 'Cancelled'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        // ✅ getRecentSessions مع limit كبير بدل getSessions
        DBHelper.getRecentSessions(limit: 50),
        DBHelper.getClasses(),
      ]);
      setState(() {
        _sessions = results[0] as List<Map<String, dynamic>>;
        _classes = results[1] as List<Map<String, dynamic>>;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  List<Map<String, dynamic>> get _filtered => _sessions.where((s) {
    if (_filterClassId != null && s['class_id'] != _filterClassId) return false;
    if (_filterStatus != null && s['session_status'] != _filterStatus)
      return false;
    return true;
  }).toList();

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

  Color _typeColor(String? t) {
    switch (t) {
      case 'TD':
        return AppColors.primary;
      case 'TP':
        return AppColors.success;
      case 'Lecture':
        return AppColors.warning;
      default:
        return AppColors.textMuted;
    }
  }

  Color _typeBg(String? t) {
    switch (t) {
      case 'TD':
        return AppColors.primaryBg;
      case 'TP':
        return AppColors.successBg;
      case 'Lecture':
        return AppColors.warningBg;
      default:
        return AppColors.divider;
    }
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
          'Session History',
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
          : Column(
              children: [
                _filterBar(),
                _summaryRow(),
                Expanded(child: _buildList()),
              ],
            ),
    );
  }

  // ── Filter Bar ────────────────────────────────────────────────────────────
  Widget _filterBar() => SizedBox(
    height: 48,
    child: ListView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        ..._statuses.map((st) {
          final sel = _filterStatus == st;
          return _filterChip(
            st,
            sel,
            () => setState(() => _filterStatus = sel ? null : st),
            color: _statusColor(st),
          );
        }),
        const SizedBox(width: 8),
        ..._classes.map((cls) {
          final id = cls['class_id'] as int;
          final sel = _filterClassId == id;
          return _filterChip(
            cls['class_name'] ?? '?',
            sel,
            () => setState(() => _filterClassId = sel ? null : id),
          );
        }),
      ],
    ),
  );

  Widget _filterChip(
    String label,
    bool selected,
    VoidCallback onTap, {
    Color? color,
  }) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: selected ? (color ?? AppColors.primary) : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: selected ? (color ?? AppColors.primary) : AppColors.border,
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.lexend(
          color: selected ? Colors.white : AppColors.textSub,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    ),
  );

  // ── Summary Row ───────────────────────────────────────────────────────────
  Widget _summaryRow() {
    final f = _filtered;
    final total = f.length;
    final completed = f.where((s) => s['session_status'] == 'Completed').length;
    final cancelled = f.where((s) => s['session_status'] == 'Cancelled').length;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          _miniStat('Total', '$total', AppColors.textSub),
          _dividerV(),
          _miniStat('Completed', '$completed', AppColors.success),
          _dividerV(),
          _miniStat('Cancelled', '$cancelled', AppColors.danger),
        ],
      ),
    );
  }

  Widget _miniStat(String label, String value, Color color) => Expanded(
    child: Column(
      children: [
        Text(
          value,
          style: GoogleFonts.lexend(
            fontWeight: FontWeight.bold,
            color: color,
            fontSize: 18,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.lexend(color: AppColors.textMuted, fontSize: 11),
        ),
      ],
    ),
  );

  Widget _dividerV() =>
      Container(width: 1, height: 32, color: AppColors.border);

  // ── List ──────────────────────────────────────────────────────────────────
  Widget _buildList() {
    final items = _filtered;
    if (items.isEmpty) {
      return Center(
        child: Text(
          'No sessions found',
          style: GoogleFonts.lexend(color: AppColors.textMuted),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
      itemCount: items.length,
      itemBuilder: (_, i) => _sessionCard(items[i]),
    );
  }

  Widget _sessionCard(Map<String, dynamic> s) {
    // vw_Recent_Sessions يعطي: present, absent, late, avg_participation
    final present = (s['present'] as int?) ?? 0;
    final absent = (s['absent'] as int?) ?? 0;
    final late = (s['late'] as int?) ?? 0;
    final total = present + absent + late;
    final pct = total > 0 ? present / total : 0.0;
    final status = s['session_status'] as String? ?? 'Scheduled';
    final type = s['session_type'] as String?;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // accent stripe
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: _statusColor(status),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // badges
                    Row(
                      children: [
                        _badge(
                          s['subject_shortname'] ?? '—',
                          _typeColor(type),
                          _typeBg(type),
                        ),
                        const SizedBox(width: 6),
                        _badge(type ?? '—', _typeColor(type), _typeBg(type)),
                        const Spacer(),
                        _badge(status, _statusColor(status), _statusBg(status)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // date
                    Row(
                      children: [
                        // ── vw_Recent_Sessions لا يحتوي class_name مباشرة
                        // لكن يحتوي subject_shortname + session_date
                        Expanded(
                          child: Text(
                            s['subject_shortname'] ?? '—',
                            style: GoogleFonts.lexend(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textMain,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Text(
                          s['session_date'] ?? '—',
                          style: GoogleFonts.lexend(
                            color: AppColors.textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    // attendance stats
                    if (status == 'Completed') ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _statDot('$present Present', AppColors.success),
                          const SizedBox(width: 10),
                          _statDot('$absent Absent', AppColors.danger),
                          if (late > 0) ...[
                            const SizedBox(width: 10),
                            _statDot('$late Late', AppColors.warning),
                          ],
                          const Spacer(),
                          Text(
                            '${(pct * 100).toStringAsFixed(0)}%',
                            style: GoogleFonts.lexend(
                              color: pct >= 0.8
                                  ? AppColors.success
                                  : AppColors.warning,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: pct,
                          minHeight: 4,
                          backgroundColor: AppColors.border,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            pct >= 0.8 ? AppColors.success : AppColors.warning,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(String text, Color color, Color bg) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(6),
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

  Widget _statDot(String text, Color color) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      const SizedBox(width: 4),
      Text(
        text,
        style: GoogleFonts.lexend(color: AppColors.textMuted, fontSize: 11),
      ),
    ],
  );
}
