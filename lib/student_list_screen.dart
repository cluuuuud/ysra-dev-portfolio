import 'package:flutter/material.dart';

class StudentModel {
  String name;
  String id;

  StudentModel({required this.name, required this.id});
}

class StudentListScreen extends StatefulWidget {
  const StudentListScreen({super.key});

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  List<StudentModel> students = [
    StudentModel(name: "Ahmed Ali", id: "S001"),
    StudentModel(name: "Sara Mohamed", id: "S002"),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Students", style: TextStyle(color: Colors.black)),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _openAddStudent,
        child: const Icon(Icons.add),
      ),

      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: students.length,
        itemBuilder: (context, index) {
          final s = students[index];

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blue.withOpacity(0.1),
                  child: Text(
                    s.name[0],
                    style: const TextStyle(color: Colors.blue),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(s.id, style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),

                // ✏️ Edit
                IconButton(icon: const Icon(Icons.edit), onPressed: () {}),

                // 🗑 Delete
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
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
    );
  }

  // ➕ Add Student
  void _openAddStudent() {
    final nameController = TextEditingController();
    final idController = TextEditingController();

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
              const Text(
                "Add Student",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Name"),
              ),

              TextField(
                controller: idController,
                decoration: const InputDecoration(labelText: "Student ID"),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () {
                  setState(() {
                    students.add(
                      StudentModel(
                        name: nameController.text,
                        id: idController.text,
                      ),
                    );
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
