import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static Database? _db;

  // =========================
  // 🔹 INIT DB
  // =========================
  static Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await initDb();
    return _db!;
  }

  static Future<Database> initDb() async {
    String path = join(await getDatabasesPath(), 'db_attendance_v2.db');

    bool exists = await databaseExists(path);

    if (!exists) {
      ByteData data = await rootBundle.load(
        'assets/database/db_attendance_v2.db',
      );

      List<int> bytes = data.buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      );

      await File(path).writeAsBytes(bytes, flush: true);
    }

    return await openDatabase(path);
  }

  // =========================
  // ✅ CLASSES
  // =========================

  static Future<List<Map<String, dynamic>>> getClasses() async {
    final dbClient = await db;
    return await dbClient.query("Classes");
  }

  static Future<int> insertClass(String name) async {
    final dbClient = await db;
    return await dbClient.insert("Classes", {"class_name": name});
  }

  // =========================
  // ✅ STUDENTS
  // =========================

  static Future<List<Map<String, dynamic>>> getStudentsByClass(
    int classId,
  ) async {
    final dbClient = await db;

    return await dbClient.query(
      "Students",
      where: "class_id = ?",
      whereArgs: [classId],
    );
  }

  static Future<int> insertStudent(String name, int classId) async {
    final dbClient = await db;

    return await dbClient.insert("Students", {
      "student_name": name,
      "class_id": classId,
    });
  }

  // =========================
  // ✅ SESSIONS
  // =========================

  static Future<int> insertSession(int classId) async {
    final dbClient = await db;

    return await dbClient.insert("Sessions", {
      "class_id": classId,
      "session_date": DateTime.now().toString(),
    });
  }

  static Future<List<Map<String, dynamic>>> getSessions() async {
    final dbClient = await db;

    return await dbClient.rawQuery('''
      SELECT
        Sessions.session_id,
        Sessions.session_date,
        Classes.class_name
      FROM Sessions
      JOIN Classes
      ON Sessions.class_id = Classes.class_id
      ORDER BY Sessions.session_id DESC
    ''');
  }

  // =========================
  // ✅ ATTENDANCE
  // =========================

  static Future<void> insertAttendance(
    int sessionId,
    List<Map<String, dynamic>> students,
  ) async {
    final dbClient = await db;

    for (var s in students) {
      await dbClient.insert("Attendance", {
        "session_id": sessionId,
        "student_id": s["id"],
        "status": s["status"],
      });
    }
  }

  static Future<Map<String, int>> getAttendanceCount(int sessionId) async {
    final dbClient = await db;

    final result = await dbClient.rawQuery(
      '''
      SELECT
        SUM(CASE WHEN status = 'Present' THEN 1 ELSE 0 END) as present,
        SUM(CASE WHEN status = 'Absent' THEN 1 ELSE 0 END) as absent
      FROM Attendance
      WHERE session_id = ?
    ''',
      [sessionId],
    );

    return {
      "present": (result[0]["present"] ?? 0) as int,
      "absent": (result[0]["absent"] ?? 0) as int,
    };
  }

  static Future<List<Map<String, dynamic>>> getStudentsBySession(
    int sessionId,
  ) async {
    final dbClient = await db;

    return await dbClient.rawQuery(
      '''
      SELECT
        Students.student_id,
        Students.student_name,
        IFNULL(Attendance.status, 'Absent') as status
      FROM Students
      LEFT JOIN Attendance
      ON Students.student_id = Attendance.student_id
      AND Attendance.session_id = ?
    ''',
      [sessionId],
    );
  }

  // =========================
  // =========================
  // ✅ TIMETABLE (CORRECT)
  // =========================

  static Future<List<Map<String, dynamic>>> getTimetable() async {
    final dbClient = await db;

    return await dbClient.query(
      "Teacher_Timetable",
      orderBy: "timetable_id DESC",
    );
  }

  static Future<int> insertTimetable({
    required String subject,
    required String day,
    required String start,
    required String end,
    required String type,
  }) async {
    final dbClient = await db;

    return await dbClient.insert("Teacher_Timetable", {
      "subject_name": subject,
      "day_of_week": day,
      "start_time": start,
      "end_time": end,
      "session_type": type,
    });
  }
}
