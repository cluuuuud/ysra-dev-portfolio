import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:attendance_app/database/db_helper.dart';
import 'package:attendance_app/app_colors.dart';
import 'package:attendance_app/screens/session_details_screen.dart';

class SessionHistoryScreen extends StatelessWidget {
  const SessionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        title: Text('Session history', style: GoogleFonts.lexend(fontWeight: FontWeight.bold)),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: DBHelper.getRecentSessions(),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final list = snap.data!;
          if (list.isEmpty) return Center(child: Text('No sessions', style: GoogleFonts.lexend()));
          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (_, i) {
              final s = list[i];
              return ListTile(
                title: Text('${s['subject_name'] ?? s['session_id']}', style: GoogleFonts.lexend()),
                subtitle: Text('${s['session_status'] ?? ''} · ${s['session_date'] ?? ''}'),
                onTap: () {
                  final id = DBHelper.parseId(s['session_id']);
                  if (id == null) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SessionDetailsScreen(sessionId: id),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
