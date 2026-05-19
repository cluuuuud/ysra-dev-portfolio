import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_colors.dart';
import '../database/db_helper.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // ── بيانات الأستاذ (ثابتة — يمكن ربطها بـ SharedPreferences لاحقاً) ──
  static const _name = 'Dr Amri Said';
  static const _role = 'Professor · Computer Science';
  static const _university = 'University of M\'sila';
  static const _department = 'Computer Science';
  static const _roleDetail = 'Professor (TD)';
  static const _year = '2025–2026';

  // ── إحصائيات من DB ───────────────────────────────────────────────────────
  int _sessions = 0;
  int _classes = 0;
  int _students = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final db = await DBHelper.db;

      final sessRes = await db.rawQuery("SELECT COUNT(*) AS cnt FROM Sessions");
      final clsRes = await db.rawQuery("SELECT COUNT(*) AS cnt FROM Classes");
      final stuRes = await db.rawQuery(
        "SELECT COUNT(*) AS cnt FROM Students WHERE status = 'active'",
      );

      setState(() {
        _sessions = (sessRes.first['cnt'] as int?) ?? 0;
        _classes = (clsRes.first['cnt'] as int?) ?? 0;
        _students = (stuRes.first['cnt'] as int?) ?? 0;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  // ── initials ──────────────────────────────────────────────────────────────
  String get _initials {
    final parts = _name.split(' ');
    if (parts.length >= 2) {
      return '${parts[parts.length - 2][0]}${parts.last[0]}';
    }
    return parts.first.substring(0, 2).toUpperCase();
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
          'Profile',
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
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // ── Profile Card ──────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      // Avatar
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: AppColors.primaryBg,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            _initials,
                            style: GoogleFonts.lexend(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Name
                      Text(
                        _name,
                        style: GoogleFonts.lexend(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textMain,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _role,
                        style: GoogleFonts.lexend(
                          color: AppColors.textMuted,
                          fontSize: 13,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Stats row
                      Row(
                        children: [
                          _statCol('$_sessions', 'Sessions'),
                          _vDiv(),
                          _statCol('$_classes', 'Classes'),
                          _vDiv(),
                          _statCol('$_students', 'Students'),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ── Info Card ─────────────────────────────────────────────
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      _infoRow(
                        Icons.school_outlined,
                        'University',
                        _university,
                      ),
                      _divider(),
                      _infoRow(
                        Icons.laptop_outlined,
                        'Department',
                        _department,
                      ),
                      _divider(),
                      _infoRow(Icons.badge_outlined, 'Role', _roleDetail),
                      _divider(),
                      _infoRow(
                        Icons.calendar_today_outlined,
                        'Academic Year',
                        _year,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ── Edit Profile Button ───────────────────────────────────
                OutlinedButton.icon(
                  onPressed: () {
                    // TODO: navigate to edit profile
                  },
                  icon: const Icon(
                    Icons.edit_outlined,
                    color: AppColors.primary,
                    size: 18,
                  ),
                  label: Text(
                    'Edit Profile',
                    style: GoogleFonts.lexend(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 52),
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  Widget _statCol(String value, String label) => Expanded(
    child: Column(
      children: [
        Text(
          value,
          style: GoogleFonts.lexend(
            fontWeight: FontWeight.bold,
            color: AppColors.textMain,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.lexend(color: AppColors.textMuted, fontSize: 12),
        ),
      ],
    ),
  );

  Widget _vDiv() => Container(width: 1, height: 36, color: AppColors.border);

  Widget _divider() =>
      Divider(height: 1, thickness: 1, color: AppColors.border, indent: 56);

  Widget _infoRow(IconData icon, String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    child: Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textMuted),
        const SizedBox(width: 14),
        Text(
          label,
          style: GoogleFonts.lexend(color: AppColors.textMuted, fontSize: 14),
        ),
        const Spacer(),
        Text(
          value,
          style: GoogleFonts.lexend(
            fontWeight: FontWeight.w600,
            color: AppColors.textMain,
            fontSize: 14,
          ),
        ),
      ],
    ),
  );
}
