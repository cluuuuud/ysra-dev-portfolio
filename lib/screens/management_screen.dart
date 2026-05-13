import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:attendance_app/database/db_helper.dart';
import 'package:attendance_app/app_colors.dart';
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
        backgroundColor: AppColors.bg,
        elevation: 0,
        title: Text('Management', style: GoogleFonts.lexend(fontWeight: FontWeight.bold)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  ..._classes.map(
                    (c) => ListTile(
                      title: Text(
                        c['class_name']?.toString() ?? 'Class',
                        style: GoogleFonts.lexend(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        '${c['unilevel'] ?? ''} · ${c['total_students'] ?? 0} students',
                        style: GoogleFonts.lexend(fontSize: 12, color: AppColors.textMuted),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        final id = DBHelper.parseId(c['class_id']);
                        if (id == null) return;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => StudentsScreen(
                              classId: id,
                              className: c['class_name']?.toString() ?? 'Class',
                            ),
                          ),
                        ).then((_) => _load());
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
