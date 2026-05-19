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
  List<Map<String, dynamic>> _subjects = [];
  List<Map<String, dynamic>> _classes = [];
  List<Map<String, dynamic>> _rooms = [];
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
      final results = await Future.wait([
        DBHelper.getWeeklySchedule(),
        DBHelper.getSubjects(),
        DBHelper.getClasses(),
        DBHelper.getRooms(), // ← نضيفها في DBHelper
      ]);
      setState(() {
        _schedule = results[0] as List<Map<String, dynamic>>;
        _subjects = results[1] as List<Map<String, dynamic>>;
        _classes = results[2] as List<Map<String, dynamic>>;
        _rooms = results[3] as List<Map<String, dynamic>>;
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

  // ══════════════════════════════════════════════════════════════════════════
  //  BUILD
  // ══════════════════════════════════════════════════════════════════════════
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
      // ── FAB: إضافة حصة جديدة ─────────────────────────────────────────────
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showSlotForm(context, day: _selectedDay),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'Add Session',
          style: GoogleFonts.lexend(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
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

  // ── Day Picker ─────────────────────────────────────────────────────────────
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
        final isToday = day == _todayName();
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
                color: sel
                    ? AppColors.primary
                    : isToday
                    ? AppColors.primary.withOpacity(0.4)
                    : AppColors.border,
                width: isToday && !sel ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Text(
                  day.substring(0, 3),
                  style: GoogleFonts.lexend(
                    color: sel
                        ? Colors.white
                        : isToday
                        ? AppColors.primary
                        : AppColors.textSub,
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

  // ── List ───────────────────────────────────────────────────────────────────
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
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () => _showSlotForm(context, day: _selectedDay),
              icon: const Icon(Icons.add, color: AppColors.primary),
              label: Text(
                'Add a session',
                style: GoogleFonts.lexend(color: AppColors.primary),
              ),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
      itemCount: items.length,
      itemBuilder: (_, i) => _slotCard(items[i]),
    );
  }

  // ── Slot Card ──────────────────────────────────────────────────────────────
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
            // accent stripe
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
                        // نوع الحصة
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
                        const SizedBox(width: 8),
                        // زر التعديل
                        GestureDetector(
                          onTap: () => _showSlotForm(context, existing: s),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppColors.bg,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: const Icon(
                              Icons.edit_outlined,
                              size: 15,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        // زر الحذف
                        GestureDetector(
                          onTap: () => _confirmDelete(s),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppColors.dangerBg,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.danger.withOpacity(0.3),
                              ),
                            ),
                            child: const Icon(
                              Icons.delete_outline,
                              size: 15,
                              color: AppColors.danger,
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
                        _infoChip(
                          Icons.room_outlined,
                          s['room_name'] ?? 'No room',
                        ),
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

  // ══════════════════════════════════════════════════════════════════════════
  //  FORM — إضافة / تعديل حصة
  // ══════════════════════════════════════════════════════════════════════════
  void _showSlotForm(
    BuildContext context, {
    Map<String, dynamic>? existing,
    String? day,
  }) {
    // القيم الأولية
    String selDay = existing?['day_of_week'] ?? day ?? _selectedDay;
    int? selSubject = existing != null
        ? _subjects.firstWhere(
                (s) => s['subject_shortname'] == existing['subject_shortname'],
                orElse: () => _subjects.first,
              )['subject_id']
              as int?
        : null;
    int? selClass = existing?['class_id'] as int?;
    String selType = existing?['session_type'] ?? 'TD';
    String? selRoom = existing?['room_name'] as String?;

    // وقت البداية والنهاية
    TimeOfDay startTime = _parseTime(existing?['start_time'] ?? '08:00');
    TimeOfDay endTime = _parseTime(existing?['end_time'] ?? '09:30');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Title
                Text(
                  existing == null ? 'Add Session' : 'Edit Session',
                  style: GoogleFonts.lexend(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMain,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 20),

                // ── اليوم ─────────────────────────────────────────────────
                _formLabel('Day'),
                const SizedBox(height: 8),
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: _days.map((d) {
                      final sel = d == selDay;
                      return GestureDetector(
                        onTap: () => setModal(() => selDay = d),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: sel ? AppColors.primary : AppColors.bg,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: sel ? AppColors.primary : AppColors.border,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              d.substring(0, 3),
                              style: GoogleFonts.lexend(
                                color: sel ? Colors.white : AppColors.textSub,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),

                // ── المادة ────────────────────────────────────────────────
                _formLabel('Subject'),
                const SizedBox(height: 8),
                _dropdown<int>(
                  value: selSubject,
                  hint: 'Select subject',
                  items: _subjects
                      .map(
                        (s) => DropdownMenuItem<int>(
                          value: s['subject_id'] as int,
                          child: Text(
                            '${s['subject_shortname']} — ${s['subject_name']}',
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.lexend(
                              color: AppColors.textMain,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setModal(() => selSubject = v),
                ),
                const SizedBox(height: 16),

                // ── القروب ────────────────────────────────────────────────
                _formLabel('Class / Group'),
                const SizedBox(height: 8),
                _dropdown<int>(
                  value: selClass,
                  hint: 'Select class',
                  items: _classes
                      .map(
                        (c) => DropdownMenuItem<int>(
                          value: c['class_id'] as int,
                          child: Text(
                            '${c['class_name']}  ·  ${c['unilevel']} ${c['academic_year']}',
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.lexend(
                              color: AppColors.textMain,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setModal(() => selClass = v),
                ),
                const SizedBox(height: 16),

                // ── النوع ─────────────────────────────────────────────────
                _formLabel('Session Type'),
                const SizedBox(height: 8),
                Row(
                  children: ['TD', 'TP', 'Lecture'].map((t) {
                    final sel = t == selType;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setModal(() => selType = t),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: sel ? _typeColor(t) : AppColors.bg,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: sel ? _typeColor(t) : AppColors.border,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              t,
                              style: GoogleFonts.lexend(
                                color: sel ? Colors.white : AppColors.textSub,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // ── الوقت ─────────────────────────────────────────────────
                _formLabel('Time'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _timePicker(
                        label: 'Start',
                        time: startTime,
                        onPick: (t) => setModal(() => startTime = t),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _timePicker(
                        label: 'End',
                        time: endTime,
                        onPick: (t) => setModal(() => endTime = t),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ── القاعة ────────────────────────────────────────────────
                _formLabel('Room (optional)'),
                const SizedBox(height: 8),
                _dropdown<String>(
                  value: selRoom,
                  hint: 'Select room',
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('No room'),
                    ),
                    ..._rooms.map(
                      (r) => DropdownMenuItem<String>(
                        value: r['room_name'] as String,
                        child: Text(
                          r['room_name'] as String,
                          style: GoogleFonts.lexend(
                            color: AppColors.textMain,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ],
                  onChanged: (v) => setModal(() => selRoom = v),
                ),
                const SizedBox(height: 24),

                // ── زر الحفظ ──────────────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () async {
                      // تحقق من الحقول
                      if (selSubject == null || selClass == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Please select subject and class',
                              style: GoogleFonts.lexend(),
                            ),
                            backgroundColor: AppColors.danger,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                        return;
                      }
                      if (_timeToMinutes(endTime) <=
                          _timeToMinutes(startTime)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'End time must be after start time',
                              style: GoogleFonts.lexend(),
                            ),
                            backgroundColor: AppColors.danger,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                        return;
                      }

                      final startStr = _formatTime(startTime);
                      final endStr = _formatTime(endTime);

                      try {
                        if (existing == null) {
                          // ── إضافة جديدة ──
                          await DBHelper.insertTimetableSlot(
                            classId: selClass!,
                            subjectId: selSubject!,
                            dayOfWeek: selDay,
                            startTime: startStr,
                            endTime: endStr,
                            sessionType: selType,
                            roomName: selRoom,
                          );
                        } else {
                          // ── تعديل موجود ──
                          await DBHelper.updateTimetableSlot(
                            timetableId: existing['timetable_id'] as int,
                            classId: selClass!,
                            subjectId: selSubject!,
                            dayOfWeek: selDay,
                            startTime: startStr,
                            endTime: endStr,
                            sessionType: selType,
                            roomName: selRoom,
                          );
                        }
                        if (mounted) {
                          Navigator.pop(ctx);
                          _load();
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Error: $e',
                              style: GoogleFonts.lexend(),
                            ),
                            backgroundColor: AppColors.danger,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      }
                    },
                    child: Text(
                      existing == null ? 'Add Session' : 'Save Changes',
                      style: GoogleFonts.lexend(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── تأكيد الحذف ────────────────────────────────────────────────────────────
  void _confirmDelete(Map<String, dynamic> slot) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Delete Session?',
          style: GoogleFonts.lexend(
            fontWeight: FontWeight.bold,
            color: AppColors.textMain,
          ),
        ),
        content: Text(
          '${slot['subject_shortname']} — ${slot['class_name']}\n'
          '${slot['day_of_week']}  ${slot['start_time']} – ${slot['end_time']}',
          style: GoogleFonts.lexend(color: AppColors.textMuted, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.lexend(color: AppColors.textMuted),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () async {
              Navigator.pop(context);
              await DBHelper.deleteTimetableSlot(slot['timetable_id'] as int);
              _load();
            },
            child: Text(
              'Delete',
              style: GoogleFonts.lexend(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers للـ Form ───────────────────────────────────────────────────────
  Widget _formLabel(String text) => Text(
    text,
    style: GoogleFonts.lexend(
      fontWeight: FontWeight.w600,
      color: AppColors.textSub,
      fontSize: 13,
    ),
  );

  Widget _dropdown<T>({
    required T? value,
    required String hint,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14),
    decoration: BoxDecoration(
      color: AppColors.bg,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.border),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<T>(
        value: value,
        hint: Text(
          hint,
          style: GoogleFonts.lexend(color: AppColors.textMuted, fontSize: 13),
        ),
        isExpanded: true,
        dropdownColor: AppColors.surface,
        items: items,
        onChanged: onChanged,
      ),
    ),
  );

  Widget _timePicker({
    required String label,
    required TimeOfDay time,
    required ValueChanged<TimeOfDay> onPick,
  }) => GestureDetector(
    onTap: () async {
      final picked = await showTimePicker(
        context: context,
        initialTime: time,
        builder: (ctx, child) => MediaQuery(
          data: MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        ),
      );
      if (picked != null) onPick(picked);
    },
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.access_time_outlined,
            size: 16,
            color: AppColors.textMuted,
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.lexend(
                  color: AppColors.textMuted,
                  fontSize: 10,
                ),
              ),
              Text(
                _formatTime(time),
                style: GoogleFonts.lexend(
                  color: AppColors.textMain,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );

  TimeOfDay _parseTime(String t) {
    final parts = t.split(':');
    return TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 8,
      minute: int.tryParse(parts[1]) ?? 0,
    );
  }

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  int _timeToMinutes(TimeOfDay t) => t.hour * 60 + t.minute;
}
