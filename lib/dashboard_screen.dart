import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'attendance_list_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  static const Color primaryBlue = Color(0xFF2A7BF1);
  static const Color textMain = Color(0xFF1F2937);
  static const Color textMuted = Color(0xFF6B7280);
  static const Color cardBg = Color(0xFFF3F4F6);
  static const Color border = Color(0xFFE5E7EB);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        title: Text(
          "ATTENDIX",
          style: GoogleFonts.lexend(
            color: textMain,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
            icon: const Icon(Icons.settings, color: textMain),
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF8FAFC), Color(0xFFF1F5F9)],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 👤 HEADER (Notion style clickable)
              InkWell(
                onTap: () {
                  Navigator.pushNamed(context, '/profile');
                },
                borderRadius: BorderRadius.circular(20),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: primaryBlue.withOpacity(0.1),
                      child: const Icon(Icons.person, color: primaryBlue),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Good Morning 👋",
                          style: GoogleFonts.lexend(
                            fontSize: 14,
                            color: textMuted,
                          ),
                        ),
                        Text(
                          "Professor",
                          style: GoogleFonts.lexend(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textMain,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // 🔄 Sync
              Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 16),
                  const SizedBox(width: 6),
                  Text("Synced", style: GoogleFonts.lexend(color: textMuted)),
                ],
              ),

              const SizedBox(height: 24),

              // 📊 STATS
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 1.4,
                children: [
                  _statCard("Students", "328", Icons.people_outline),
                  _statCard("Classes", "4", Icons.book_outlined),
                  _statCard("Sessions", "24", Icons.calendar_today),
                  _statCard("Pending", "12", Icons.pending_actions),
                ],
              ),

              const SizedBox(height: 28),

              // ⚡ Quick Actions
              Text(
                "Quick Actions",
                style: GoogleFonts.lexend(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textMain,
                ),
              ),

              const SizedBox(height: 14),

              _actionButton("Take Attendance", Icons.edit, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AttendanceListScreen(),
                  ),
                );
              }),

              const SizedBox(height: 10),

              _actionButton("Manage Classes", Icons.folder_open, () {
                Navigator.pushNamed(context, '/classes');
              }),

              const SizedBox(height: 10),

              _actionButton(
                "Export to Drive",
                Icons.cloud_upload_outlined,
                () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 📊 Stat Card
  Widget _statCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: primaryBlue, size: 22),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.lexend(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textMain,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.lexend(color: textMuted, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // ⚡ Action Button
  Widget _actionButton(String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: border),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, color: primaryBlue, size: 22),
            const SizedBox(width: 14),
            Text(
              title,
              style: GoogleFonts.lexend(
                fontWeight: FontWeight.w600,
                color: textMain,
              ),
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
