import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:attendance_app/database/db_helper.dart';
import 'package:attendance_app/app_colors.dart';

class SessionDetailsScreen extends StatelessWidget {
  final int sessionId;

  const SessionDetailsScreen({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        title: Text('Session $sessionId', style: GoogleFonts.lexend(fontWeight: FontWeight.bold)),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: DBHelper.getAttendanceBySession(sessionId),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final rows = snap.data!;
          return ListView.builder(
            itemCount: rows.length,
            itemBuilder: (_, i) {
              final r = rows[i];
              final name = r['full_name'] ?? '${r['first_name'] ?? ''} ${r['last_name'] ?? ''}';
              return ListTile(
                title: Text('$name', style: GoogleFonts.lexend()),
                subtitle: Text('${r['status']} · ${r['registration_number']}'),
              );
            },
          );
        },
      ),
    );
  }
}
