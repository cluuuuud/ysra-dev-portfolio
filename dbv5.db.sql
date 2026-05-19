BEGIN TRANSACTION;
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
);
CREATE TABLE IF NOT EXISTS "Classes" (
	"class_id"	INTEGER,
	"class_name"	TEXT,
	"unilevel"	TEXT,
	"academic_year"	TEXT,
	"session_type"	TEXT NOT NULL DEFAULT 'TD' CHECK("session_type" IN ('Lecture', 'TD', 'TP')),
	PRIMARY KEY("class_id" AUTOINCREMENT),
	UNIQUE("class_name","unilevel","academic_year")
);
CREATE TABLE IF NOT EXISTS "Rooms" (
	"room_name"	TEXT,
	PRIMARY KEY("room_name")
);
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
);
CREATE TABLE IF NOT EXISTS "Student_Enrollment" (
	"registration_number"	TEXT NOT NULL,
	"class_id"	INTEGER NOT NULL,
	PRIMARY KEY("registration_number","class_id"),
	FOREIGN KEY("class_id") REFERENCES "Classes"("class_id") ON DELETE CASCADE,
	FOREIGN KEY("registration_number") REFERENCES "Students"("registration_number") ON DELETE CASCADE
);
CREATE TABLE IF NOT EXISTS "Students" (
	"registration_number"	TEXT,
	"first_name"	TEXT NOT NULL,
	"last_name"	TEXT NOT NULL,
	"email"	TEXT DEFAULT 'student@univ-msila.dz',
	"phone"	TEXT,
	"date_of_birth"	TEXT,
	"status"	TEXT DEFAULT 'Active' CHECK("status" IN ('active', 'inactive', 'graduated', 'withdrawn')),
	PRIMARY KEY("registration_number")
);
CREATE TABLE IF NOT EXISTS "Subjects" (
	"subject_id"	INTEGER,
	"subject_name"	TEXT NOT NULL,
	"subject_shortname"	TEXT NOT NULL UNIQUE,
	PRIMARY KEY("subject_id" AUTOINCREMENT)
);
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
);
CREATE TABLE IF NOT EXISTS "Teachers" (
	"teacher_id"	INTEGER,
	"full_name"	TEXT NOT NULL,
	PRIMARY KEY("teacher_id" AUTOINCREMENT)
);
INSERT INTO "Classes" VALUES (1,'A1','Licence','2025-2026','TD');
INSERT INTO "Classes" VALUES (2,'A2','Licence','2025-2026','TD');
INSERT INTO "Classes" VALUES (6,'A6','Licence','2025-2026','TD');
INSERT INTO "Classes" VALUES (7,'B1','Licence','2025-2026','TD');
INSERT INTO "Classes" VALUES (8,'B2','Licence','2025-2026','TD');
INSERT INTO "Classes" VALUES (12,'B6','Licence','2025-2026','TD');
INSERT INTO "Rooms" VALUES ('S25');
INSERT INTO "Rooms" VALUES ('S26');
INSERT INTO "Rooms" VALUES ('S28');
INSERT INTO "Rooms" VALUES ('S32');
INSERT INTO "Rooms" VALUES ('S33');
INSERT INTO "Rooms" VALUES ('TP-13');
INSERT INTO "Rooms" VALUES ('TP-14');
INSERT INTO "Rooms" VALUES ('TP-15');
INSERT INTO "Rooms" VALUES ('TP-16');
INSERT INTO "Sessions" VALUES (1,1,'02/02/2026','15:30','Completed','');
INSERT INTO "Sessions" VALUES (2,1,'09/02/2026','15:30','Completed','');
INSERT INTO "Sessions" VALUES (3,1,'16/02/2026','15:30','Completed','');
INSERT INTO "Sessions" VALUES (4,1,'23/02/2026','15:30','Completed','');
INSERT INTO "Sessions" VALUES (5,1,'02/03/2026','15:30','Completed','');
INSERT INTO "Sessions" VALUES (6,1,'09/03/2026','15:30','Completed','');
INSERT INTO "Sessions" VALUES (7,1,'16/03/2026','15:30','Cancelled','');
INSERT INTO "Sessions" VALUES (8,1,'06/04/2026','15:30','Completed','');
INSERT INTO "Sessions" VALUES (9,1,'13/04/2026','15:30','Completed','');
INSERT INTO "Sessions" VALUES (11,1,'20/04/2026','15:30','Cancelled','');
INSERT INTO "Sessions" VALUES (12,1,'27/04/2026','15:30','Completed','');
INSERT INTO "Sessions" VALUES (13,1,'04/05/2026','15:30','Cancelled','Collective absense');
INSERT INTO "Sessions" VALUES (21,2,'02/02/2026','14:00','Completed','');
INSERT INTO "Sessions" VALUES (22,2,'09/02/2026','14:00','Completed','');
INSERT INTO "Sessions" VALUES (23,2,'16/02/2026','14:00','Completed','');
INSERT INTO "Sessions" VALUES (24,2,'23/02/2026','14:00','Completed','');
INSERT INTO "Sessions" VALUES (25,2,'02/03/2026','14:00','Completed','');
INSERT INTO "Sessions" VALUES (26,2,'09/03/2026','14:00','Completed','');
INSERT INTO "Sessions" VALUES (27,2,'16/03/2026','14:00','Cancelled','');
INSERT INTO "Sessions" VALUES (28,2,'06/04/2026','14:00','Completed','');
INSERT INTO "Sessions" VALUES (29,2,'13/04/2026','14:00','Completed','');
INSERT INTO "Sessions" VALUES (211,2,'20/04/2026','14:00','Cancelled','');
INSERT INTO "Sessions" VALUES (212,2,'27/04/2026','14:00','Completed','');
INSERT INTO "Sessions" VALUES (213,2,'04/05/2026','14:00','Completed','');
INSERT INTO "Student_Enrollment" VALUES ('252535649116',1);
INSERT INTO "Student_Enrollment" VALUES ('242535683703',1);
INSERT INTO "Student_Enrollment" VALUES ('252535568812',1);
INSERT INTO "Student_Enrollment" VALUES ('242435556206',1);
INSERT INTO "Student_Enrollment" VALUES ('232435669220',1);
INSERT INTO "Student_Enrollment" VALUES ('242535678613',1);
INSERT INTO "Student_Enrollment" VALUES ('242535679302',1);
INSERT INTO "Student_Enrollment" VALUES ('242435583714',1);
INSERT INTO "Student_Enrollment" VALUES ('252535574020',1);
INSERT INTO "Student_Enrollment" VALUES ('252535575102',1);
INSERT INTO "Student_Enrollment" VALUES ('252535571812',1);
INSERT INTO "Student_Enrollment" VALUES ('252535633506',1);
INSERT INTO "Student_Enrollment" VALUES ('252535628510',1);
INSERT INTO "Student_Enrollment" VALUES ('232535677807',1);
INSERT INTO "Student_Enrollment" VALUES ('242535679705',1);
INSERT INTO "Student_Enrollment" VALUES ('252535566807',1);
INSERT INTO "Student_Enrollment" VALUES ('232435662418',1);
INSERT INTO "Student_Enrollment" VALUES ('252535626013',1);
INSERT INTO "Student_Enrollment" VALUES ('252535597519',1);
INSERT INTO "Student_Enrollment" VALUES ('252535570920',1);
INSERT INTO "Student_Enrollment" VALUES ('252535566817',1);
INSERT INTO "Student_Enrollment" VALUES ('252535565418',1);
INSERT INTO "Student_Enrollment" VALUES ('232335519217',1);
INSERT INTO "Student_Enrollment" VALUES ('252535565220',1);
INSERT INTO "Student_Enrollment" VALUES ('252535638301',1);
INSERT INTO "Student_Enrollment" VALUES ('232535718411',1);
INSERT INTO "Student_Enrollment" VALUES ('242435608917',1);
INSERT INTO "Student_Enrollment" VALUES ('192535720817',1);
INSERT INTO "Student_Enrollment" VALUES ('242535720215',1);
INSERT INTO "Student_Enrollment" VALUES ('252535618809',1);
INSERT INTO "Student_Enrollment" VALUES ('222435702301',1);
INSERT INTO "Student_Enrollment" VALUES ('252535626105',1);
INSERT INTO "Student_Enrollment" VALUES ('222535686718',1);
INSERT INTO "Student_Enrollment" VALUES ('232335573008',1);
INSERT INTO "Student_Enrollment" VALUES ('242435558301',1);
INSERT INTO "Student_Enrollment" VALUES ('252535571513',1);
INSERT INTO "Student_Enrollment" VALUES ('252535639509',1);
INSERT INTO "Student_Enrollment" VALUES ('242535687704',1);
INSERT INTO "Student_Enrollment" VALUES ('252535568017',1);
INSERT INTO "Student_Enrollment" VALUES ('242535713920',1);
INSERT INTO "Student_Enrollment" VALUES ('252535694312',1);
INSERT INTO "Student_Enrollment" VALUES ('242435556202',1);
INSERT INTO "Student_Enrollment" VALUES ('252535571006',1);
INSERT INTO "Student_Enrollment" VALUES ('242435701416',1);
INSERT INTO "Student_Enrollment" VALUES ('252535572111',2);
INSERT INTO "Student_Enrollment" VALUES ('242535684120',2);
INSERT INTO "Student_Enrollment" VALUES ('252535602905',2);
INSERT INTO "Student_Enrollment" VALUES ('252535570512',2);
INSERT INTO "Student_Enrollment" VALUES ('252535566719',2);
INSERT INTO "Student_Enrollment" VALUES ('242435632617',2);
INSERT INTO "Student_Enrollment" VALUES ('252535564607',2);
INSERT INTO "Student_Enrollment" VALUES ('242535684108',2);
INSERT INTO "Student_Enrollment" VALUES ('252535597112',2);
INSERT INTO "Student_Enrollment" VALUES ('252535569708',2);
INSERT INTO "Student_Enrollment" VALUES ('252535625705',2);
INSERT INTO "Student_Enrollment" VALUES ('252535628513',2);
INSERT INTO "Student_Enrollment" VALUES ('252535607820',2);
INSERT INTO "Student_Enrollment" VALUES ('252535569316',2);
INSERT INTO "Student_Enrollment" VALUES ('252535678707',2);
INSERT INTO "Student_Enrollment" VALUES ('252535648716',2);
INSERT INTO "Student_Enrollment" VALUES ('252535645019',2);
INSERT INTO "Student_Enrollment" VALUES ('242435635409',2);
INSERT INTO "Student_Enrollment" VALUES ('222235532003',2);
INSERT INTO "Student_Enrollment" VALUES ('252535594503',2);
INSERT INTO "Student_Enrollment" VALUES ('242435560804',2);
INSERT INTO "Student_Enrollment" VALUES ('252535572020',2);
INSERT INTO "Student_Enrollment" VALUES ('242535679413',2);
INSERT INTO "Student_Enrollment" VALUES ('252535608014',2);
INSERT INTO "Student_Enrollment" VALUES ('232435701003',2);
INSERT INTO "Student_Enrollment" VALUES ('242535713410',2);
INSERT INTO "Student_Enrollment" VALUES ('252535654313',2);
INSERT INTO "Student_Enrollment" VALUES ('242535719117',2);
INSERT INTO "Student_Enrollment" VALUES ('252535572016',2);
INSERT INTO "Student_Enrollment" VALUES ('242535716808',2);
INSERT INTO "Student_Enrollment" VALUES ('252535568418',2);
INSERT INTO "Student_Enrollment" VALUES ('252535565905',2);
INSERT INTO "Student_Enrollment" VALUES ('242535721301',2);
INSERT INTO "Student_Enrollment" VALUES ('242435589205',2);
INSERT INTO "Student_Enrollment" VALUES ('252535583912',2);
INSERT INTO "Student_Enrollment" VALUES ('252535600505',2);
INSERT INTO "Student_Enrollment" VALUES ('242435585405',2);
INSERT INTO "Student_Enrollment" VALUES ('242435560611',2);
INSERT INTO "Student_Enrollment" VALUES ('242535715111',2);
INSERT INTO "Student_Enrollment" VALUES ('242535680913',2);
INSERT INTO "Student_Enrollment" VALUES ('252535608213',2);
INSERT INTO "Student_Enrollment" VALUES ('232335547802',2);
INSERT INTO "Student_Enrollment" VALUES ('212235613202',2);
INSERT INTO "Student_Enrollment" VALUES ('252535573902',6);
INSERT INTO "Student_Enrollment" VALUES ('242535694511',6);
INSERT INTO "Student_Enrollment" VALUES ('252535569309',6);
INSERT INTO "Student_Enrollment" VALUES ('252535609515',6);
INSERT INTO "Student_Enrollment" VALUES ('242435583213',6);
INSERT INTO "Student_Enrollment" VALUES ('252535566519',6);
INSERT INTO "Student_Enrollment" VALUES ('252535569005',6);
INSERT INTO "Student_Enrollment" VALUES ('252535568406',6);
INSERT INTO "Student_Enrollment" VALUES ('252533008214',6);
INSERT INTO "Student_Enrollment" VALUES ('252535584817',6);
INSERT INTO "Student_Enrollment" VALUES ('252535571610',6);
INSERT INTO "Student_Enrollment" VALUES ('252535571613',6);
INSERT INTO "Student_Enrollment" VALUES ('252535573502',6);
INSERT INTO "Student_Enrollment" VALUES ('252535593419',6);
INSERT INTO "Student_Enrollment" VALUES ('242435552017',6);
INSERT INTO "Student_Enrollment" VALUES ('252535621706',6);
INSERT INTO "Student_Enrollment" VALUES ('242435581218',6);
INSERT INTO "Student_Enrollment" VALUES ('252535568111',6);
INSERT INTO "Student_Enrollment" VALUES ('242435556103',6);
INSERT INTO "Student_Enrollment" VALUES ('252535679213',6);
INSERT INTO "Student_Enrollment" VALUES ('252535564820',6);
INSERT INTO "Student_Enrollment" VALUES ('242535684209',6);
INSERT INTO "Student_Enrollment" VALUES ('242535687803',6);
INSERT INTO "Student_Enrollment" VALUES ('242535677814',6);
INSERT INTO "Student_Enrollment" VALUES ('242535680804',6);
INSERT INTO "Student_Enrollment" VALUES ('252535570611',6);
INSERT INTO "Student_Enrollment" VALUES ('252535569406',6);
INSERT INTO "Student_Enrollment" VALUES ('252535595909',6);
INSERT INTO "Student_Enrollment" VALUES ('252535716705',6);
INSERT INTO "Student_Enrollment" VALUES ('252535572101',6);
INSERT INTO "Student_Enrollment" VALUES ('252535583709',6);
INSERT INTO "Student_Enrollment" VALUES ('252535572018',6);
INSERT INTO "Student_Enrollment" VALUES ('252535583610',6);
INSERT INTO "Student_Enrollment" VALUES ('252535569117',6);
INSERT INTO "Student_Enrollment" VALUES ('252535604420',6);
INSERT INTO "Student_Enrollment" VALUES ('242435558810',6);
INSERT INTO "Student_Enrollment" VALUES ('242535686306',6);
INSERT INTO "Student_Enrollment" VALUES ('252535593310',6);
INSERT INTO "Student_Enrollment" VALUES ('252535574316',6);
INSERT INTO "Student_Enrollment" VALUES ('252535584405',6);
INSERT INTO "Student_Enrollment" VALUES ('252535575020',6);
INSERT INTO "Student_Enrollment" VALUES ('252535619406',7);
INSERT INTO "Student_Enrollment" VALUES ('222235506304',7);
INSERT INTO "Student_Enrollment" VALUES ('252535565402',7);
INSERT INTO "Student_Enrollment" VALUES ('252535578612',7);
INSERT INTO "Student_Enrollment" VALUES ('242435559905',7);
INSERT INTO "Student_Enrollment" VALUES ('242535688115',7);
INSERT INTO "Student_Enrollment" VALUES ('252535569320',7);
INSERT INTO "Student_Enrollment" VALUES ('252535633508',7);
INSERT INTO "Student_Enrollment" VALUES ('252535572914',7);
INSERT INTO "Student_Enrollment" VALUES ('252535598209',7);
INSERT INTO "Student_Enrollment" VALUES ('252531072209',7);
INSERT INTO "Student_Enrollment" VALUES ('252535628718',7);
INSERT INTO "Student_Enrollment" VALUES ('242435580111',7);
INSERT INTO "Student_Enrollment" VALUES ('242435569419',7);
INSERT INTO "Student_Enrollment" VALUES ('252535619001',7);
INSERT INTO "Student_Enrollment" VALUES ('252535565601',7);
INSERT INTO "Student_Enrollment" VALUES ('242535719420',7);
INSERT INTO "Student_Enrollment" VALUES ('252535571903',7);
INSERT INTO "Student_Enrollment" VALUES ('242435632413',7);
INSERT INTO "Student_Enrollment" VALUES ('252535639718',7);
INSERT INTO "Student_Enrollment" VALUES ('252535568216',7);
INSERT INTO "Student_Enrollment" VALUES ('252535639803',7);
INSERT INTO "Student_Enrollment" VALUES ('242435552009',7);
INSERT INTO "Student_Enrollment" VALUES ('252535571816',7);
INSERT INTO "Student_Enrollment" VALUES ('252535578406',7);
INSERT INTO "Student_Enrollment" VALUES ('242535682220',7);
INSERT INTO "Student_Enrollment" VALUES ('242435555105',7);
INSERT INTO "Student_Enrollment" VALUES ('252535613014',7);
INSERT INTO "Student_Enrollment" VALUES ('252535567415',7);
INSERT INTO "Student_Enrollment" VALUES ('242531569006',7);
INSERT INTO "Student_Enrollment" VALUES ('252535604606',7);
INSERT INTO "Student_Enrollment" VALUES ('252535565506',7);
INSERT INTO "Student_Enrollment" VALUES ('242435581920',7);
INSERT INTO "Student_Enrollment" VALUES ('252535571703',7);
INSERT INTO "Student_Enrollment" VALUES ('222235545706',7);
INSERT INTO "Student_Enrollment" VALUES ('252535639513',7);
INSERT INTO "Student_Enrollment" VALUES ('242535721118',7);
INSERT INTO "Student_Enrollment" VALUES ('252535622004',7);
INSERT INTO "Student_Enrollment" VALUES ('252535607520',7);
INSERT INTO "Student_Enrollment" VALUES ('252535721706',7);
INSERT INTO "Student_Enrollment" VALUES ('232335541804',7);
INSERT INTO "Student_Enrollment" VALUES ('252535626014',7);
INSERT INTO "Student_Enrollment" VALUES ('242535686803',8);
INSERT INTO "Student_Enrollment" VALUES ('232335553010',8);
INSERT INTO "Student_Enrollment" VALUES ('252535649106',8);
INSERT INTO "Student_Enrollment" VALUES ('252535573609',8);
INSERT INTO "Student_Enrollment" VALUES ('252535646506',8);
INSERT INTO "Student_Enrollment" VALUES ('25054097358',8);
INSERT INTO "Student_Enrollment" VALUES ('252535571917',8);
INSERT INTO "Student_Enrollment" VALUES ('252535608016',8);
INSERT INTO "Student_Enrollment" VALUES ('252535633311',8);
INSERT INTO "Student_Enrollment" VALUES ('242435560803',8);
INSERT INTO "Student_Enrollment" VALUES ('232435695504',8);
INSERT INTO "Student_Enrollment" VALUES ('232535683410',8);
INSERT INTO "Student_Enrollment" VALUES ('252535608817',8);
INSERT INTO "Student_Enrollment" VALUES ('252535637016',8);
INSERT INTO "Student_Enrollment" VALUES ('242435556211',8);
INSERT INTO "Student_Enrollment" VALUES ('252535570905',8);
INSERT INTO "Student_Enrollment" VALUES ('242435630112',8);
INSERT INTO "Student_Enrollment" VALUES ('252535593607',8);
INSERT INTO "Student_Enrollment" VALUES ('252535583006',8);
INSERT INTO "Student_Enrollment" VALUES ('242535716712',8);
INSERT INTO "Student_Enrollment" VALUES ('252535607212',8);
INSERT INTO "Student_Enrollment" VALUES ('252535599713',8);
INSERT INTO "Student_Enrollment" VALUES ('252535570109',8);
INSERT INTO "Student_Enrollment" VALUES ('252535582702',8);
INSERT INTO "Student_Enrollment" VALUES ('252535604512',8);
INSERT INTO "Student_Enrollment" VALUES ('232435701808',8);
INSERT INTO "Student_Enrollment" VALUES ('232335624902',8);
INSERT INTO "Student_Enrollment" VALUES ('252535584215',8);
INSERT INTO "Student_Enrollment" VALUES ('222535684212',8);
INSERT INTO "Student_Enrollment" VALUES ('252535619915',8);
INSERT INTO "Student_Enrollment" VALUES ('252535628908',8);
INSERT INTO "Student_Enrollment" VALUES ('242435558801',8);
INSERT INTO "Student_Enrollment" VALUES ('252535577010',8);
INSERT INTO "Student_Enrollment" VALUES ('242435556701',8);
INSERT INTO "Student_Enrollment" VALUES ('252535567616',8);
INSERT INTO "Student_Enrollment" VALUES ('252535583908',8);
INSERT INTO "Student_Enrollment" VALUES ('232535687812',8);
INSERT INTO "Student_Enrollment" VALUES ('252532354504',8);
INSERT INTO "Student_Enrollment" VALUES ('252535584503',8);
INSERT INTO "Student_Enrollment" VALUES ('242435598504',8);
INSERT INTO "Student_Enrollment" VALUES ('232335546007',8);
INSERT INTO "Student_Enrollment" VALUES ('242435581316',12);
INSERT INTO "Student_Enrollment" VALUES ('242535686110',12);
INSERT INTO "Student_Enrollment" VALUES ('242535695706',12);
INSERT INTO "Student_Enrollment" VALUES ('242435630104',12);
INSERT INTO "Student_Enrollment" VALUES ('252535566205',12);
INSERT INTO "Student_Enrollment" VALUES ('242535716209',12);
INSERT INTO "Student_Enrollment" VALUES ('252535584207',12);
INSERT INTO "Student_Enrollment" VALUES ('232331786010',12);
INSERT INTO "Student_Enrollment" VALUES ('242535694915',12);
INSERT INTO "Student_Enrollment" VALUES ('252535584813',12);
INSERT INTO "Student_Enrollment" VALUES ('242535694311',12);
INSERT INTO "Student_Enrollment" VALUES ('242535683901',12);
INSERT INTO "Student_Enrollment" VALUES ('252535634112',12);
INSERT INTO "Student_Enrollment" VALUES ('252535566920',12);
INSERT INTO "Student_Enrollment" VALUES ('252535565211',12);
INSERT INTO "Student_Enrollment" VALUES ('242535713417',12);
INSERT INTO "Student_Enrollment" VALUES ('232335598009',12);
INSERT INTO "Student_Enrollment" VALUES ('252535596419',12);
INSERT INTO "Student_Enrollment" VALUES ('252535578201',12);
INSERT INTO "Student_Enrollment" VALUES ('252535600605',12);
INSERT INTO "Student_Enrollment" VALUES ('252535607813',12);
INSERT INTO "Student_Enrollment" VALUES ('252535600116',12);
INSERT INTO "Student_Enrollment" VALUES ('252535567212',12);
INSERT INTO "Student_Enrollment" VALUES ('252535596920',12);
INSERT INTO "Student_Enrollment" VALUES ('252535639720',12);
INSERT INTO "Student_Enrollment" VALUES ('252535578214',12);
INSERT INTO "Student_Enrollment" VALUES ('242435588512',12);
INSERT INTO "Student_Enrollment" VALUES ('252535604914',12);
INSERT INTO "Student_Enrollment" VALUES ('242535712413',12);
INSERT INTO "Student_Enrollment" VALUES ('252535634102',12);
INSERT INTO "Student_Enrollment" VALUES ('252535714001',12);
INSERT INTO "Student_Enrollment" VALUES ('252535573906',12);
INSERT INTO "Student_Enrollment" VALUES ('232435672808',12);
INSERT INTO "Student_Enrollment" VALUES ('252535583820',12);
INSERT INTO "Student_Enrollment" VALUES ('252535570702',12);
INSERT INTO "Student_Enrollment" VALUES ('252535571501',12);
INSERT INTO "Student_Enrollment" VALUES ('252535571604',12);
INSERT INTO "Student_Enrollment" VALUES ('252535583320',12);
INSERT INTO "Student_Enrollment" VALUES ('242435582420',12);
INSERT INTO "Student_Enrollment" VALUES ('242535676903',12);
INSERT INTO "Student_Enrollment" VALUES ('232435695910',12);
INSERT INTO "Student_Enrollment" VALUES ('242435571112',12);
INSERT INTO "Students" VALUES ('252535649116','ABI','NORELHOUDA','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('242535683703','ALI ZEGHLACHE','MERYEM','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535568812','ATMANE','KAWTHERFATIMAE ZAHRA','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('242435556206','AZAZ','MOHAMED ISLAM','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('232435669220','BACHIRI','MANAL','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('242535678613','BELDJOUDI','AMANI MEGDOUDA','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('242535679302','BELDJOUDI','Hanine','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('242435583714','BENALLIA','NADJEM EDDINE','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535574020','BEN AMOR','Badr','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535575102','BENLAITER','ABDELMOUMIN','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535571812','BENLOKRICHI','CHOAYB','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535633506','BEN SALAH','DAIA EDDINE','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535628510','BEN SELIKH','KHALID BEN ELWALID','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('232535677807','BENTOUMI','Anes abd el ouahab','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('242535679705','BLIZAK','DALAL','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535566807','BOUDILMI','RANIA','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('232435662418','BOUKHALET','Aya','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535626013','BOULARES','SAFAA','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535597519','DEBBAH','HAITHEM','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535570920','DJEGHLOUL','YASSINE MOATAZ BILLAH','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535566817','FERHAT','RIHAB LAADJ','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535565418','GAGUI','ISLAM ABDERRACHID','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('232335519217','GAGUI','ABDELILLAH','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535565220','GHADBANE','ANES','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535638301','HACHEMI','BRAHIM','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('232535718411','HAMIDI','AMIRA','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('242435608917','HEDJERCI','OMAYMA','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('192535720817','KAMEL','BRAHIM','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('242535720215','KHALILI','MOHEMED LAMIN','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535618809','KHATTAB','NESRINE','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('222435702301','LASSELAT','Adem','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535626105','LEBACHI','MOHAMED AMINE','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('222535686718','LEBOUAZDA','Mohamed yahia','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('232335573008','MAMMERI','Khouloud','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('242435558301','MEGAACHE','YOUCEF','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535571513','MESSEGUEM','AMDJED','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535639509','NECHE','AYMEN','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('242535687704','RAHMANI','EL BARAE ABDELMOUMIN','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535568017','ROUBI','SALAH EDDINE','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('242535713920','SAIAHI','KHEDIDJA','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535694312','TAIBI','RAOUNAK','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('242435556202','TEMMAR','MOHAMED AYOUB','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535571006','ZIANE','YEHIA','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('242435701416','زوارق','عبدو','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535572111','ABDELAZIZ','HOUMAME','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('242535684120','ABI','MAYSSOUN','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535602905','AID','AYA','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535570512','ALLAOUI','HOUDA','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535566719','AMRANE','RAID','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('242435632617','ATTOUI','ALI','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535564607','BAKHTI','ALAE','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('242535684108','BAKHTI','Mounsif','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535597112','BAKHTI','NESRINE FATIMA','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535569708','BENADEL','MOATAZ BILLEH','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535625705','BENAMER','NADJLA','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535628513','BENDAKFAL','KADIDJA','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535607820','BOUAOUINA','ABDERRAOUF','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535569316','BOUDIAF','MOHAMMED NASRALLAH','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535678707','BOUDRISSA','IMANE','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535648716','BOURAS','Meryem','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535645019','BRAHIMI','HIBATALLAH SALSABIL','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('242435635409','BRAHIMI','NESRINE','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('222235532003','CHEMINI','MOHAMED AMINE','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535594503','DEHBI','DALILA','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('242435560804','DILMI','ALAE EDDINE','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535572020','DILMI','MANEL','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('242535679413','GHELLAB','Khouloud','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535608014','HAMACHE','KARIMA','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('232435701003','HEFIED','Mohamed ryadh','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('242535713410','KHALILI','ANAS','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535654313','KHAREF','ALI','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('242535719117','KOADRI','Wail ishak','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535572016','KORICHI','MALAK','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('242535716808','KOUADRI','Maram','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535568418','LAKEHAL','ABDERAHIM','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535565905','LAMARA','ENFAL','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('242535721301','MIHOUBI','Fairouze','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('242435589205','MOKRANE','OUMAIMA ALLAH','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535583912','NACERI','OUARDIR','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535600505','NEZLA','AMEL','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('242435585405','SAADI','REKIA','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('242435560611','SEBAA','ZINEDDINE','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('242535715111','TAHRI','CHAHRAZED','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('242535680913','YOUSFI','SOUNDOUS','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535608213','ZAITER','MALAK','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('232335547802','ZEGUIR','MONSIF EL HOUCINE','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('212235613202','ZERROUAK','Mohammed tahar','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535648220','ALISAOUCHA','ANES','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535649103','ALLAL','AHMED YASSINE','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('242435630103','ALLAL','OMAYMA','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('212535685903','AMRIOU','Aya','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535654316','BAKAI','MOHAMED','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535568603','BATTAT','FOUAD','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535571817','BECHACHE','SAFOUET IMENE','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('222235637108','BELKACEM','BACHIR ELAMINE','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('242535686704','BEN AMOUD','MOUHAMED','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('242435558217','BENKHIREDDINE','YOUSSOUF','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('242535686319','BEN MOKHTAR','SEYFEDDINE','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('242435552115','BOUREZG','ISLAM','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535566511','BOUSSAG','KHALIL','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535626111','CHABANI','Younes','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('242435584511','CHADADI','AYOUB','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535608811','DAIRA','GHASSAN','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535583405','DJERBOUH','FATMA ZAHRA','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535597520','ELBEY','HAITHEM BADREDDINE','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('242435551904','GHOUZI','ANES','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535600705','HALITIM','NOR EL HOUDA','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535621820','HANECHE','ABDELMOUMIN','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535569306','HOUARI','MOHAMMED ABDERRAOUF','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('232435662504','KADI','AYA','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535573818','KHERCHI','ENFAL','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535714011','LAICHI','KHALIL','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('242535720709','LEMKHALTI','Islam','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('232435701306','LOGRAB','Aymen','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535593306','MABROUKI','ANISSE','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535634113','MAZOUZ','MOHAMMED TAHA','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('242435568702','MERABET','ISRA','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('242435553205','MOHAMED CHIKOUCHE','HANANE','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('232335582609','MOHAMMEDI','ABD ELALI','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535598202','NOUIBAT','AMINE','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535636619','OUADAH','AYOUB','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('242435555505','OUADDAH','FATIMA','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535638305','REHAB','ZIYED','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('222235581105','SALEM','MOATEZ BELLAH','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535566107','SEMOUNE','BOCHRA NOUR ELHIDAYA','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('242435597206','SOHBI','INES','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('242535680503','ZEGHLACHE','SARA TORQUIA','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535634119','ZIDANI','WISSAL','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535573902','AICHAOUI','AYYOUB','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('242535694511','ATHMANI','CHAIMA','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535569309','BAKHTI','MOHAMED ABDELWADOUD','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535609515','BENCHABANE','MALEK','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('242435583213','BENREZGUA','YASSAMINE','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535566519','BENYETTOU','DARINE RAWNAQ','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535569005','BERRA','LINA FATIHA','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535568406','BOUBAAYA','ABD ELMODJIB','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252533008214','BOUCHEBBAH','FAIZ','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535584817','BOUDERRADJI','MOHAMMED','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535571610','BOUDIAF','ACHRAF','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535571613','BOUREZG','ELYAMNA','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535573502','BOUSSAG','MOHAMED TAYEB NAOUI','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535593419','CHEBBOUB','IKRAM CHAIMA','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('242435552017','DAOUD','IBRAHIM CHIHAB ELDDINE','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535621706','DRIF','RANIA','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('242435581218','ELBAHI','ABDERRAHMANE','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535568111','GHADBANE','AICHA RITADJ','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('242435556103','GUERBAI','MOHAMMED','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535679213','HAFFAF','HALIMA ESSAADIYA','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535564820','HIMER','ARWA','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('242535684209','HOUICHE','NIBRASS','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('242535687803','KHALFA','Rania','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('242535677814','KHENOUF','ENFAL','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('242535680804','KHEZZARI','SALMA','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535570611','KHODJA','HADIL','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535569406','LAMOUNES','MARAM','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535595909','LAMRAOUI','FATEH HOCINE','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535716705','LOKDAI','MOHAMED ELFATEH','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535572101','MEKADDEM','MEYS','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535583709','MEKKI','MAHDI','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535572018','MEZAACHE','MALEK','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535583610','MOKHTARI','MERIEM','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535569117','NASRI','MOHAMMED ISLAM','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535604420','RAHLI','KHAWLA','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('242435558810','SOUICI','ABDELMALEK','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('242535686306','TABBICHE','Zakarya','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535593310','THARAFI','AYA','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535574316','TOUMI','ABDELMOUNAIM','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535584405','ZAHOUI','ABDERRAHMENE','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535575020','ZERROUGA','SAFA','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535619406','ABDELATIF','ISLEM','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('222235506304','ABDELHAFID','IKRAM','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535565402','ABDELLAOUI','IBTISSAM KHADIDJA','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535578612','AMEUR','ABDNNACER','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('242435559905','AMROUNE','KAWTHER','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('242535688115','ATAMNIA','WISSAL','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535569320','BEDDIAR','MOHAMMED YAZID','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535633508','BELHADJ','Abdelbassit','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535572914','BELHADJ','AYMEN IBRAHIM','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535598209','BELOUADAH','HAYATE','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252531072209','BENCHEBANA','YACINE','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535628718','BENDJERSI','ABDALLAH','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('242435580111','BENFERHAT','DOUAA','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('242435569419','BENGHERAB','ABDELBAKI SAID','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535619001','BENMAGRI','YAAKOUB','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535565601','BENMATOUG','IMANE','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('242535719420','BENSEDID','HOUSSAM','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535571903','BENZAOUI','ABDELDJALIL','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('242435632413','BERRI','SELSABIL','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535639718','BOUREZG','LINA','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535568216','CHAKER','ABDERRAHMEN FAROUQ','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535639803','CHEBABHA','MARWA','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('242435552009','CHERIFI','AYYOUB','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535571816','CHERIGUI','SAFA','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535578406','CHOUBAAR','DHIYAEDDINE','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('242535682220','DJENIDI','ASSAM','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('242435555105','ELHADI','ABDERRAHIM','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535613014','GHADRI','SOUNDOUS','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535567415','MAHMOUDI','SALSABIL','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('242531569006','MAKRI','MERYEM MALEK','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535604606','MECHTA','LINA','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535565506','MEDDAH','IKRAM','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('242435581920','MEDDOUR','MOHAMED LAMINE','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535571703','MENASRI','BAHAEDDINE','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('222235545706','RAOUANE','AHMED','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535639513','ROUANE','IBTISSAM','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('242535721118','SAADI','ABD ELBASSET','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535622004','SAADOUNE','MEYMOUNA','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535607520','SEBIH','DOUA','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535721706','SLIMANI','HANINE','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('232335541804','TENNAH','BACHIR','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535626014','ZIANE','ADEL','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('242535686803','ABDESMAD','Meryem','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('232335553010','ABED','Ilyas abdelalim','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535649106','ABI','ANFAL','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535573609','ALLAL','HIND','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535646506','ALLAL','WEDJDANE','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('25054097358','AOUIDJI','OUSSAMA','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535571917','AOUINA','KAMAL','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535608016','BAADJI','LOGMAN','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535633311','BELKHEIR','ANES','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('242435560803','BENAISSA','ABDELWAHAB','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('232435695504','BENKAIHOUL','BASMA','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('232535683410','BENTOUMI','NASSIM','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535608817','BEZAF','MOHAMMED ANES','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535637016','BOUTERAA','ABDERRAHMANE','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('242435556211','CHAKER','MOHAMMED EL AMIN','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535570905','CHELALGA','YASMINE','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('242435630112','DECHOUCHA','MAROUA','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535593607','HADJI','INES','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535583006','HAMMAL','ZINELAABIDINE','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('242535716712','KACIMI ELHASSANI','MOHAMED ABDALLAH','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535607212','KARA','ANES CHARAFEDDINE','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535599713','KERMICHE','NOUH ABDELHAI','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535570109','KHODJA','NADA','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535582702','KOUDRI','TOUKA','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535604512','LAALI','CHEMS EDDINE','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('232435701808','LAHLALI','DJEHINA INSAF','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('232335624902','LOUGLAIB','Fatima','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535584215','MAZARI','BESMALA','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('222535684212','MEHENNI','NABILA','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535619915','MESSAOUDI','ALI ISHAK','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535628908','MORZOUGLAL','MOHAMED ELAMIN','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('242435558801','MOUSSAI','SAFWAN','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535577010','OUDEH','AHMED YASSINE','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('242435556701','RAHMOUNE','MERYEM','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535567616','RAMDANI','SOUNDOUS','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535583908','REMILI','HEYTHEM SALAH EDDINE','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('232535687812','SAHRAOUI','Soundes','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252532354504','SAOUDI','ABDELILLAH','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535584503','TOUATI','Nour','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('242435598504','TOUMI','HAITHAM','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('232335546007','YACINE','BENSAADOUN','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('242435581316','ABDELMOUMENE','ABDENNOUR','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('242535686110','AMROUCHE','Iyad ed derradji','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('242535695706','AOUADJ','Mousaab','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('242435630104','ARBIA','IMANE','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535566205','ARIOUA','TESNIM','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('242535716209','ATALLAOUI','KADDOUR','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535584207','BENAISSI','AYOUB','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('232331786010','BENDAOUD','MOHAMED','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('242535694915','BENTAYEB','MARIYA','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535584813','BOUCHIBA','ABDELMALEK','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('242535694311','BOUKHARI','ROQIYA SITR ER RAHMAN','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('242535683901','BOUTERAA','MOUSAAB','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535634112','BOUZINA','MOHAMED RAYANE','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535566920','CHELBAB','ROMEYSSA','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535565211','FERAHTIA','AMIN LOUEY','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('242535713417','GACEMI','IMANE','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('232335598009','GUERRA','HASSANAT','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535596419','HADBAOUI','MOHAMED LARBI','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535578201','HEMMAK','AKREM','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535600605','KELBOUZ','RADHIA','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535607813','GHILOUS','TAHER ABDERRAOUF','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535600116','KHACHACHI','SAMI','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535567212','KHALDOUNE','SADJIDA','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535596920','KHEIDRI','MONCIF AMINE','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535639720','KORICHI','MOUAYED','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535578214','KORICHI','MOHAMMED TARIQ','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('242435588512','LALI','ZEHAD AHMED AMIN','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535604914','LAMANI','HICHAM','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('242535712413','MAHMOUDI','AHLAM','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535634102','M''HAMEDI','ABDELHAFIDH','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535714001','NADJOUI','KHEDIDJA MANEL','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535573906','NAILI','ISLAM','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('232435672808','NETTAH','Youcef','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535583820','RABHI','HEDIL','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535570702','RAHMOUNE','HIND','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535571501','SALAMANI','ADEM','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535571604','SAOUDI','IMANE','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('252535583320','SEDKAOUI','AISSA','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('242435582420','TOUAMI','MANAR','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('242535676903','ZELLAGUI','Adem','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('232435695910','ZERROUKI','HANANE','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Students" VALUES ('242435571112','ZIANE','HASSINA','''student@univ-msila.dz''',NULL,NULL,'active');
INSERT INTO "Subjects" VALUES (1,'Bases de données','BDD');
INSERT INTO "Subjects" VALUES (2,'Algorithmes and data structures 1','ASD1');
INSERT INTO "Subjects" VALUES (3,'Algorithmes and Data structures 2','ASD2');
INSERT INTO "Subjects" VALUES (4,'Machine Structure 1','SM1');
INSERT INTO "Subjects" VALUES (5,'Machine Structure 2','SM2');
INSERT INTO "Teacher_Timetable" VALUES (1,1,3,1,'Monday','15:30','17:00','TD','S25');
INSERT INTO "Teacher_Timetable" VALUES (2,7,3,1,'Monday','14:00','15:30','TD','S25');
INSERT INTO "Teacher_Timetable" VALUES (3,6,3,1,'Monday','11:00','12:30','TD','S25');
INSERT INTO "Teacher_Timetable" VALUES (4,2,3,1,'Tuesday','09:30','11:00','TD','S33');
INSERT INTO "Teacher_Timetable" VALUES (5,12,3,1,'Tuesday','08:00','09:30','TD','S33');
INSERT INTO "Teacher_Timetable" VALUES (6,8,3,1,'Tuesday','11:00','12:30','TD','S33');
INSERT INTO "Teacher_Timetable" VALUES (7,1,3,1,'Sunday','08:00','09:30','TD','S25');
INSERT INTO "Teacher_Timetable" VALUES (8,7,3,1,'Sunday','09:30','11:00','TD','S26');
INSERT INTO "Teachers" VALUES (1,'Dr Ghemougui Abdessettar');
INSERT INTO "Teachers" VALUES (2,'Dr Tharafi Abdellah');
INSERT INTO "Teachers" VALUES (3,'Dr Amri Said');
CREATE VIEW vw_At_Risk_Students AS
 SELECT
    s.registration_number,
    s.first_name || ' ' || s.last_name AS student_name,
    se.class_id,
     s.email,

    ROUND(
        (SUM(CASE
            WHEN a.status IN ('Present', 'Late') THEN 1
             ELSE 0
         END) * 100.0) /
         NULLIF(COUNT(a.attendance_id), 0),
        2
    ) AS attendance_rate,

     ROUND(AVG(a.participation_score), 2) AS avg_participation,
    ROUND(AVG(a.discipline_score), 2) AS avg_discipline,
    ROUND(AVG(a.preparation_score), 2) AS avg_preparation,
     ROUND(
         (AVG(a.participation_score) +
          AVG(a.discipline_score) +
          AVG(a.preparation_score)) / 3.0,
         2
     ) AS overall_average,

     CASE
         WHEN (
             (SUM(CASE WHEN a.status IN ('Present', 'Late') THEN 1 ELSE 0 END) * 100.0) /
             NULLIF(COUNT(a.attendance_id), 0)
         ) < 75
         THEN 'Low Attendance'
     END AS attendance_risk,

     CASE
        WHEN (
             (AVG(a.participation_score) +
             AVG(a.discipline_score) +
             AVG(a.preparation_score)) / 3.0
         ) < 50
         THEN 'Low Performance'
     END AS performance_risk

 FROM Students s

 LEFT JOIN Student_Enrollment se
     ON s.registration_number = se.registration_number

 LEFT JOIN Attendance a
     ON s.registration_number = a.registration_number

 WHERE s.status = 'Active'

 GROUP BY
     s.registration_number,
     s.first_name,
     s.last_name,
     se.class_id,
     s.email

 HAVING
     attendance_rate < 75
     OR overall_average < 50
     OR avg_discipline < 60;
CREATE VIEW vw_Class_Statistics AS
SELECT
    c.class_id,
    c.class_name,
    --c.unilevel,
    -- c.academic_year,
    COUNT(DISTINCT se.registration_number) AS total_students,

    COUNT(DISTINCT CASE
        WHEN s.status = 'Active'
        THEN se.registration_number
    END) AS active_students,

    COUNT(DISTINCT sess.session_id) AS total_sessions,

    COUNT(DISTINCT CASE
        WHEN sess.status = 'Completed'
        THEN sess.session_id
    END) AS completed_sessions,

    ROUND(AVG(
        CASE
            WHEN a.status IN ('Present', 'Late') THEN 100.0
            ELSE 0
        END
    ), 2) AS class_attendance_rate

FROM Classes c

LEFT JOIN Student_Enrollment se
    ON c.class_id = se.class_id

LEFT JOIN Students s
    ON se.registration_number = s.registration_number

LEFT JOIN Teacher_Timetable tt
    ON c.class_id = tt.class_id

LEFT JOIN Sessions sess
    ON tt.timetable_id = sess.timetable_id

LEFT JOIN Attendance a
    ON sess.session_id = a.session_id
    AND se.registration_number = a.registration_number

GROUP BY
    c.class_id,
    c.unilevel,
    c.academic_year;
CREATE VIEW vw_Ordered_Students_By_Class AS
SELECT
    se.class_id,
    s.registration_number,
    -- s.first_name,
    -- s.last_name,
    s.first_name || ' ' || s.last_name AS full_name,
    cc.class_name

FROM Student_Enrollment se
JOIN Students s
    ON se.registration_number = s.registration_number

JOIN Classes cc
    ON se.class_id = cc.class_id
WHERE s.status = 'active'

ORDER BY se.class_id, s.last_name, s.first_name;
CREATE VIEW vw_Recent_Sessions AS
SELECT
    sess.session_id,
    tt.class_id,
    sess.session_date,
    sess.status AS session_status,
    sub.subject_shortname,
    tt.session_type,

    COUNT(DISTINCT a.registration_number) AS students_recorded,
    SUM(CASE WHEN a.status = 'Present' THEN 1 ELSE 0 END) AS present,
    SUM(CASE WHEN a.status = 'Absent' THEN 1 ELSE 0 END) AS absent,
    SUM(CASE WHEN a.status = 'Late' THEN 1 ELSE 0 END) AS late,
    ROUND(AVG(a.participation_score), 2) AS avg_participation

FROM Sessions sess

JOIN Teacher_Timetable tt
    ON sess.timetable_id = tt.timetable_id

JOIN Subjects sub
    ON tt.subject_id = sub.subject_id

LEFT JOIN Attendance a
    ON sess.session_id = a.session_id

GROUP BY
    sess.session_id,
    sess.session_date,
    sess.status,
    tt.class_id,
    sub.subject_name,
    tt.session_type

ORDER BY sess.session_date DESC
LIMIT 10;
CREATE VIEW vw_Session_Details AS
SELECT
    sess.session_id,
    sess.session_date,
    sess.status AS session_status,
    tt.timetable_id,
    tt.class_id,
    cc.class_name,
    sub.subject_name,
    sub.subject_shortname,
    t.full_name AS teacher_name,
    tt.day_of_week,
    tt.start_time,
    tt.end_time,
    tt.session_type,
    tt.room_name,
    COUNT(DISTINCT a.registration_number) AS students_recorded,
    SUM(CASE WHEN a.status = 'Present' THEN 1 ELSE 0 END) AS students_present,
    SUM(CASE WHEN a.status = 'Absent' THEN 1 ELSE 0 END) AS students_absent,
    SUM(CASE WHEN a.status = 'Late' THEN 1 ELSE 0 END) AS students_late

FROM Sessions sess

JOIN Teacher_Timetable tt 
    ON sess.timetable_id = tt.timetable_id

JOIN Classes cc 
    ON tt.class_id = cc.class_id

JOIN Subjects sub 
    ON tt.subject_id = sub.subject_id

JOIN Teachers t 
    ON tt.teacher_id = t.teacher_id

LEFT JOIN Attendance a 
    ON sess.session_id = a.session_id

GROUP BY
    sess.session_id, sess.session_date, sess.status,
    tt.timetable_id, tt.class_id,
    sub.subject_name, t.full_name,
    tt.day_of_week,
    tt.start_time, tt.end_time, tt.session_type, tt.room_name;
CREATE VIEW vw_Student_Profile AS
SELECT
    s.registration_number,
    s.first_name || ' ' || s.last_name AS full_name,
    s.first_name,
    s.last_name,
    s.email,
    s.phone,
    s.date_of_birth,
    s.status,
    se.class_id,
    c.class_name,
    c.unilevel,
    c.academic_year
FROM Students s
LEFT JOIN Student_Enrollment se
    ON s.registration_number = se.registration_number
LEFT JOIN Classes c
    ON se.class_id = c.class_id;
CREATE VIEW vw_Weekly_Schedule AS
SELECT
    tt.timetable_id,
    --tt.class_id,
    cc.class_name,
    --sub.subject_name,
    sub.subject_shortname,
    tt.day_of_week,
    tt.start_time,
    tt.end_time,
    tt.session_type,
    tt.room_name,
    CASE tt.day_of_week
        WHEN 'Saturday' THEN 1
        WHEN 'Sunday' THEN 2
        WHEN 'Monday' THEN 3
        WHEN 'Tuesday' THEN 4
        WHEN 'Wednesday' THEN 5
        WHEN 'Thursday' THEN 6
    END AS day_order

FROM Teacher_Timetable tt

JOIN Subjects sub 
    ON tt.subject_id = sub.subject_id

JOIN Classes cc 
    ON tt.class_id = cc.class_id

ORDER BY day_order, tt.start_time;
CREATE INDEX IF NOT EXISTS "idx_attendance_session" ON "Attendance" (
	"session_id"
);
CREATE INDEX IF NOT EXISTS "idx_attendance_status" ON "Attendance" (
	"status"
);
CREATE INDEX IF NOT EXISTS "idx_attendance_student" ON "Attendance" (
	"registration_number"
);
CREATE INDEX IF NOT EXISTS "idx_sessions_date" ON "Sessions" (
	"session_date"
);
CREATE INDEX IF NOT EXISTS "idx_sessions_timetable" ON "Sessions" (
	"timetable_id"
);
CREATE INDEX IF NOT EXISTS "idx_students_name" ON "Students" (
	"last_name",
	"first_name"
);
CREATE INDEX IF NOT EXISTS "idx_timetable_day" ON "Teacher_Timetable" (
	"day_of_week"
);
CREATE INDEX IF NOT EXISTS "idx_timetable_subject" ON "Teacher_Timetable" (
	"subject_id"
);
CREATE TRIGGER enforce_max_two_unilevels
BEFORE INSERT ON Student_Enrollment
BEGIN
    SELECT CASE
        WHEN (
            SELECT COUNT(DISTINCT c.unilevel)
            FROM Student_Enrollment se
            JOIN Classes c ON se.class_id = c.class_id
            WHERE se.registration_number = NEW.registration_number
        ) >= 2

        AND NOT EXISTS (
            SELECT 1
            FROM Student_Enrollment se
            JOIN Classes c ON se.class_id = c.class_id
            WHERE se.registration_number = NEW.registration_number
            AND c.unilevel = (
                SELECT unilevel
                FROM Classes
                WHERE class_id = NEW.class_id
            )
        )

    THEN RAISE(ABORT, 'Student cannot enroll in more than 2 different unilevels')
    END;
END;
COMMIT;
