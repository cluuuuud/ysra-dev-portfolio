import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../database/db_helper.dart';
import '../app_colors.dart';

class TimetableScreen extends StatefulWidget {
  const TimetableScreen({super.key});

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  List<Map<String, dynamic>> _schedule = [];
  bool _loading = true;
  String _selectedDay = '';

  static const _days = [
    'Saturday',
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
  ];

  @override
  void initState() {
    super.initState();
    _selectedDay = _todayName();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      // ✅ getWeeklySchedule بدل getTimetable
      final data = await DBHelper.getWeeklySchedule();
      setState(() {
        _schedule = data;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
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

  List<Map<String, dynamic>> get _filtered =>
      _schedule.where((s) => s['day_of_week'] == _selectedDay).toList();

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
        title: Text(
          'Timetable',
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
          : Column(
              children: [
                _dayPicker(),
                Expanded(child: _buildList()),
              ],
            ),
    );
  }

  // ── Day Picker ────────────────────────────────────────────────────────────
  Widget _dayPicker() => SizedBox(
    height: 56,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _days.length,
      itemBuilder: (_, i) {
        final day = _days[i];
        final sel = day == _selectedDay;
        final has = _schedule.any((s) => s['day_of_week'] == day);
        return GestureDetector(
          onTap: () => setState(() => _selectedDay = day),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: sel ? AppColors.primary : AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: sel ? AppColors.primary : AppColors.border,
              ),
            ),
            child: Row(
              children: [
                Text(
                  day.substring(0, 3),
                  style: GoogleFonts.lexend(
                    color: sel ? Colors.white : AppColors.textSub,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                if (has) ...[
                  const SizedBox(width: 6),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: sel ? Colors.white70 : AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    ),
  );

  // ── Session List ──────────────────────────────────────────────────────────
  Widget _buildList() {
    final items = _filtered;
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.event_busy_outlined,
              size: 48,
              color: AppColors.textMuted.withOpacity(0.4),
            ),
            const SizedBox(height: 12),
            Text(
              'No sessions on $_selectedDay',
              style: GoogleFonts.lexend(
                color: AppColors.textMuted,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: items.length,
      itemBuilder: (_, i) => _slotCard(items[i]),
    );
  }

  Widget _slotCard(Map<String, dynamic> s) {
    final type = s['session_type'] as String?;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: IntrinsicHeight(
        child: Row(
          children: [
            // ── Left accent stripe ──
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: _typeColor(type),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${s['subject_shortname']} — ${s['class_name']}',
                            style: GoogleFonts.lexend(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textMain,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _typeBg(type),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            type ?? '—',
                            style: GoogleFonts.lexend(
                              color: _typeColor(type),
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _infoChip(
                          Icons.access_time_outlined,
                          '${s['start_time']} – ${s['end_time']}',
                        ),
                        const SizedBox(width: 12),
                        _infoChip(Icons.room_outlined, s['room_name'] ?? '—'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String text) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 13, color: AppColors.textMuted),
      const SizedBox(width: 4),
      Text(
        text,
        style: GoogleFonts.lexend(color: AppColors.textMuted, fontSize: 12),
      ),
    ],
  );
}
