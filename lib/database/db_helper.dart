import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// مساعد قاعدة البيانات — يُنشئ جداول المخطط عند أول تشغيل إذا لم يكن الملف موجوداً.
/// (يمكنك لاحقاً استبدال `dbv5.db` بنسخة كاملة من assets إن وُجدت.)
class DBHelper {
  static Database? _db;

  static String sqlLocalDate([DateTime? dt]) {
    final n = dt ?? DateTime.now();
    return '${n.year}-${n.month.toString().padLeft(2, '0')}-${n.day.toString().padLeft(2, '0')}';
  }

  static String sqlLocalTime([DateTime? dt]) {
    final n = dt ?? DateTime.now();
    return '${n.hour.toString().padLeft(2, '0')}:${n.minute.toString().padLeft(2, '0')}:${n.second.toString().padLeft(2, '0')}';
  }

  /// أسماء الأيام كما في `Teacher_Timetable.day_of_week` في القاعدة.
  static String englishWeekdayName(DateTime d) {
    const names = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return names[d.weekday - 1];
  }

  static int? parseId(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString());
  }

  static Future<Database> get db async {
    _db ??= await _initDb();
    return _db!;
  }

  static Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), 'dbv5.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, _) async {
        await _createEmptySchema(db);
        await _seedMinimalData(db);
      },
    );
  }

  /// جداول متوافقة مع `schema.sql` (بدون Views) — كافية لتشغيل التطبيق.
  static Future<void> _createEmptySchema(Database db) async {
    await db.execute('PRAGMA foreign_keys = OFF');
    for (final sql in _ddlStatements) {
      await db.execute(sql);
    }
    await db.execute('PRAGMA foreign_keys = ON');
  }

  static const _ddlStatements = <String>[
    '''
CREATE TABLE IF NOT EXISTS "Teachers" (
	"teacher_id"	INTEGER,
	"full_name"	TEXT NOT NULL,
	PRIMARY KEY("teacher_id" AUTOINCREMENT)
)''',
    '''
CREATE TABLE IF NOT EXISTS "Rooms" (
	"room_name"	TEXT,
	PRIMARY KEY("room_name")
)''',
    '''
CREATE TABLE IF NOT EXISTS "Subjects" (
	"subject_id"	INTEGER,
	"subject_name"	TEXT NOT NULL UNIQUE,
	PRIMARY KEY("subject_id" AUTOINCREMENT)
)''',
    '''
CREATE TABLE IF NOT EXISTS "Classes" (
	"class_id"	INTEGER,
	"group_name"	TEXT,
	"unilevel"	TEXT,
	"academic_year"	TEXT,
	PRIMARY KEY("class_id" AUTOINCREMENT),
	UNIQUE("group_name","unilevel","academic_year")
)''',
    '''
CREATE TABLE IF NOT EXISTS "Teacher_Timetable" (
	"timetable_id"	INTEGER,
	"class_id"	INTEGER NOT NULL,
	"subject_id"	INTEGER NOT NULL,
	"teacher_id"	INTEGER NOT NULL,
	"day_of_week"	TEXT NOT NULL CHECK("day_of_week" IN ('Saturday', 'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday')),
	"start_time"	TEXT NOT NULL,
	"end_time"	TEXT NOT NULL,
	"session_type"	TEXT NOT NULL CHECK("session_type" IN ('Lecture', 'TD', 'TP')),
	"room_name"	TEXT,
	UNIQUE("class_id","day_of_week","start_time"),
	PRIMARY KEY("timetable_id" AUTOINCREMENT),
	FOREIGN KEY("class_id") REFERENCES "Classes"("class_id") ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY("room_name") REFERENCES "Rooms"("room_name") ON UPDATE CASCADE ON DELETE SET NULL,
	FOREIGN KEY("subject_id") REFERENCES "Subjects"("subject_id") ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY("teacher_id") REFERENCES "Teachers"("teacher_id") ON UPDATE CASCADE ON DELETE CASCADE,
	CHECK("end_time" > "start_time")
)''',
    '''
CREATE TABLE IF NOT EXISTS "Students" (
	"registration_number"	TEXT,
	"first_name"	TEXT NOT NULL,
	"last_name"	TEXT NOT NULL,
	"email"	TEXT UNIQUE,
	"phone"	TEXT,
	"date_of_birth"	TEXT,
	"status"	TEXT DEFAULT 'Active' CHECK("status" IN ('Active', 'Inactive', 'Graduated', 'Withdrawn')),
	PRIMARY KEY("registration_number")
)''',
    '''
CREATE TABLE IF NOT EXISTS "Student_Enrollment" (
	"registration_number"	TEXT NOT NULL,
	"class_id"	INTEGER NOT NULL,
	"session_type"	TEXT NOT NULL CHECK("session_type" IN ('Lecture', 'TD', 'TP')),
	PRIMARY KEY("registration_number","class_id","session_type"),
	FOREIGN KEY("class_id") REFERENCES "Classes"("class_id") ON DELETE CASCADE,
	FOREIGN KEY("registration_number") REFERENCES "Students"("registration_number") ON DELETE CASCADE
)''',
    '''
CREATE TABLE IF NOT EXISTS "Sessions" (
	"session_id"	INTEGER,
	"timetable_id"	INTEGER NOT NULL,
	"session_date"	TEXT NOT NULL,
	"start_time"	TEXT NOT NULL,
	"status"	TEXT NOT NULL DEFAULT 'Scheduled' CHECK("status" IN ('Scheduled', 'Completed', 'Cancelled')),
	"notes"	TEXT,
	PRIMARY KEY("session_id" AUTOINCREMENT),
	UNIQUE("timetable_id","session_date","start_time"),
	FOREIGN KEY("timetable_id") REFERENCES "Teacher_Timetable"("timetable_id") ON DELETE CASCADE
)''',
    '''
CREATE TABLE IF NOT EXISTS "Attendance" (
	"attendance_id"	INTEGER,
	"registration_number"	TEXT NOT NULL,
	"session_id"	INTEGER NOT NULL,
	"step_order"	INTEGER,
	"status"	TEXT NOT NULL CHECK("status" IN ('Present', 'Absent', 'Late', 'Excused')),
	"arrival_time"	TEXT,
	"notes"	TEXT,
	"participation_score"	INTEGER DEFAULT 0 CHECK("participation_score" BETWEEN 0 AND 10),
	"discipline_score"	INTEGER DEFAULT 0 CHECK("discipline_score" BETWEEN 0 AND 10),
	"preparation_score"	INTEGER DEFAULT 0 CHECK("preparation_score" BETWEEN 0 AND 10),
	PRIMARY KEY("attendance_id" AUTOINCREMENT),
	UNIQUE("registration_number","session_id"),
	FOREIGN KEY("registration_number") REFERENCES "Students"("registration_number") ON DELETE CASCADE,
	FOREIGN KEY("session_id") REFERENCES "Sessions"("session_id") ON DELETE CASCADE
)''',
    '''
CREATE TABLE IF NOT EXISTS "Audit_Log" (
	"id"	INTEGER,
	"action"	TEXT,
	"entity"	TEXT,
	"timestamp"	TEXT DEFAULT CURRENT_TIMESTAMP,
	PRIMARY KEY("id" AUTOINCREMENT)
)''',
  ];

  static Future<void> _seedMinimalData(Database db) async {
    await db.insert('Teachers', {
      'teacher_id': 1,
      'full_name': 'Dr Ghemougui Abdessettar',
    });
    await db.insert('Rooms', {'room_name': 'S25'});
    await db.insert('Subjects', {
      'subject_id': 1,
      'subject_name': 'Computer Science',
    });
    await db.insert('Classes', {
      'class_id': 1,
      'group_name': 'A01',
      'unilevel': 'Licence',
      'academic_year': '2025-2026',
    });
    await db.insert('Teacher_Timetable', {
      'timetable_id': 1,
      'class_id': 1,
      'subject_id': 1,
      'teacher_id': 1,
      'day_of_week': 'Monday',
      'start_time': '08:00:00',
      'end_time': '10:00:00',
      'session_type': 'TD',
      'room_name': 'S25',
    });
  }

  // ── Teachers ─────────────────────────────────────────────────────────────
  static Future<List<Map<String, dynamic>>> getAllTeachers() async {
    final d = await db;
    try {
      return d.query('Teachers', orderBy: 'full_name ASC');
    } catch (_) {
      return [];
    }
  }

  static Future<Map<String, dynamic>?> getTeacherById(int teacherId) async {
    final d = await db;
    try {
      final r = await d.query(
        'Teachers',
        where: 'teacher_id = ?',
        whereArgs: [teacherId],
        limit: 1,
      );
      return r.isEmpty ? null : r.first;
    } catch (_) {
      return null;
    }
  }

  static Future<int> updateTeacherFullName(
    int teacherId,
    String fullName,
  ) async {
    final d = await db;
    return d.update(
      'Teachers',
      {'full_name': fullName.trim()},
      where: 'teacher_id = ?',
      whereArgs: [teacherId],
    );
  }

  // ── Classes / stats ─────────────────────────────────────────────────────
  static Future<List<Map<String, dynamic>>> getClasses() async {
    final d = await db;
    try {
      return d.rawQuery('''
        SELECT
          c.class_id,
          c.group_name AS class_name,
          c.unilevel,
          c.academic_year,
          (SELECT session_type FROM Teacher_Timetable WHERE class_id = c.class_id LIMIT 1) AS session_type
        FROM Classes c
        ORDER BY c.group_name
      ''');
    } catch (_) {
      return d.query('Classes', orderBy: 'group_name ASC');
    }
  }

  static Future<List<Map<String, dynamic>>> getClassStatistics() async {
    final d = await db;
    try {
      return d.rawQuery('''
        SELECT v.*, c.group_name AS class_name
        FROM vw_Class_Statistics v
        JOIN Classes c ON v.class_id = c.class_id
        ORDER BY c.group_name
      ''');
    } catch (_) {
      return d.rawQuery('''
        SELECT
          c.class_id,
          c.group_name AS class_name,
          c.unilevel,
          c.academic_year,
          COUNT(DISTINCT se.registration_number) AS total_students,
          0 AS active_students,
          0 AS total_sessions,
          0 AS completed_sessions,
          0.0 AS class_attendance_rate
        FROM Classes c
        LEFT JOIN Student_Enrollment se ON c.class_id = se.class_id
        GROUP BY c.class_id
      ''');
    }
  }

  static Future<List<Map<String, dynamic>>> getAtRiskStudents() async {
    final d = await db;
    try {
      return d.rawQuery('SELECT * FROM vw_At_Risk_Students');
    } catch (_) {
      return [];
    }
  }

  // ── Today / focus sessions ────────────────────────────────────────────────
  static Future<List<Map<String, dynamic>>> getTodaySessions() async {
    final d = await db;
    final today = sqlLocalDate();
    try {
      return d.rawQuery(
        '''
        SELECT
          sess.session_id,
          sess.session_date,
          sess.status AS session_status,
          tt.class_id,
          tt.timetable_id,
          tt.start_time,
          tt.end_time,
          tt.session_type,
          tt.room_name,
          c.group_name AS class_name,
          sub.subject_name AS subject_name,
          sub.subject_name AS subject_shortname,
          COUNT(DISTINCT a.registration_number) AS students_recorded,
          SUM(CASE WHEN a.status = 'Present' THEN 1 ELSE 0 END) AS students_present
        FROM Sessions sess
        JOIN Teacher_Timetable tt ON sess.timetable_id = tt.timetable_id
        JOIN Classes c ON tt.class_id = c.class_id
        JOIN Subjects sub ON tt.subject_id = sub.subject_id
        LEFT JOIN Attendance a ON sess.session_id = a.session_id
        WHERE sess.session_date = ?
        GROUP BY sess.session_id, tt.class_id, tt.timetable_id, tt.start_time, tt.end_time,
                 tt.session_type, tt.room_name, c.group_name, sub.subject_name, sess.session_date, sess.status
        ORDER BY tt.start_time
        ''',
        [today],
      );
    } catch (_) {
      return [];
    }
  }

  static Future<Map<String, dynamic>?>
  getCurrentOrNextSessionForAttendance() async {
    final list = await getTodaySessions();
    for (final r in list) {
      if (r['session_status'] != 'Completed') {
        return {...r, 'is_current_slot': 0};
      }
    }
    if (list.isNotEmpty) return {...list.first, 'is_current_slot': 0};
    return null;
  }

  static Future<double> getWeeklyAttendanceRate() async {
    final d = await db;
    try {
      final r = await d.rawQuery('''
        SELECT
          ROUND(100.0 * SUM(CASE WHEN a.status IN ('Present','Late') THEN 1 ELSE 0 END) / NULLIF(COUNT(*), 0), 1) AS rate
        FROM Attendance a
        JOIN Sessions s ON a.session_id = s.session_id
        WHERE s.session_date >= date('now', '-7 days')
      ''');
      if (r.isEmpty) return 0;
      final v = r.first['rate'];
      if (v is num) return v.toDouble();
      return 0;
    } catch (_) {
      return 0;
    }
  }

  // ── Timetable ─────────────────────────────────────────────────────────────
  static Future<List<Map<String, dynamic>>> getWeeklySchedule() async {
    final d = await db;
    try {
      return d.rawQuery(
        'SELECT * FROM vw_Weekly_Schedule ORDER BY day_order, start_time',
      );
    } catch (_) {
      return d.query('Teacher_Timetable', orderBy: 'day_of_week, start_time');
    }
  }

  static Future<List<Map<String, dynamic>>> getTimetableSlotsForClassToday(
    int classId,
  ) async {
    final d = await db;
    final dayName = englishWeekdayName(DateTime.now());
    try {
      return d.rawQuery(
        '''
        SELECT * FROM vw_Weekly_Schedule
        WHERE class_id = ? AND day_of_week = ?
        ORDER BY start_time ASC
        ''',
        [classId, dayName],
      );
    } catch (_) {
      return d.rawQuery(
        '''
        SELECT * FROM Teacher_Timetable
        WHERE class_id = ? AND day_of_week = ?
        ORDER BY start_time ASC
        ''',
        [classId, dayName],
      );
    }
  }

  // ── Sessions ─────────────────────────────────────────────────────────────
  static Future<int> getOrCreateSession({
    required int timetableId,
    required String startTime,
  }) async {
    final d = await db;
    final date = sqlLocalDate();
    final found = await d.query(
      'Sessions',
      where: 'timetable_id = ? AND session_date = ? AND start_time = ?',
      whereArgs: [timetableId, date, startTime],
      limit: 1,
    );
    if (found.isNotEmpty) {
      return parseId(found.first['session_id'])!;
    }
    return d.insert('Sessions', {
      'timetable_id': timetableId,
      'session_date': date,
      'start_time': startTime,
      'status': 'Scheduled',
    });
  }

  static Future<void> updateSessionStatus(int sessionId, String status) async {
    final d = await db;
    await d.update(
      'Sessions',
      {'status': status},
      where: 'session_id = ?',
      whereArgs: [sessionId],
    );
  }

  static Future<List<Map<String, dynamic>>> getRecentSessions() async {
    final d = await db;
    try {
      return d.rawQuery(
        'SELECT * FROM vw_Recent_Sessions ORDER BY session_id DESC LIMIT 80',
      );
    } catch (_) {
      return d.rawQuery('''
        SELECT sess.session_id, sess.session_date, sess.status AS session_status,
               tt.class_id, sub.subject_name, tt.session_type
        FROM Sessions sess
        JOIN Teacher_Timetable tt ON sess.timetable_id = tt.timetable_id
        JOIN Subjects sub ON tt.subject_id = sub.subject_id
        ORDER BY sess.session_date DESC, sess.session_id DESC
        LIMIT 50
      ''');
    }
  }

  static Future<Map<String, dynamic>?> getSessionDetails(int sessionId) async {
    final d = await db;
    try {
      final res = await d.rawQuery(
        'SELECT * FROM vw_Session_Details WHERE session_id = ?',
        [sessionId],
      );
      return res.isNotEmpty ? res.first : null;
    } catch (_) {
      return null;
    }
  }

  // ── Students ──────────────────────────────────────────────────────────────
  static Future<List<Map<String, dynamic>>> getStudentsByClass(
    int classId,
  ) async {
    final d = await db;
    try {
      return d.rawQuery(
        'SELECT * FROM vw_Ordered_Students_By_Class WHERE class_id = ?',
        [classId],
      );
    } catch (_) {
      return d.rawQuery(
        '''
        SELECT s.*, se.class_id
        FROM Students s
        JOIN Student_Enrollment se ON s.registration_number = se.registration_number
        WHERE se.class_id = ?
        ORDER BY s.last_name, s.first_name
        ''',
        [classId],
      );
    }
  }

  static Future<void> insertStudentWithEnrollment({
    required String registrationNumber,
    required String firstName,
    required String lastName,
    required int classId,
    String? email,
    String sessionType = 'TD',
  }) async {
    final d = await db;
    await d.transaction((txn) async {
      await txn.insert('Students', {
        'registration_number': registrationNumber,
        'first_name': firstName,
        'last_name': lastName,
        'email': email ?? 'student@univ-msila.dz',
        'status': 'Active',
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
      await txn.insert('Student_Enrollment', {
        'registration_number': registrationNumber,
        'class_id': classId,
        'session_type': sessionType,
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
    });
  }

  static Future<Map<String, dynamic>> importStudents(
    List<Map<String, dynamic>> rows,
    int classId,
  ) async {
    final d = await db;
    var inserted = 0;
    var skipped = 0;
    final errors = <String>[];

    await d.transaction((txn) async {
      for (final row in rows) {
        final reg = (row['registration_number'] ?? '').toString().trim();
        final fn = (row['first_name'] ?? '').toString().trim();
        final ln = (row['last_name'] ?? '').toString().trim();
        if (reg.isEmpty || fn.isEmpty || ln.isEmpty) {
          skipped++;
          errors.add('Incomplete row: $row');
          continue;
        }
        try {
          final r = await txn.insert('Students', {
            'registration_number': reg,
            'first_name': fn,
            'last_name': ln,
            'email': row['email'] ?? 'student@univ-msila.dz',
            'status': 'Active',
          }, conflictAlgorithm: ConflictAlgorithm.ignore);
          if (r == 0) {
            skipped++;
            continue;
          }
          await txn.insert('Student_Enrollment', {
            'registration_number': reg,
            'class_id': classId,
            'session_type': row['session_type'] ?? 'TD',
          }, conflictAlgorithm: ConflictAlgorithm.ignore);
          inserted++;
        } catch (e) {
          skipped++;
          errors.add('$reg: $e');
        }
      }
    });
    return {'inserted': inserted, 'skipped': skipped, 'errors': errors};
  }

  // ── Attendance ────────────────────────────────────────────────────────────
  static Future<Map<String, Map<String, dynamic>>> getAttendanceForSession(
    int sessionId,
  ) async {
    final d = await db;
    final res = await d.rawQuery(
      'SELECT * FROM Attendance WHERE session_id = ?',
      [sessionId],
    );
    return {
      for (final r in res)
        r['registration_number'] as String: Map<String, dynamic>.from(r),
    };
  }

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
    await d.insert('Attendance', {
      'session_id': sessionId,
      'registration_number': registrationNumber,
      'status': status,
      'participation_score': participationScore,
      'discipline_score': disciplineScore,
      'preparation_score': preparationScore,
      'notes': notes,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<void> batchUpsertAttendance(
    int sessionId,
    List<Map<String, dynamic>> students,
  ) async {
    final d = await db;
    await d.transaction((txn) async {
      for (final s in students) {
        await txn.insert('Attendance', {
          'session_id': sessionId,
          'registration_number': s['registration_number'],
          'status': s['status'],
          'participation_score': s['participation_score'] ?? 0,
          'discipline_score': s['discipline_score'] ?? 0,
          'preparation_score': s['preparation_score'] ?? 0,
          'notes': s['notes'],
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }
    });
  }

  static Future<List<Map<String, dynamic>>> getAttendanceBySession(
    int sessionId,
  ) async {
    final d = await db;
    try {
      return d.rawQuery(
        '''
        SELECT
          a.registration_number,
          a.status,
          a.notes,
          a.participation_score,
          a.discipline_score,
          a.preparation_score,
          s.first_name || ' ' || s.last_name AS full_name,
          s.first_name,
          s.last_name
        FROM Attendance a
        JOIN Students s ON a.registration_number = s.registration_number
        WHERE a.session_id = ?
        ORDER BY s.last_name, s.first_name
        ''',
        [sessionId],
      );
    } catch (_) {
      return d.rawQuery('SELECT * FROM Attendance WHERE session_id = ?', [
        sessionId,
      ]);
    }
  }

  static Future<List<Map<String, dynamic>>> getAttendanceExportData({
    int? classId,
    int? sessionId,
  }) async {
    final d = await db;
    var where = 'WHERE 1=1';
    final args = <dynamic>[];
    if (classId != null) {
      where += ' AND tt.class_id = ?';
      args.add(classId);
    }
    if (sessionId != null) {
      where += ' AND sess.session_id = ?';
      args.add(sessionId);
    }
    try {
      return d.rawQuery('''
        SELECT
          a.registration_number,
          s.first_name || ' ' || s.last_name AS student_name,
          c.group_name AS class_name,
          sub.subject_name AS subject_shortname,
          tt.session_type,
          sess.session_date,
          sess.start_time,
          a.status,
          a.notes,
          a.participation_score,
          a.discipline_score,
          a.preparation_score
        FROM Attendance a
        JOIN Students s ON a.registration_number = s.registration_number
        JOIN Sessions sess ON a.session_id = sess.session_id
        JOIN Teacher_Timetable tt ON sess.timetable_id = tt.timetable_id
        JOIN Classes c ON tt.class_id = c.class_id
        JOIN Subjects sub ON tt.subject_id = sub.subject_id
        $where
        ORDER BY sess.session_date DESC, s.last_name, s.first_name
        ''', args);
    } catch (_) {
      return [];
    }
  }
}
