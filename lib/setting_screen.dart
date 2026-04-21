import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // 🎨 نفس الـ palette
  static const Color primary = Color(0xFF2563EB);
  static const Color bg = Color(0xFFF8FAFC);
  static const Color cardBg = Colors.white;
  static const Color border = Color(0xFFE2E8F0);

  static const Color textMain = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF64748B);

  bool notifications = true;
  bool darkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,

      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        title: Text(
          "Settings",
          style: GoogleFonts.lexend(
            color: textMain,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(color: textMain),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ⚙️ GENERAL
            _sectionTitle("General"),

            Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: border),
              ),
              child: Column(
                children: [
                  _switchTile(
                    title: "Notifications",
                    value: notifications,
                    onChanged: (v) {
                      setState(() => notifications = v);
                    },
                  ),
                  const Divider(height: 0),
                  _switchTile(
                    title: "Dark Mode",
                    value: darkMode,
                    onChanged: (v) {
                      setState(() => darkMode = v);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 📄 ACCOUNT
            _sectionTitle("Account"),

            Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: border),
              ),
              child: Column(
                children: [
                  _tile("Profile", Icons.person, () {
                    Navigator.pushNamed(context, '/profile');
                  }),
                  const Divider(height: 0),
                  _tile("Change Password", Icons.lock, () {}),
                ],
              ),
            ),

            const Spacer(),

            // 🚪 LOGOUT
            SizedBox(
              width: double.infinity,
              height: 55,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login',
                    (route) => false,
                  );
                },
                child: const Text("LOG OUT"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 Section Title
  Widget _sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          title,
          style: GoogleFonts.lexend(fontSize: 14, color: textMuted),
        ),
      ),
    );
  }

  // 🔹 Switch Tile
  Widget _switchTile({
    required String title,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return SwitchListTile(
      title: Text(title, style: GoogleFonts.lexend(color: textMain)),
      value: value,
      activeColor: primary,
      onChanged: onChanged,
    );
  }

  // 🔹 Normal Tile
  Widget _tile(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: primary),
      title: Text(
        title,
        style: GoogleFonts.lexend(color: textMain, fontWeight: FontWeight.w500),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
