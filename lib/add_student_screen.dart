import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AttendanceRecordScreen extends StatefulWidget {
  final String studentName;

  const AttendanceRecordScreen({super.key, required this.studentName});

  @override
  State<AttendanceRecordScreen> createState() => _AttendanceRecordScreenState();
}

class _AttendanceRecordScreenState extends State<AttendanceRecordScreen> {
  String attendanceStatus = "Present";
  double participation = 3.0;
  double discipline = 5.0;
  double preparation = 4.0;

  static const Color primaryBg = Color(0xFF080808);
  static const Color accentBlue = Color(0xFF4D96FF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryBg,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "RECORD ACTIVITY",
          style: GoogleFonts.lexend(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Stack(
        children: [
          /// ✅ تم حذف blurRadius (كان الخطأ هنا)
          Positioned(
            top: 50,
            left: 20,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accentBlue.withOpacity(0.1),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStudentHeader(),
                  const SizedBox(height: 40),

                  _buildSectionTitle("Attendance Status"),
                  const SizedBox(height: 15),

                  Row(
                    children: [
                      _statusButton(
                        "Present",
                        Colors.greenAccent,
                        Icons.check_circle_rounded,
                      ),
                      const SizedBox(width: 10),
                      _statusButton(
                        "Late",
                        Colors.orangeAccent,
                        Icons.watch_later_rounded,
                      ),
                      const SizedBox(width: 10),
                      _statusButton(
                        "Absent",
                        Colors.redAccent,
                        Icons.remove_circle_rounded,
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  _buildSectionTitle("Performance Metrics"),
                  const SizedBox(height: 10),
                  _buildGlassMetricsCard(),

                  const SizedBox(height: 50),
                  _buildSaveButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentHeader() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 32,
                backgroundColor: accentBlue,
                child: Icon(Icons.person_rounded, color: Colors.white),
              ),
              const SizedBox(width: 18),
              Text(
                widget.studentName,
                style: GoogleFonts.lexend(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusButton(String status, Color color, IconData icon) {
    bool isSelected = attendanceStatus == status;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => attendanceStatus = status),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withOpacity(0.15)
                : Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? color.withOpacity(0.5) : Colors.white10,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? color : Colors.white24),
              const SizedBox(height: 8),
              Text(
                status,
                style: GoogleFonts.lexend(
                  color: isSelected ? color : Colors.white38,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlassMetricsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          _buildScoreSlider(
            "Participation",
            participation,
            (v) => setState(() => participation = v),
            Colors.greenAccent,
          ),
          const Divider(color: Colors.white10),
          _buildScoreSlider(
            "Discipline",
            discipline,
            (v) => setState(() => discipline = v),
            Colors.orangeAccent,
          ),
          const Divider(color: Colors.white10),
          _buildScoreSlider(
            "Preparation",
            preparation,
            (v) => setState(() => preparation = v),
            accentBlue,
          ),
        ],
      ),
    );
  }

  Widget _buildScoreSlider(
    String label,
    double value,
    Function(double) onChanged,
    Color color,
  ) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: GoogleFonts.lexend(color: Colors.white70)),
            Text(
              "${value.toInt()}/5",
              style: GoogleFonts.lexend(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(
            context,
          ).copyWith(activeTrackColor: color, thumbColor: color),
          child: Slider(
            value: value,
            min: 0,
            max: 5,
            divisions: 5,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(colors: [accentBlue, Color(0xFF3366FF)]),
      ),
      child: ElevatedButton(
        onPressed: () {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Saved ✅")));
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        child: Text(
          "CONFIRM & SAVE",
          style: GoogleFonts.lexend(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.lexend(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
