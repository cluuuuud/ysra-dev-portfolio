import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:attendance_app/database/db_helper.dart';
import 'package:attendance_app/app_colors.dart';

class TimetableScreen extends StatefulWidget {
  const TimetableScreen({super.key});

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  List<Map<String, dynamic>> _rows = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final d = await DBHelper.getWeeklySchedule();
      setState(() {
        _rows = d;
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
        title: Text(
          'Timetable',
          style: GoogleFonts.lexend(fontWeight: FontWeight.bold),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _rows.length,
              itemBuilder: (_, i) {
                final r = _rows[i];
                return ListTile(
                  title: Text(
                    '${r['subject_name']}',
                    style: GoogleFonts.lexend(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    '${r['day_of_week']} ${r['start_time']}-${r['end_time']} · ${r['session_type']}',
                    style: GoogleFonts.lexend(
                      fontSize: 13,
                      color: AppColors.textMuted,
                    ),
                  ),
                );
              },
            ),
    );
  }
}
