import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'student_screen.dart';

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A1A2E),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Dashboard",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(icon: Icon(Icons.notifications_none), onPressed: () {}),
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Colors.blueAccent,
              child: Icon(Icons.person, color: Colors.white),
            ),
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Welcome 👋",
              style: GoogleFonts.poppins(color: Colors.white70, fontSize: 16),
            ),
            Text(
              "Manage Your App",
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 30),

            // 🔥 Stats
            Row(
              children: [
                _buildStatCard("Students", "120", Colors.blueAccent),
                SizedBox(width: 15),
                _buildStatCard("Classes", "4", Colors.cyan),
              ],
            ),

            SizedBox(height: 30),

            Text(
              "Quick Actions",
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),

            SizedBox(height: 20),

            // 🔥 Buttons
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/students');
              },
              child: Text("Students"),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
            ),

            SizedBox(height: 15),

            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Classes screen not added yet")),
                );
              },
              child: Text("Classes"),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 Stat Card
  Widget _buildStatCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(color: Colors.white60, fontSize: 12),
            ),
            SizedBox(height: 10),
            Text(
              value,
              style: GoogleFonts.poppins(
                color: color,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
