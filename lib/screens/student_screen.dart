import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_colors.dart';
import '../database/db_helper.dart';

class StudentsScreen extends StatefulWidget {
  final int classId;
  final String className;

  const StudentsScreen({
    super.key,
    required this.classId,
    required this.className,
  });

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  List<Map<String, dynamic>> _all = [];
  List<Map<String, dynamic>> _filtered = [];
  bool _loading = true;
  final _search = TextEditingController();

  // ── Avatar colors — مطابق للصورة (ألوان متنوعة) ──────────────────────────
  static const _avatarColors = [
    Color(0xFFE0E7FF), // indigo light
    Color(0xFFDCFCE7), // green light
    Color(0xFFEDE9FE), // purple light
    Color(0xFFCFFAFE), // cyan light
    Color(0xFFFEF3C7), // amber light
    Color(0xFFFFE4E6), // rose light
  ];
  static const _avatarTextColors = [
    Color(0xFF4338CA),
    Color(0xFF16A34A),
    Color(0xFF7C3AED),
    Color(0xFF0891B2),
    Color(0xFFD97706),
    Color(0xFFE11D48),
  ];

  @override
  void initState() {
    super.initState();
    _load();
    _search.addListener(_onSearch);
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await DBHelper.getStudentsByClass(widget.classId);
      setState(() {
        _all = data;
        _filtered = data;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  void _onSearch() {
    final q = _search.text.toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? _all
          : _all.where((s) {
              final name = (s['full_name'] ?? '').toString().toLowerCase();
              final reg = (s['registration_number'] ?? '')
                  .toString()
                  .toLowerCase();
              return name.contains(q) || reg.contains(q);
            }).toList();
    });
  }

  // ── Add Student ───────────────────────────────────────────────────────────
  void _showAddDialog() {
    final regCtrl = TextEditingController();
    final firstCtrl = TextEditingController();
    final lastCtrl = TextEditingController();
    String? err;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Add Student',
                style: GoogleFonts.lexend(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textMain,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 20),
              _sheetField(regCtrl, 'Registration Number', Icons.badge_outlined),
              const SizedBox(height: 12),
              _sheetField(firstCtrl, 'First Name', Icons.person_outline),
              const SizedBox(height: 12),
              _sheetField(lastCtrl, 'Last Name', Icons.person_outline),
              if (err != null) ...[
                const SizedBox(height: 8),
                Text(
                  err!,
                  style: const TextStyle(color: AppColors.danger, fontSize: 13),
                ),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () async {
                    final reg = regCtrl.text.trim();
                    final first = firstCtrl.text.trim();
                    final last = lastCtrl.text.trim();
                    if (reg.isEmpty || first.isEmpty || last.isEmpty) {
                      setS(() => err = 'Please fill all fields');
                      return;
                    }
                    await DBHelper.insertStudentWithEnrollment(
                      registrationNumber: reg,
                      firstName: first,
                      lastName: last,
                      classId: widget.classId,
                    );
                    Navigator.pop(ctx);
                    _load();
                  },
                  child: Text(
                    'Add Student',
                    style: GoogleFonts.lexend(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Edit Student ──────────────────────────────────────────────────────────
  void _showEditDialog(Map<String, dynamic> s) {
    final firstCtrl = TextEditingController(text: s['first_name'] ?? '');
    final lastCtrl = TextEditingController(text: s['last_name'] ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          left: 20,
          right: 20,
          top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Edit Student',
              style: GoogleFonts.lexend(
                fontWeight: FontWeight.bold,
                color: AppColors.textMain,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              s['registration_number'] ?? '',
              style: GoogleFonts.lexend(
                color: AppColors.textMuted,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 20),
            _sheetField(firstCtrl, 'First Name', Icons.person_outline),
            const SizedBox(height: 12),
            _sheetField(lastCtrl, 'Last Name', Icons.person_outline),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                onPressed: () async {
                  final db = await DBHelper.db;
                  await db.update(
                    'Students',
                    {
                      'first_name': firstCtrl.text.trim(),
                      'last_name': lastCtrl.text.trim(),
                    },
                    where: 'registration_number = ?',
                    whereArgs: [s['registration_number']],
                  );
                  Navigator.pop(ctx);
                  _load();
                },
                child: Text(
                  'Save',
                  style: GoogleFonts.lexend(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Delete ────────────────────────────────────────────────────────────────
  void _confirmDelete(Map<String, dynamic> s) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete Student',
          style: GoogleFonts.lexend(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Remove ${s['full_name']} from this class?',
          style: GoogleFonts.lexend(color: AppColors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.lexend(color: AppColors.textMuted),
            ),
          ),
          TextButton(
            onPressed: () async {
              final db = await DBHelper.db;
              await db.delete(
                'Student_Enrollment',
                where: 'registration_number = ? AND class_id = ?',
                whereArgs: [s['registration_number'], widget.classId],
              );
              Navigator.pop(context);
              _load();
            },
            child: Text(
              'Delete',
              style: GoogleFonts.lexend(
                color: AppColors.danger,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.className,
              style: GoogleFonts.lexend(
                fontWeight: FontWeight.bold,
                color: AppColors.textMain,
                fontSize: 18,
              ),
            ),
            Text(
              '${_all.length} students',
              style: GoogleFonts.lexend(color: AppColors.primary, fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.person_add_outlined,
              color: AppColors.primary,
            ),
            onPressed: _showAddDialog,
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : Column(
              children: [
                // ── Search Bar ──────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.divider,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: TextField(
                      controller: _search,
                      style: GoogleFonts.lexend(
                        color: AppColors.textMain,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search by name or reg number...',
                        hintStyle: GoogleFonts.lexend(
                          color: AppColors.textMuted,
                          fontSize: 14,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: AppColors.textMuted,
                          size: 20,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                ),

                // ── List ────────────────────────────────────────────────────
                Expanded(
                  child: _filtered.isEmpty
                      ? Center(
                          child: Text(
                            'No students found',
                            style: GoogleFonts.lexend(
                              color: AppColors.textMuted,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
                          itemCount: _filtered.length,
                          itemBuilder: (_, i) => _studentCard(_filtered[i], i),
                        ),
                ),
              ],
            ),

      // ── FAB — Add Student ────────────────────────────────────────────────
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: Text(
          'Add Student',
          style: GoogleFonts.lexend(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _studentCard(Map<String, dynamic> s, int index) {
    final colorIdx = index % _avatarColors.length;
    final name = s['full_name'] as String? ?? '—';
    final reg = s['registration_number'] as String? ?? '';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // ── Avatar ──────────────────────────────────────────────────────
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _avatarColors[colorIdx],
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                initial,
                style: TextStyle(
                  color: _avatarTextColors[colorIdx],
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // ── Name + Reg ───────────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.lexend(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMain,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  reg,
                  style: GoogleFonts.lexend(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // ── Edit ────────────────────────────────────────────────────────
          IconButton(
            icon: const Icon(
              Icons.edit_outlined,
              color: AppColors.textMuted,
              size: 20,
            ),
            onPressed: () => _showEditDialog(s),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),

          // ── Delete ───────────────────────────────────────────────────────
          IconButton(
            icon: const Icon(
              Icons.delete_outline,
              color: AppColors.danger,
              size: 20,
            ),
            onPressed: () => _confirmDelete(s),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
        ],
      ),
    );
  }

  Widget _sheetField(TextEditingController ctrl, String hint, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.divider,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: TextField(
        controller: ctrl,
        style: GoogleFonts.lexend(color: AppColors.textMain, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.lexend(
            color: AppColors.textMuted,
            fontSize: 14,
          ),
          prefixIcon: Icon(icon, color: AppColors.textMuted, size: 18),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}
