import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const Color primaryBlue = Color(0xFF2A7BF1);
  static const Color fieldBg = Color(0xFFF3F4F6);
  static const Color textMain = Color(0xFF1F2937);

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isPasswordHidden = true;
  String? errorText;

  void _login() {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        errorText = "Please fill all fields";
      });
      return;
    }

    // 🔥 مؤقت (بدون backend)
    if (email == "admin" && password == "1234") {
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else {
      setState(() {
        errorText = "Invalid credentials";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: textMain),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            Text(
              "Welcome back!",
              style: GoogleFonts.lexend(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: textMain,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              "Sign in to continue managing your classes.",
              style: GoogleFonts.lexend(fontSize: 16, color: Colors.grey),
            ),

            const SizedBox(height: 40),

            /// EMAIL
            _buildInputField(
              controller: emailController,
              hint: "Professor Email",
              icon: Icons.email_outlined,
            ),

            const SizedBox(height: 20),

            /// PASSWORD
            _buildInputField(
              controller: passwordController,
              hint: "Password",
              icon: Icons.lock_outline,
              isPassword: true,
            ),

            const SizedBox(height: 10),

            /// ERROR MESSAGE
            if (errorText != null)
              Text(
                errorText!,
                style: GoogleFonts.lexend(color: Colors.red, fontSize: 14),
              ),

            const SizedBox(height: 30),

            /// BUTTON
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: _login,
                child: Text(
                  "Sign In",
                  style: GoogleFonts.lexend(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),

            Center(
              child: Text(
                "Forgot Password?",
                style: GoogleFonts.lexend(
                  color: primaryBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔧 INPUT FIELD
  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: fieldBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword ? isPasswordHidden : false,
        style: GoogleFonts.lexend(color: textMain),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.lexend(color: Colors.grey),
          prefixIcon: Icon(icon, color: Colors.grey),

          /// 👁️ show/hide password
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    isPasswordHidden ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      isPasswordHidden = !isPasswordHidden;
                    });
                  },
                )
              : null,

          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 20,
          ),
        ),
      ),
    );
  }
}
