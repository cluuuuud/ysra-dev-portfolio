import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_colors.dart';
import 'session_history_screen.dart';
import 'import_export_screen.dart';
import 'profile_screen.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  bool _notifications = true;
  bool _autoSave = true;
  bool _darkMode = false; // Coming soon

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
          'Settings',
          style: GoogleFonts.lexend(
            color: AppColors.textMain,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── Preferences ──────────────────────────────────────────────────
          _sectionLabel('Preferences'),
          const SizedBox(height: 10),
          _groupCard([
            _toggleTile(
              icon: Icons.notifications_outlined,
              title: 'Notifications',
              subtitle: 'Session reminders and alerts',
              value: _notifications,
              onChanged: (v) => setState(() => _notifications = v),
            ),
            _divider(),
            _toggleTile(
              icon: Icons.save_outlined,
              title: 'Auto-save Attendance',
              subtitle: 'Save after each student tap',
              value: _autoSave,
              onChanged: (v) => setState(() => _autoSave = v),
            ),
            _divider(),
            _toggleTile(
              icon: Icons.dark_mode_outlined,
              title: 'Dark Mode',
              subtitle: 'Coming soon',
              value: _darkMode,
              onChanged: null, // disabled — coming soon
            ),
          ]),

          const SizedBox(height: 28),

          // ── Account ───────────────────────────────────────────────────────
          _sectionLabel('Account'),
          const SizedBox(height: 10),
          _groupCard([
            _navTile(
              icon: Icons.person_outline,
              title: 'Profile',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              ),
            ),
            _divider(),
            _navTile(
              icon: Icons.lock_outline,
              title: 'Change Password',
              onTap: () {
                // TODO: navigate to change password
              },
            ),
          ]),

          const SizedBox(height: 28),

          // ── Data ──────────────────────────────────────────────────────────
          _sectionLabel('Data'),
          const SizedBox(height: 10),
          _groupCard([
            _navTile(
              icon: Icons.import_export_outlined,
              title: 'Import / Export',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ImportExportScreen()),
              ),
            ),
            _divider(),
            _navTile(
              icon: Icons.history_outlined,
              title: 'Session History',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SessionHistoryScreen()),
              ),
            ),
          ]),

          const SizedBox(height: 28),

          // ── About ─────────────────────────────────────────────────────────
          _sectionLabel('About'),
          const SizedBox(height: 10),
          _groupCard([
            _infoTile(
              icon: Icons.info_outline,
              title: 'App Version',
              value: '1.0.0',
            ),
          ]),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ── Shared builders ───────────────────────────────────────────────────────

  Widget _sectionLabel(String text) => Text(
    text,
    style: GoogleFonts.lexend(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: AppColors.textMuted,
      letterSpacing: 0.3,
    ),
  );

  Widget _groupCard(List<Widget> children) => Container(
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.border),
    ),
    child: Column(children: children),
  );

  Widget _divider() =>
      Divider(height: 1, thickness: 1, color: AppColors.border, indent: 56);

  // Toggle row
  Widget _toggleTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    ValueChanged<bool>? onChanged,
  }) {
    final disabled = onChanged == null;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 18,
              color: disabled ? AppColors.textMuted : AppColors.textSub,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.lexend(
                    fontWeight: FontWeight.w600,
                    color: disabled ? AppColors.textMuted : AppColors.textMain,
                    fontSize: 14,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.lexend(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
            inactiveThumbColor: AppColors.textMuted,
            inactiveTrackColor: AppColors.border,
          ),
        ],
      ),
    );
  }

  // Nav row (chevron)
  Widget _navTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: AppColors.textSub),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.lexend(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMain,
                  fontSize: 14,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textMuted,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  // Info row (value on right, no chevron)
  Widget _infoTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: AppColors.textSub),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.lexend(
                fontWeight: FontWeight.w600,
                color: AppColors.textMain,
                fontSize: 14,
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.lexend(color: AppColors.textMuted, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
