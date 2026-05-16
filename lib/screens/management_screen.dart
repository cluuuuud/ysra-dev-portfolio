import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../database/db_helper.dart';
import '../app_colors.dart';
import 'student_screen.dart';

class ManagementScreen extends StatefulWidget {
  const ManagementScreen({super.key});

  @override
  State<ManagementScreen> createState() => _ManagementScreenState();
}

class _ManagementScreenState extends State<ManagementScreen> {
  List<Map<String, dynamic>> _classes = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      // ✅ getClassStatistics من vw_Class_Statistics
      final data = await DBHelper.getClassStatistics();
      setState(() {
        _classes = data;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Text(
          'Management',
          style: GoogleFonts.lexend(
            color: AppColors.textMain,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: AppColors.bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textMain),
          onPressed: () => Navigator.pop(context),
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
                  _summary(),
                  const SizedBox(height: 24),
                  Text(
                    'Classes',
                    style: GoogleFonts.lexend(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textMain,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._classes.map(_classCard),
                ],
              ),
            ),
    );
  }

  Widget _summary() {
    final totalStudents = _classes.fold<int>(
      0,
      (s, c) => s + ((c['total_students'] as int?) ?? 0),
    );
    final totalSessions = _classes.fold<int>(
      0,
      (s, c) => s + ((c['completed_sessions'] as int?) ?? 0),
    );
    final avgRate = _classes.isEmpty
        ? 0.0
        : _classes.fold<double>(
                0,
                (s, c) => s + ((c['class_attendance_rate'] as double?) ?? 0),
              ) /
              _classes.length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          _statCol(
            '${_classes.length}',
            'Classes',
            Colors.white,
            Colors.white70,
          ),
          _vDiv(),
          _statCol('$totalStudents', 'Students', Colors.white, Colors.white70),
          _vDiv(),
          _statCol('$totalSessions', 'Sessions', Colors.white, Colors.white70),
          _vDiv(),
          _statCol(
            '${avgRate.toStringAsFixed(0)}%',
            'Avg Rate',
            Colors.white,
            Colors.white70,
          ),
        ],
      ),
    );
  }

  Widget _statCol(String v, String l, Color vc, Color lc) => Expanded(
    child: Column(
      children: [
        Text(
          v,
          style: GoogleFonts.lexend(
            color: vc,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        Text(l, style: GoogleFonts.lexend(color: lc, fontSize: 11)),
      ],
    ),
  );

  Widget _vDiv() => Container(width: 1, height: 36, color: Colors.white24);

  Widget _classCard(Map<String, dynamic> c) {
    final rate = (c['class_attendance_rate'] as double?) ?? 0.0;
    final students = (c['total_students'] as int?) ?? 0;
    final sessions = (c['completed_sessions'] as int?) ?? 0;
    final pct = rate / 100;

    final rateColor = rate >= 80
        ? AppColors.success
        : rate >= 60
        ? AppColors.warning
        : AppColors.danger;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => StudentsScreen(
            classId: c['class_id'] as int,
            className: c['class_name'] as String,
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
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
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      (c['class_name'] as String? ?? '?')[0],
                      style: GoogleFonts.lexend(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        c['class_name'] ?? '—',
                        style: GoogleFonts.lexend(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textMain,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        '${c['unilevel'] ?? ''} · ${c['academic_year'] ?? ''}',
                        style: GoogleFonts.lexend(
                          color: AppColors.textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${rate.toStringAsFixed(0)}%',
                  style: GoogleFonts.lexend(
                    color: rateColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: pct,
                minHeight: 5,
                backgroundColor: AppColors.border,
                valueColor: AlwaysStoppedAnimation<Color>(rateColor),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _infoChip(Icons.people_outline, '$students students'),
                const SizedBox(width: 12),
                _infoChip(
                  Icons.check_circle_outline,
                  '$sessions sessions done',
                ),
                const Spacer(),
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.textMuted,
                  size: 16,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String t) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 13, color: AppColors.textMuted),
      const SizedBox(width: 4),
      Text(
        t,
        style: GoogleFonts.lexend(color: AppColors.textMuted, fontSize: 12),
      ),
    ],
  );
}
