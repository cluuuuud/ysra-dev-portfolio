import 'package:flutter/material.dart';

class AddStudentScreen extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController idController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Student")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(hintText: "Name"),
            ),
            TextField(
              controller: idController,
              decoration: InputDecoration(hintText: "ID"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, {
                  "name": nameController.text,
                  "id": idController.text,
                  "status": "New",
                });
              },
              child: Text("ADD"),
            ),
          ],
        ),
      ),
    );
  }
}
