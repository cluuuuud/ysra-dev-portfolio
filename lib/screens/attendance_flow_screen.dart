import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../database/db_helper.dart';
import '../app_colors.dart';

// ═══════════════════════════════════════════════════════════
//  Model داخلي للطالب
// ═══════════════════════════════════════════════════════════
class _StudentRecord {
  final String registrationNumber;
  final String fullName;
  String status; // Present | Absent | Late | Excused
  int participationScore;
  int disciplineScore;
  int preparationScore;
  String notes;
  bool saved;

  _StudentRecord({
    required this.registrationNumber,
    required this.fullName,
    this.status = 'Present',
    this.participationScore = 0,
    this.disciplineScore = 0,
    this.preparationScore = 0,
    this.notes = '',
    this.saved = false,
  });
}

// ═══════════════════════════════════════════════════════════
//  AttendanceFlowScreen
// ═══════════════════════════════════════════════════════════
class AttendanceFlowScreen extends StatefulWidget {
  final int classId;
  final String className;
  final int sessionId;

  const AttendanceFlowScreen({
    super.key,
    required this.classId,
    required this.className,
    required this.sessionId,
  });

  @override
  State<AttendanceFlowScreen> createState() => _AttendanceFlowScreenState();
}

class _AttendanceFlowScreenState extends State<AttendanceFlowScreen>
    with SingleTickerProviderStateMixin {
  List<_StudentRecord> _students = [];
  int _currentIndex = 0;
  bool _loading = true;
  bool _saving = false;

  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOut,
    );
    _load();
  }

  @override
  void dispose() {
    _animController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // ── Load data ─────────────────────────────────────────────────────────────
  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      // ✅ getStudentsByClass من vw_Ordered_Students_By_Class
      // ✅ getAttendanceForSession يرجع Map<regNum, record>
      final rawStudents = await DBHelper.getStudentsByClass(widget.classId);
      final existing = await DBHelper.getAttendanceForSession(widget.sessionId);

      _students = rawStudents.map((s) {
        final reg = s['registration_number'] as String;
        final prev = existing[reg];
        return _StudentRecord(
          registrationNumber: reg,
          fullName: s['full_name'] as String? ?? '',
          status: prev?['status'] as String? ?? 'Present',
          participationScore: (prev?['participation_score'] as int?) ?? 0,
          disciplineScore: (prev?['discipline_score'] as int?) ?? 0,
          preparationScore: (prev?['preparation_score'] as int?) ?? 0,
          notes: prev?['notes'] as String? ?? '',
          saved: prev != null,
        );
      }).toList();

      // ابدأ من أول طالب غير محفوظ
      _currentIndex = _students.indexWhere((s) => !s.saved);
      if (_currentIndex == -1) _currentIndex = _students.length - 1;

      _syncNotes();
      setState(() => _loading = false);
      _animController.forward(from: 0);
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  void _syncNotes() => _notesController.text = _current.notes;
  _StudentRecord get _current => _students[_currentIndex];

  // ── Navigation ────────────────────────────────────────────────────────────
  Future<void> _goTo(int index) async {
    await _saveCurrent();
    await _animController.reverse();
    setState(() {
      _currentIndex = index;
      _syncNotes();
    });
    await _animController.forward(from: 0);
  }

  Future<void> _next() async {
    if (_currentIndex < _students.length - 1) await _goTo(_currentIndex + 1);
  }

  Future<void> _prev() async {
    if (_currentIndex > 0) await _goTo(_currentIndex - 1);
  }

  // ── Save ──────────────────────────────────────────────────────────────────
  Future<void> _saveCurrent() async {
    final s = _current;
    s.notes = _notesController.text;
    try {
      await DBHelper.upsertAttendance(
        sessionId: widget.sessionId,
        registrationNumber: s.registrationNumber,
        status: s.status,
        notes: s.notes,
        participationScore: s.participationScore,
        disciplineScore: s.disciplineScore,
        preparationScore: s.preparationScore,
      );
      setState(() => s.saved = true);
    } catch (_) {}
  }

  Future<void> _finishSession() async {
    setState(() => _saving = true);
    await _saveCurrent();

    // حفظ الطلبة الباقيين بـ Transaction
    await DBHelper.batchUpsertAttendance(
      widget.sessionId,
      _students
          .map(
            (s) => {
              'registration_number': s.registrationNumber,
              'status': s.status,
              'notes': s.notes,
              'participation_score': s.participationScore,
              'discipline_score': s.disciplineScore,
              'preparation_score': s.preparationScore,
            },
          )
          .toList(),
    );

    await DBHelper.updateSessionStatus(widget.sessionId, 'Completed');

    if (mounted) {
      setState(() => _saving = false);
      Navigator.pop(context);
    }
  }

  // ── Color helpers ─────────────────────────────────────────────────────────
  Color _statusColor(String s) {
    switch (s) {
      case 'Present':
        return AppColors.success;
      case 'Absent':
        return AppColors.danger;
      case 'Late':
        return AppColors.warning;
      case 'Excused':
        return const Color(0xFF7C3AED);
      default:
        return AppColors.textMuted;
    }
  }

  Color _statusBg(String s) {
    switch (s) {
      case 'Present':
        return AppColors.successBg;
      case 'Absent':
        return AppColors.dangerBg;
      case 'Late':
        return AppColors.warningBg;
      case 'Excused':
        return const Color(0xFFEDE9FE);
      default:
        return AppColors.divider;
    }
  }

  IconData _statusIcon(String s) {
    switch (s) {
      case 'Present':
        return Icons.check_circle;
      case 'Absent':
        return Icons.cancel;
      case 'Late':
        return Icons.watch_later;
      case 'Excused':
        return Icons.info;
      default:
        return Icons.circle_outlined;
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: AppColors.bg,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }
    if (_students.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.bg,
        appBar: _appBar(),
        body: Center(
          child: Text(
            'No students enrolled in this class.',
            style: GoogleFonts.lexend(color: AppColors.textMuted),
          ),
        ),
      );
    }

    final total = _students.length;
    final done = _students.where((s) => s.saved).length;
    final progress = total > 0 ? done / total : 0.0;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: _appBar(),
      body: Column(
        children: [
          _progressHeader(done, total, progress),
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: Column(
                  children: [
                    _studentCard(),
                    const SizedBox(height: 16),
                    _statusPicker(),
                    const SizedBox(height: 16),
                    if (_current.status == 'Present') ...[
                      _scoresSection(),
                      const SizedBox(height: 16),
                    ],
                    _notesField(),
                    const SizedBox(height: 24),
                    _navRow(total),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  AppBar _appBar() => AppBar(
    backgroundColor: AppColors.bg,
    elevation: 0,
    leading: IconButton(
      icon: const Icon(Icons.arrow_back, color: AppColors.textMain),
      onPressed: () async {
        await _saveCurrent();
        if (mounted) Navigator.pop(context);
      },
    ),
    title: Text(
      widget.className,
      style: GoogleFonts.lexend(
        color: AppColors.textMain,
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
    ),
    actions: [
      if (_saving)
        const Padding(
          padding: EdgeInsets.all(14),
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary,
            ),
          ),
        )
      else
        TextButton(
          onPressed: _finishSession,
          child: Text(
            'Finish',
            style: GoogleFonts.lexend(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
    ],
  );

  // ── Progress Header ───────────────────────────────────────────────────────
  Widget _progressHeader(int done, int total, double progress) => Container(
    padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
    color: AppColors.bg,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Student ${_currentIndex + 1} of $total',
              style: GoogleFonts.lexend(
                color: AppColors.textSub,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            const Spacer(),
            Text(
              '$done recorded',
              style: GoogleFonts.lexend(
                color: AppColors.textMuted,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: AppColors.border,
            valueColor: AlwaysStoppedAnimation<Color>(
              progress == 1.0 ? AppColors.success : AppColors.primary,
            ),
          ),
        ),
      ],
    ),
  );

  // ── Student Card ──────────────────────────────────────────────────────────
  Widget _studentCard() {
    final s = _current;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _statusColor(s.status).withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: _statusColor(s.status).withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: _statusBg(s.status),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                s.fullName.isNotEmpty ? s.fullName[0].toUpperCase() : '?',
                style: GoogleFonts.lexend(
                  color: _statusColor(s.status),
                  fontWeight: FontWeight.bold,
                  fontSize: 26,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            s.fullName,
            style: GoogleFonts.lexend(
              fontWeight: FontWeight.bold,
              color: AppColors.textMain,
              fontSize: 18,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            s.registrationNumber,
            style: GoogleFonts.lexend(color: AppColors.textMuted, fontSize: 12),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _statusBg(s.status),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _statusIcon(s.status),
                  color: _statusColor(s.status),
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  s.status,
                  style: GoogleFonts.lexend(
                    color: _statusColor(s.status),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Status Picker ─────────────────────────────────────────────────────────
  Widget _statusPicker() {
    const statuses = ['Present', 'Absent', 'Late', 'Excused'];
    return Row(
      children: statuses.map((st) {
        final selected = _current.status == st;
        return Expanded(
          child: GestureDetector(
            onTap: () async {
              HapticFeedback.lightImpact();
              setState(() => _current.status = st);
              await _saveCurrent();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: selected ? _statusColor(st) : AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selected ? _statusColor(st) : AppColors.border,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    _statusIcon(st),
                    color: selected ? Colors.white : _statusColor(st),
                    size: 20,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    st,
                    style: GoogleFonts.lexend(
                      color: selected ? Colors.white : AppColors.textSub,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Scores ────────────────────────────────────────────────────────────────
  Widget _scoresSection() => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Evaluation  (0 – 10)',
          style: GoogleFonts.lexend(
            fontWeight: FontWeight.bold,
            color: AppColors.textMain,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 14),
        _scoreRow(
          'Participation',
          Icons.record_voice_over_outlined,
          _current.participationScore,
          (v) => setState(() => _current.participationScore = v),
        ),
        const SizedBox(height: 10),
        _scoreRow(
          'Discipline',
          Icons.shield_outlined,
          _current.disciplineScore,
          (v) => setState(() => _current.disciplineScore = v),
        ),
        const SizedBox(height: 10),
        _scoreRow(
          'Preparation',
          Icons.book_outlined,
          _current.preparationScore,
          (v) => setState(() => _current.preparationScore = v),
        ),
      ],
    ),
  );

  Widget _scoreRow(
    String label,
    IconData icon,
    int value,
    ValueChanged<int> onChange,
  ) => Row(
    children: [
      Icon(icon, size: 16, color: AppColors.textMuted),
      const SizedBox(width: 8),
      SizedBox(
        width: 96,
        child: Text(
          label,
          style: GoogleFonts.lexend(color: AppColors.textSub, fontSize: 12),
        ),
      ),
      Expanded(
        child: Row(
          children: List.generate(11, (i) {
            final sel = i == value;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  onChange(i);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  margin: const EdgeInsets.symmetric(horizontal: 1.5),
                  height: 28,
                  decoration: BoxDecoration(
                    color: sel ? AppColors.primary : AppColors.divider,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Text(
                      '$i',
                      style: GoogleFonts.lexend(
                        color: sel ? Colors.white : AppColors.textMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    ],
  );

  // ── Notes ─────────────────────────────────────────────────────────────────
  Widget _notesField() => Container(
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.border),
    ),
    child: TextField(
      controller: _notesController,
      maxLines: 2,
      style: GoogleFonts.lexend(color: AppColors.textMain, fontSize: 13),
      decoration: InputDecoration(
        hintText: 'Add a note (optional)...',
        hintStyle: GoogleFonts.lexend(color: AppColors.textMuted, fontSize: 13),
        prefixIcon: const Icon(
          Icons.notes_outlined,
          size: 18,
          color: AppColors.textMuted,
        ),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      onChanged: (v) => _current.notes = v,
    ),
  );

  // ── Navigation Row ────────────────────────────────────────────────────────
  Widget _navRow(int total) {
    final isFirst = _currentIndex == 0;
    final isLast = _currentIndex == total - 1;

    return Row(
      children: [
        // ✅ Previous — يرجع للطالب السابق لتصحيح الخطأ
        Expanded(
          child: GestureDetector(
            onTap: isFirst ? null : _prev,
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: isFirst ? AppColors.divider : AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.arrow_back,
                    size: 18,
                    color: isFirst ? AppColors.textMuted : AppColors.textSub,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Previous',
                    style: GoogleFonts.lexend(
                      color: isFirst ? AppColors.textMuted : AppColors.textSub,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // ✅ Next / Finish
        Expanded(
          child: GestureDetector(
            onTap: isLast ? _finishSession : _next,
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: isLast ? AppColors.success : AppColors.primary,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isLast ? 'Finish' : 'Next',
                    style: GoogleFonts.lexend(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    isLast ? Icons.check : Icons.arrow_forward,
                    size: 18,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
