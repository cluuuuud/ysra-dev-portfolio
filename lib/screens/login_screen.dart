import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_colors.dart';

// ═══════════════════════════════════════════════════════════
//  LoginScreen — Notion / SaaS style — يتطابق مع بقية الشاشات
//  NOTE: التطبيق لا يحتاج جدول Users — اللوجين محلي ثابت
//        (email: admin  /  password: 1234)
//        لاحقاً يمكن ربطه بـ DBHelper.loginUser إذا أُضيف الجدول
// ═══════════════════════════════════════════════════════════
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _passwordHidden = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ── Login logic ───────────────────────────────────────────────────────────
  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = "Please fill all fields");
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    // ── بيانات ثابتة (محلية) ─────────────────────────────────────────────
    // عند الحاجة استبدلها بـ: final user = await DBHelper.loginUser(email, password);
    await Future.delayed(const Duration(milliseconds: 600)); // تحاكي الانتظار

    if (email == "admin" && password == "1234") {
      if (mounted) Navigator.pushReplacementNamed(context, '/dashboard');
    } else {
      setState(() {
        _error = "Invalid credentials";
        _loading = false;
      });
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 56),

              // ── Logo / Brand ──────────────────────────────────────────────
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.school_outlined,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(height: 24),

              Text(
                "Welcome back",
                style: GoogleFonts.lexend(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textMain,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Sign in to manage your classes and attendance.",
                style: GoogleFonts.lexend(
                  fontSize: 14,
                  color: AppColors.textMuted,
                ),
              ),

              const SizedBox(height: 40),

              // ── Email field ───────────────────────────────────────────────
              _fieldLabel("Email / Username"),
              const SizedBox(height: 8),
              _inputField(
                controller: _emailController,
                hint: "admin",
                icon: Icons.person_outline,
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 20),

              // ── Password field ────────────────────────────────────────────
              _fieldLabel("Password"),
              const SizedBox(height: 8),
              _inputField(
                controller: _passwordController,
                hint: "••••••••",
                icon: Icons.lock_outline,
                isPassword: true,
              ),

              // ── Error ─────────────────────────────────────────────────────
              if (_error != null) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.dangerBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.danger.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: AppColors.danger,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _error!,
                        style: GoogleFonts.lexend(
                          color: AppColors.danger,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 28),

              // ── Sign In button ────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: _loading ? null : _login,
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          "Sign In",
                          style: GoogleFonts.lexend(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 16),

              // ── Hint ──────────────────────────────────────────────────────
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    "Default: admin / 1234",
                    style: GoogleFonts.lexend(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 48),

              // ── Footer ────────────────────────────────────────────────────
              Center(
                child: Text(
                  "ATTENDIX — Attendance Management",
                  style: GoogleFonts.lexend(
                    color: AppColors.textMuted,
                    fontSize: 11,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  Widget _fieldLabel(String text) => Text(
    text,
    style: GoogleFonts.lexend(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: AppColors.textSub,
    ),
  );

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword ? _passwordHidden : false,
        keyboardType: keyboardType,
        style: GoogleFonts.lexend(color: AppColors.textMain, fontSize: 14),
        onSubmitted: (_) => _login(),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.lexend(
            color: AppColors.textMuted,
            fontSize: 14,
          ),
          prefixIcon: Icon(icon, color: AppColors.textMuted, size: 20),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _passwordHidden
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppColors.textMuted,
                    size: 20,
                  ),
                  onPressed: () =>
                      setState(() => _passwordHidden = !_passwordHidden),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}
