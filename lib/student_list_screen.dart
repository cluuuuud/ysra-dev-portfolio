import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Student {
  String name;
  String id;
  String group;

  Student({required this.name, required this.id, required this.group});
}

class StudentListScreen extends StatefulWidget {
  const StudentListScreen({super.key});

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  static const Color bg = Color(0xFFF8FAFC);
  static const Color cardBg = Colors.white;
  static const Color border = Color(0xFFE2E8F0);
  static const Color textMain = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF64748B);
  static const Color primary = Color(0xFF2563EB);

  List<Student> students = [
    Student(name: "Yousra", id: "2024IT1001", group: "L3-SI-G1"),
    Student(name: "Amine", id: "2024IT1002", group: "L3-SI-G2"),
  ];

  String search = "";

  @override
  Widget build(BuildContext context) {
    final filtered = students
        .where((s) => s.name.toLowerCase().contains(search.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: bg,

      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        title: Text(
          "Students",
          style: GoogleFonts.lexend(
            color: textMain,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: primary,
        onPressed: () => _openForm(),
        child: const Icon(Icons.add),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🔍 Search
            TextField(
              onChanged: (value) {
                setState(() => search = value);
              },
              decoration: InputDecoration(
                hintText: "Search student...",
                filled: true,
                fillColor: cardBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: border),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 👥 List
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Text(
                        "No students found",
                        style: GoogleFonts.lexend(color: textMuted),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final s = filtered[index];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: border),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      s.name,
                                      style: GoogleFonts.lexend(
                                        fontWeight: FontWeight.w600,
                                        color: textMain,
                                      ),
                                    ),
                                    Text(
                                      "${s.id} • ${s.group}",
                                      style: GoogleFonts.lexend(
                                        fontSize: 12,
                                        color: textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // ✏ Edit
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _openForm(student: s),
                              ),

                              // 🗑 Delete
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  setState(() {
                                    students.remove(s);
                                  });
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // 🧾 Add / Edit Form
  void _openForm({Student? student}) {
    final nameController = TextEditingController(text: student?.name ?? "");
    final idController = TextEditingController(text: student?.id ?? "");
    String group = student?.group ?? "L3-SI-G1";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                student == null ? "Add Student" : "Edit Student",
                style: GoogleFonts.lexend(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Name"),
              ),

              TextField(
                controller: idController,
                decoration: const InputDecoration(labelText: "ID"),
              ),

              DropdownButtonFormField(
                value: group,
                items: ["L3-SI-G1", "L3-SI-G2", "M1-ISIL-G1"]
                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
                onChanged: (value) {
                  group = value!;
                },
                decoration: const InputDecoration(labelText: "Group"),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () {
                  setState(() {
                    if (student == null) {
                      students.add(
                        Student(
                          name: nameController.text,
                          id: idController.text,
                          group: group,
                        ),
                      );
                    } else {
                      student.name = nameController.text;
                      student.id = idController.text;
                      student.group = group;
                    }
                  });

                  Navigator.pop(context);
                },
                child: const Text("Save"),
              ),
            ],
          ),
        );
      },
    );
  }
}
