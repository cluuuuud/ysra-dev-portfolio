import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static Database? _db;

  static Future<Database> get db async {
    _db ??= await _initDb();
    return _db!;
  }

  static Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), 'dbv5.db');
    final exists = await databaseExists(path);
    if (!exists) {
      final data = await rootBundle.load('assets/database/dbv5.db');
      final bytes = data.buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      );
      await File(path).writeAsBytes(bytes, flush: true);
    }
    return openDatabase(path);
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  DASHBOARD
  // ══════════════════════════════════════════════════════════════════════════

  static Future<List<Map<String, dynamic>>> getTodaySessions() async {
    final d = await db;
    return d.rawQuery("""
      SELECT * FROM vw_Session_Details
      WHERE session_date = DATE('now')
      ORDER BY start_time ASC
    """);
  }

  static Future<Map<String, dynamic>?> getNextSession() async {
    final d = await db;
    final res = await d.rawQuery("""
      SELECT * FROM vw_Session_Details
      WHERE session_status = 'Scheduled'
        AND (
          session_date > DATE('now')
          OR (session_date = DATE('now') AND start_time > TIME('now'))
        )
      ORDER BY session_date ASC, start_time ASC
      LIMIT 1
    """);
    return res.isNotEmpty ? res.first : null;
  }

  static Future<Map<String, dynamic>?> getCurrentSession() async {
    final d = await db;
    final res = await d.rawQuery("""
      SELECT * FROM vw_Session_Details
      WHERE session_date = DATE('now')
        AND TIME('now') BETWEEN start_time AND end_time
      LIMIT 1
    """);
    return res.isNotEmpty ? res.first : null;
  }

  static Future<Map<String, dynamic>?> getLastCompletedSession() async {
    final d = await db;
    final res = await d.rawQuery("""
      SELECT * FROM vw_Session_Details
      WHERE session_status = 'Completed'
      ORDER BY session_date DESC, start_time DESC
      LIMIT 1
    """);
    return res.isNotEmpty ? res.first : null;
  }

  static Future<double> getWeeklyAttendanceRate() async {
    final d = await db;
    final res = await d.rawQuery("""
      SELECT ROUND(
        100.0 * SUM(CASE WHEN a.status IN ('Present','Late') THEN 1 ELSE 0 END)
        / NULLIF(COUNT(a.attendance_id), 0), 1
      ) AS rate
      FROM Attendance a
      JOIN Sessions s ON a.session_id = s.session_id
      WHERE s.session_date BETWEEN DATE('now','-6 days') AND DATE('now')
    """);
    if (res.isEmpty) return 0;
    return ((res.first['rate'] as num?) ?? 0).toDouble();
  }

  static Future<List<Map<String, dynamic>>> getRecentSessions({
    int limit = 5,
  }) async {
    final d = await db;
    return d.rawQuery("SELECT * FROM vw_Recent_Sessions LIMIT ?", [limit]);
  }

  // ── At-Risk Students (من vw_At_Risk_Students) ─────────────────────────────
  /// عدد الطلبة المعرّضين للخطر
  static Future<int> getAtRiskCount() async {
    final d = await db;
    try {
      final res = await d.rawQuery(
        "SELECT COUNT(*) AS cnt FROM vw_At_Risk_Students",
      );
      return (res.first['cnt'] as int?) ?? 0;
    } catch (_) {
      return 0;
    }
  }

  /// قائمة الطلبة المعرّضين للخطر (للعرض التفصيلي)
  static Future<List<Map<String, dynamic>>> getAtRiskStudents() async {
    final d = await db;
    try {
      return d.rawQuery("SELECT * FROM vw_At_Risk_Students");
    } catch (_) {
      return [];
    }
  }

  // ── Class Statistics (من vw_Class_Statistics) ────────────────────────────
  static Future<List<Map<String, dynamic>>> getClassStatistics() async {
    final d = await db;
    return d.rawQuery("SELECT * FROM vw_Class_Statistics");
  }

  /// متوسط نسبة الحضور عبر كل الأقسام
  static Future<double> getAvgClassRate() async {
    final d = await db;
    final res = await d.rawQuery("""
      SELECT ROUND(AVG(class_attendance_rate), 1) AS avg_rate
      FROM vw_Class_Statistics
    """);
    if (res.isEmpty) return 0;
    return ((res.first['avg_rate'] as num?) ?? 0).toDouble();
  }

  /// عدد الأقسام
  static Future<int> getClassCount() async {
    final d = await db;
    final res = await d.rawQuery("SELECT COUNT(*) AS cnt FROM Classes");
    return (res.first['cnt'] as int?) ?? 0;
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  CLASSES
  // ══════════════════════════════════════════════════════════════════════════

  static Future<List<Map<String, dynamic>>> getClasses() async {
    final d = await db;
    return d.query("Classes", orderBy: "class_name ASC");
  }

  static Future<int> insertClass({
    required String className,
    required String unilevel,
    required String academicYear,
    String sessionType = 'TD',
  }) async {
    final d = await db;
    return d.insert("Classes", {
      "class_name": className,
      "unilevel": unilevel,
      "academic_year": academicYear,
      "session_type": sessionType,
    });
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  STUDENTS
  // ══════════════════════════════════════════════════════════════════════════

  static Future<List<Map<String, dynamic>>> getStudentsByClass(
    int classId,
  ) async {
    final d = await db;
    return d.rawQuery(
      "SELECT * FROM vw_Ordered_Students_By_Class WHERE class_id = ?",
      [classId],
    );
  }

  static Future<int> insertStudent({
    required String registrationNumber,
    required String firstName,
    required String lastName,
    String? email,
    String? phone,
    String? dateOfBirth,
  }) async {
    final d = await db;
    return d.insert("Students", {
      "registration_number": registrationNumber,
      "first_name": firstName,
      "last_name": lastName,
      "email": email ?? 'student@univ-msila.dz',
      "phone": phone,
      "date_of_birth": dateOfBirth,
      "status": 'active',
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  static Future<void> enrollStudent(String regNumber, int classId) async {
    final d = await db;
    await d.insert("Student_Enrollment", {
      "registration_number": regNumber,
      "class_id": classId,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  static Future<void> insertStudentWithEnrollment({
    required String registrationNumber,
    required String firstName,
    required String lastName,
    required int classId,
    String? email,
    String? phone,
  }) async {
    await insertStudent(
      registrationNumber: registrationNumber,
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: phone,
    );
    await enrollStudent(registrationNumber, classId);
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  SESSIONS
  // ══════════════════════════════════════════════════════════════════════════

  static Future<int> getOrCreateSession({
    required int timetableId,
    required String startTime,
  }) async {
    final d = await db;
    final now = DateTime.now();
    final dateStr =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    final existing = await d.rawQuery(
      """
      SELECT session_id FROM Sessions
      WHERE timetable_id = ? AND session_date = ? AND start_time = ?
      LIMIT 1
    """,
      [timetableId, dateStr, startTime],
    );

    if (existing.isNotEmpty) return existing.first['session_id'] as int;

    return d.insert("Sessions", {
      "timetable_id": timetableId,
      "session_date": dateStr,
      "start_time": startTime,
      "status": "Scheduled",
    });
  }

  static Future<void> updateSessionStatus(int sessionId, String status) async {
    final d = await db;
    await d.update(
      "Sessions",
      {"status": status},
      where: "session_id = ?",
      whereArgs: [sessionId],
    );
  }

  static Future<List<Map<String, dynamic>>> getSessions() async {
    final d = await db;
    return d.rawQuery(
      "SELECT * FROM vw_Session_Details ORDER BY session_date DESC, start_time DESC",
    );
  }

  static Future<Map<String, dynamic>?> getSessionDetails(int sessionId) async {
    final d = await db;
    final res = await d.rawQuery(
      "SELECT * FROM vw_Session_Details WHERE session_id = ?",
      [sessionId],
    );
    return res.isNotEmpty ? res.first : null;
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  ATTENDANCE
  // ══════════════════════════════════════════════════════════════════════════

  static Future<void> upsertAttendance({
    required int sessionId,
    required String registrationNumber,
    required String status,
    int participationScore = 0,
    int disciplineScore = 0,
    int preparationScore = 0,
    String? notes,
  }) async {
    final d = await db;
    await d.insert("Attendance", {
      "session_id": sessionId,
      "registration_number": registrationNumber,
      "status": status,
      "participation_score": participationScore,
      "discipline_score": disciplineScore,
      "preparation_score": preparationScore,
      "notes": notes,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<void> batchUpsertAttendance(
    int sessionId,
    List<Map<String, dynamic>> students,
  ) async {
    final d = await db;
    await d.transaction((txn) async {
      for (final s in students) {
        await txn.insert("Attendance", {
          "session_id": sessionId,
          "registration_number": s['registration_number'],
          "status": s['status'],
          "participation_score": s['participation_score'] ?? 0,
          "discipline_score": s['discipline_score'] ?? 0,
          "preparation_score": s['preparation_score'] ?? 0,
          "notes": s['notes'],
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }
    });
  }

  static Future<Map<String, Map<String, dynamic>>> getAttendanceForSession(
    int sessionId,
  ) async {
    final d = await db;
    final res = await d.rawQuery(
      "SELECT * FROM Attendance WHERE session_id = ?",
      [sessionId],
    );
    return {
      for (final r in res) r['registration_number'] as String: Map.from(r),
    };
  }

  static Future<List<Map<String, dynamic>>> getAttendanceBySession(
    int sessionId,
  ) async {
    final d = await db;
    return d.rawQuery(
      """
      SELECT a.*, s.first_name || ' ' || s.last_name AS full_name
      FROM Attendance a
      JOIN Students s ON a.registration_number = s.registration_number
      WHERE a.session_id = ?
      ORDER BY s.last_name, s.first_name
    """,
      [sessionId],
    );
  }

  static Future<Map<String, int>> getAttendanceCount(int sessionId) async {
    final d = await db;
    final res = await d.rawQuery(
      """
      SELECT
        SUM(CASE WHEN status = 'Present' THEN 1 ELSE 0 END) AS present,
        SUM(CASE WHEN status = 'Absent'  THEN 1 ELSE 0 END) AS absent,
        SUM(CASE WHEN status = 'Late'    THEN 1 ELSE 0 END) AS late
      FROM Attendance WHERE session_id = ?
    """,
      [sessionId],
    );
    if (res.isEmpty) return {"present": 0, "absent": 0, "late": 0};
    return {
      "present": (res.first["present"] as int?) ?? 0,
      "absent": (res.first["absent"] as int?) ?? 0,
      "late": (res.first["late"] as int?) ?? 0,
    };
  }

  static Future<List<Map<String, dynamic>>> getAttendanceExportData({
    int? classId,
    int? sessionId,
  }) async {
    final d = await db;
    String where = "WHERE 1=1";
    final args = <dynamic>[];
    if (classId != null) {
      where += " AND tt.class_id = ?";
      args.add(classId);
    }
    if (sessionId != null) {
      where += " AND sess.session_id = ?";
      args.add(sessionId);
    }

    return d.rawQuery("""
      SELECT
        a.registration_number,
        s.first_name || ' ' || s.last_name AS student_name,
        cc.class_name,
        sub.subject_shortname,
        tt.session_type,
        sess.session_date,
        sess.start_time,
        a.status,
        a.notes,
        a.participation_score,
        a.discipline_score,
        a.preparation_score
      FROM Attendance a
      JOIN Students  s    ON a.registration_number = s.registration_number
      JOIN Sessions  sess ON a.session_id          = sess.session_id
      JOIN Teacher_Timetable tt  ON sess.timetable_id = tt.timetable_id
      JOIN Classes   cc   ON tt.class_id             = cc.class_id
      JOIN Subjects  sub  ON tt.subject_id            = sub.subject_id
      $where
      ORDER BY sess.session_date DESC, s.last_name, s.first_name
    """, args);
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  TIMETABLE
  // ══════════════════════════════════════════════════════════════════════════

  static Future<List<Map<String, dynamic>>> getWeeklySchedule() async {
    final d = await db;
    return d.rawQuery(
      "SELECT * FROM vw_Weekly_Schedule ORDER BY day_order, start_time",
    );
  }

  static Future<List<Map<String, dynamic>>> getTimetableByClass(
    int classId,
  ) async {
    final d = await db;
    return d.rawQuery(
      "SELECT * FROM vw_Weekly_Schedule WHERE class_id = ? ORDER BY day_order, start_time",
      [classId],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  SUBJECTS & TEACHERS
  // ══════════════════════════════════════════════════════════════════════════

  static Future<List<Map<String, dynamic>>> getSubjects() async {
    final d = await db;
    return d.query("Subjects", orderBy: "subject_name ASC");
  }

  static Future<List<Map<String, dynamic>>> getTeachers() async {
    final d = await db;
    return d.query("Teachers", orderBy: "full_name ASC");
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  IMPORT
  // ══════════════════════════════════════════════════════════════════════════

  static Future<Map<String, dynamic>> importStudents(
    List<Map<String, dynamic>> rows,
    int classId,
  ) async {
    final d = await db;
    int inserted = 0, skipped = 0;
    final errors = <String>[];

    await d.transaction((txn) async {
      for (final row in rows) {
        final reg = (row['registration_number'] ?? '').toString().trim();
        final fn = (row['first_name'] ?? '').toString().trim();
        final ln = (row['last_name'] ?? '').toString().trim();

        if (reg.isEmpty || fn.isEmpty || ln.isEmpty) {
          errors.add('Skipped: $row');
          skipped++;
          continue;
        }
        try {
          final r = await txn.insert("Students", {
            "registration_number": reg,
            "first_name": fn,
            "last_name": ln,
            "email": row['email'] ?? 'student@univ-msila.dz',
            "phone": row['phone'],
            "status": 'active',
          }, conflictAlgorithm: ConflictAlgorithm.ignore);
          await txn.insert("Student_Enrollment", {
            "registration_number": reg,
            "class_id": classId,
          }, conflictAlgorithm: ConflictAlgorithm.ignore);
          r > 0 ? inserted++ : skipped++;
        } catch (e) {
          errors.add('Error $reg: $e');
          skipped++;
        }
      }
    });

    return {"inserted": inserted, "skipped": skipped, "errors": errors};
  }
}
