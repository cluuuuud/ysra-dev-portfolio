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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Record Activity",
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStudentHeader(),
            const SizedBox(height: 40),

            Text("Attendance Status", style: _sectionStyle()),
            const SizedBox(height: 15),

            Row(
              children: [
                _statusButton("Present", Colors.green, Icons.check_circle),
                const SizedBox(width: 8),
                _statusButton("Late", Colors.orange, Icons.access_time_filled),
                const SizedBox(width: 8),
                _statusButton("Absent", Colors.red, Icons.cancel),
              ],
            ),

            const SizedBox(height: 40),

            Text("Activity Metrics (0 - 5)", style: _sectionStyle()),
            const SizedBox(height: 20),

            _buildScoreSlider(
              "Participation",
              participation,
              (val) => setState(() => participation = val),
            ),

            _buildScoreSlider(
              "Discipline",
              discipline,
              (val) => setState(() => discipline = val),
            ),

            _buildScoreSlider(
              "Preparation",
              preparation,
              (val) => setState(() => preparation = val),
            ),

            const SizedBox(height: 50),

            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _statusButton(String status, Color color, IconData icon) {
    bool isSelected = attendanceStatus == status;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => attendanceStatus = status),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withOpacity(0.2)
                : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : Colors.white10,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? color : Colors.white38, size: 22),
              const SizedBox(height: 5),
              Text(
                status,
                style: GoogleFonts.poppins(
                  color: isSelected ? color : Colors.white38,
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStudentHeader() {
    return Row(
      children: [
        const CircleAvatar(
          radius: 30,
          backgroundColor: Colors.blueAccent,
          child: Icon(Icons.person, color: Colors.white),
        ),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.studentName,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              "Group: G1 • ID: 2121",
              style: TextStyle(color: Colors.white38, fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildScoreSlider(
    String label,
    double value,
    Function(double) onChanged,
  ) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Colors.white70)),
            Text(
              value.toInt().toString(),
              style: const TextStyle(
                color: Colors.blueAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Slider(
          value: value,
          min: 0,
          max: 5,
          divisions: 5,
          activeColor: Colors.blueAccent,
          inactiveColor: Colors.white10,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Saved: $attendanceStatus for ${widget.studentName}",
              ),
            ),
          );
        },
        child: Text(
          "CONFIRM & SAVE",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  TextStyle _sectionStyle() => GoogleFonts.poppins(
    color: Colors.white,
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );
}
