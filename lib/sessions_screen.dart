import 'package:flutter/material.dart';

class SessionsScreen extends StatelessWidget {
  final String day;
  final String time;

  const SessionsScreen({super.key, required this.day, required this.time});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("Sessions - $day ($time)"),
      ),

      body: ListView(
        children: [
          _buildSessionItem(context, "Math"),
          _buildSessionItem(context, "Physics"),
        ],
      ),
    );
  }

  Widget _buildSessionItem(BuildContext context, String subject) {
    return ListTile(
      title: Text(subject, style: const TextStyle(color: Colors.white)),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white38),
      onTap: () {
        Navigator.pushNamed(context, '/attendance');
      },
    );
  }
}
