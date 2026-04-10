import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'db_attendance.db');

    // تحقق هل database موجودة
    if (!await File(path).exists()) {
      // تحميلها من assets
      ByteData data = await rootBundle.load('assets/database/db_attendance.db');
      List<int> bytes = data.buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      );

      // إنشاء الملف
      await File(path).writeAsBytes(bytes);
    }

    return await openDatabase(path);
  }

  // قراءة الطلاب
  Future<List<Map<String, dynamic>>> getStudents() async {
    final db = await instance.database;
    return await db.query('students');
  }

  // إضافة طالب
  Future<int> insertStudent(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('students', row);
  }
}
