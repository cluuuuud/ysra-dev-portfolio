import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:attendance_app/database/db_helper.dart';
import 'package:attendance_app/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _hidden = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailCtrl.text.trim();
    final pass = _passwordCtrl.text.trim();
    if (email.isEmpty || pass.isEmpty) {
      setState(() => _error = 'Please fill all fields');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final teachers = await DBHelper.getAllTeachers();
      final prefs = await SharedPreferences.getInstance();
      Map<String, dynamic>? matched;

      for (final t in teachers) {
        final full = t['full_name'] as String? ?? '';
        final parts = full
            .replaceAll('Dr ', '')
            .replaceAll('Dr. ', '')
            .trim()
            .split(' ');
        final lastName = parts.isNotEmpty ? parts.last : '';
        final firstName = parts.length > 1 ? parts.first : '';
        if (lastName.isEmpty || firstName.isEmpty) continue;

        final expEmail = '${lastName.toLowerCase()}@gmail.com';
        final altEmail = '${firstName.toLowerCase()}@gmail.com';
        final expPass =
            '${lastName[0].toUpperCase()}${lastName.substring(1).toLowerCase()}'
            '${firstName[0].toUpperCase()}${firstName.substring(1).toLowerCase()}';

        final emailOk =
            email.toLowerCase() == expEmail || email.toLowerCase() == altEmail;
        if (!emailOk) continue;

        final tid = DBHelper.parseId(t['teacher_id']);
        if (tid == null) continue;
        final override = prefs.getString('teacher_password_$tid');
        if (override != null && override.isNotEmpty) {
          if (pass == override) {
            matched = t;
            break;
          }
        } else if (pass == expPass) {
          matched = t;
          break;
        }
      }

      if (matched == null &&
          email == 'abdessettar@gmail.com' &&
          pass == 'GhemouguiAbdessettar') {
        matched = teachers.isNotEmpty
            ? teachers.first
            : {'teacher_id': 1, 'full_name': 'Dr Ghemougui Abdessettar'};
      }

      if (matched != null) {
        final prefs2 = await SharedPreferences.getInstance();
        await prefs2.setBool('isLogged', true);
        final mid = DBHelper.parseId(matched['teacher_id']) ?? 1;
        await prefs2.setInt('teacherId', mid);
        await prefs2.setString(
          'teacherName',
          matched['full_name'] as String? ?? 'Professor',
        );
        if (mounted) Navigator.pushReplacementNamed(context, '/dashboard');
      } else {
        setState(() => _error = 'Wrong email or password');
      }
    } catch (_) {
      setState(() => _error = 'An error occurred. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

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
              const SizedBox(height: 48),
              Text(
                'Welcome back',
                style: GoogleFonts.lexend(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textMain,
                ),
              ),
              const SizedBox(height: 32),
              Text('Email', style: GoogleFonts.lexend(color: AppColors.textMuted)),
              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              Text('Password', style: GoogleFonts.lexend(color: AppColors.textMuted)),
              TextField(
                controller: _passwordCtrl,
                obscureText: _hidden,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(_hidden ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _hidden = !_hidden),
                  ),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: GoogleFonts.lexend(color: AppColors.danger)),
              ],
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: _loading ? null : _login,
                  child: _loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text('Sign in', style: GoogleFonts.lexend()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
