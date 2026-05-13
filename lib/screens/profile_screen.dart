import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:attendance_app/database/db_helper.dart';
import 'package:attendance_app/app_colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _teacherName = 'Professor';
  int _teacherId = 1;
  bool _loading = true;
  int _totalSessions = 0;
  int _totalClasses = 0;
  int _totalStudents = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      _teacherId = prefs.getInt('teacherId') ?? 1;
      final row = await DBHelper.getTeacherById(_teacherId);
      _teacherName =
          row?['full_name'] as String? ?? prefs.getString('teacherName') ?? 'Professor';

      final dbClient = await DBHelper.db;
      final sessions = await dbClient.rawQuery(
        "SELECT COUNT(*) AS cnt FROM Sessions WHERE status = ?",
        ['Completed'],
      );
      final classes = await dbClient.rawQuery(
        'SELECT COUNT(DISTINCT class_id) AS cnt FROM Teacher_Timetable WHERE teacher_id = ?',
        [_teacherId],
      );
      final students = await dbClient.rawQuery(
        '''SELECT COUNT(DISTINCT se.registration_number) AS cnt
           FROM Student_Enrollment se
           JOIN Teacher_Timetable tt ON se.class_id = tt.class_id
           WHERE tt.teacher_id = ?''',
        [_teacherId],
      );

      int n(dynamic v) => v is int ? v : (v as num?)?.toInt() ?? 0;

      setState(() {
        _totalSessions = n(sessions.first['cnt']);
        _totalClasses = n(classes.first['cnt']);
        _totalStudents = n(students.first['cnt']);
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  String _initials() {
    final parts =
        _teacherName.replaceAll('Dr.', '').replaceAll('Dr ', '').trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    if (parts.isNotEmpty && parts[0].isNotEmpty) return parts[0][0].toUpperCase();
    return '?';
  }

  Future<void> _editName() async {
    final ctrl = TextEditingController(text: _teacherName);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Edit name', style: GoogleFonts.lexend(fontWeight: FontWeight.bold)),
        content: TextField(controller: ctrl, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Save')),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final name = ctrl.text.trim();
    if (name.isEmpty) return;
    try {
      await DBHelper.updateTeacherFullName(_teacherId, name);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('teacherName', name);
      setState(() => _teacherName = name);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Saved', style: GoogleFonts.lexend())),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e', style: GoogleFonts.lexend())),
        );
      }
    }
  }

  Future<void> _changePassword() async {
    final p1 = TextEditingController();
    final p2 = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('App password', style: GoogleFonts.lexend(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: p1, obscureText: true, decoration: const InputDecoration(labelText: 'New')),
            TextField(controller: p2, obscureText: true, decoration: const InputDecoration(labelText: 'Confirm')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('teacher_password_$_teacherId');
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Clear'),
          ),
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Save')),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    if (p1.text.trim() != p2.text.trim() || p1.text.trim().isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('teacher_password_$_teacherId', p1.text.trim());
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password saved on device', style: GoogleFonts.lexend())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        title: Text('Profile', style: GoogleFonts.lexend(fontWeight: FontWeight.bold)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  CircleAvatar(radius: 40, child: Text(_initials(), style: GoogleFonts.lexend(fontSize: 22))),
                  const SizedBox(height: 12),
                  Text(_teacherName, style: GoogleFonts.lexend(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('ID $_teacherId', style: GoogleFonts.lexend(color: AppColors.textMuted)),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _chip('$_totalSessions', 'Sessions'),
                      _chip('$_totalClasses', 'Classes'),
                      _chip('$_totalStudents', 'Students'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(onPressed: _editName, child: const Text('Edit name (database)')),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(onPressed: _changePassword, child: const Text('Change login password')),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _chip(String v, String l) => Column(
        children: [
          Text(v, style: GoogleFonts.lexend(fontWeight: FontWeight.bold, fontSize: 18)),
          Text(l, style: GoogleFonts.lexend(fontSize: 12, color: AppColors.textMuted)),
        ],
      );
}
