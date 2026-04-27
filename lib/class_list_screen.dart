import 'package:flutter/material.dart';

class ClassModel {
  String name;
  int studentsCount;

  ClassModel({required this.name, required this.studentsCount});
}

class ClassListScreen extends StatefulWidget {
  @override
  State<ClassListScreen> createState() => _ClassListScreenState();
}

class _ClassListScreenState extends State<ClassListScreen> {
  List<ClassModel> classes = [
    ClassModel(name: "L3-SI-G1", studentsCount: 32),
    ClassModel(name: "L3-SI-G2", studentsCount: 28),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Classes", style: TextStyle(color: Colors.black)),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _openAddClass,
        child: const Icon(Icons.add),
      ),

      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: classes.length,
        itemBuilder: (context, index) {
          final c = classes[index];

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.class_, color: Colors.blue),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        c.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        "${c.studentsCount} students",
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),

                // ➡️ دخول للطلبة
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios),
                  onPressed: () {
                    Navigator.pushNamed(context, '/students');
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ➕ Add Class
  void _openAddClass() {
    final controller = TextEditingController();

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
                "Add Class",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: controller,
                decoration: const InputDecoration(labelText: "Class Name"),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () {
                  setState(() {
                    classes.add(
                      ClassModel(name: controller.text, studentsCount: 0),
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
