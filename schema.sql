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
CREATE TABLE IF NOT EXISTS "Audit_Log" (
	"id"	INTEGER,
	"action"	TEXT,
	"entity"	TEXT,
	"timestamp"	TEXT DEFAULT CURRENT_TIMESTAMP,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "Classes" (
	"class_id"	INTEGER,
	"group_name"	TEXT,
	"unilevel"	TEXT,
	"academic_year"	TEXT,
	PRIMARY KEY("class_id" AUTOINCREMENT),
	UNIQUE("group_name","unilevel","academic_year")
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
	"session_type"	TEXT NOT NULL CHECK("session_type" IN ('Lecture', 'TD', 'TP')),
	PRIMARY KEY("registration_number","class_id","session_type"),
	FOREIGN KEY("class_id") REFERENCES "Classes"("class_id") ON DELETE CASCADE,
	FOREIGN KEY("registration_number") REFERENCES "Students"("registration_number") ON DELETE CASCADE
);
CREATE TABLE IF NOT EXISTS "Students" (
	"registration_number"	TEXT,
	"first_name"	TEXT NOT NULL,
	"last_name"	TEXT NOT NULL,
	"email"	TEXT UNIQUE,
	"phone"	TEXT,
	"date_of_birth"	TEXT,
	"status"	TEXT DEFAULT 'Active' CHECK("status" IN ('Active', 'Inactive', 'Graduated', 'Withdrawn')),
	PRIMARY KEY("registration_number")
);
CREATE TABLE IF NOT EXISTS "Subjects" (
	"subject_id"	INTEGER,
	"subject_name"	TEXT NOT NULL UNIQUE,
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
INSERT INTO "Audit_Log" VALUES (1,'SEED_EXECUTED','ATTENDIX_PRO_FULL_FIXED','2026-05-06 13:12:38');
INSERT INTO "Audit_Log" VALUES (2,'SEED_EXECUTED','ATTENDIX_PRO_FULL_FIXED','2026-05-06 13:12:40');
INSERT INTO "Audit_Log" VALUES (3,'SEED_EXECUTED','ATTENDIX_PRO_FULL_FIXED','2026-05-06 13:17:37');
INSERT INTO "Audit_Log" VALUES (4,'SEED_EXECUTED','ATTENDIX_PRO_FULL_FIXED','2026-05-06 13:18:32');
INSERT INTO "Audit_Log" VALUES (5,'SEED_EXECUTED','ATTENDIX_PRO_FULL_FIXED','2026-05-06 13:18:50');
INSERT INTO "Audit_Log" VALUES (6,'SEED_EXECUTED','ATTENDIX_PRO_FULL_FIXED','2026-05-06 14:05:57');
INSERT INTO "Audit_Log" VALUES (7,'SEED_EXECUTED','ATTENDIX_PRO_FULL_FIXED','2026-05-06 14:09:52');
INSERT INTO "Classes" VALUES (1,'A01','Licence','2025-2026');
INSERT INTO "Classes" VALUES (8,'A01','Licence Informatique','2025-2026');
INSERT INTO "Rooms" VALUES ('S25');
INSERT INTO "Rooms" VALUES ('S26');
INSERT INTO "Rooms" VALUES ('S28');
INSERT INTO "Rooms" VALUES ('S33');
INSERT INTO "Rooms" VALUES ('S32');
INSERT INTO "Rooms" VALUES ('TP-13');
INSERT INTO "Rooms" VALUES ('TP-14');
INSERT INTO "Rooms" VALUES ('TP-15');
INSERT INTO "Rooms" VALUES ('TP-16');
INSERT INTO "Student_Enrollment" VALUES ('2.52536E+11',1,'Lecture');
INSERT INTO "Student_Enrollment" VALUES ('212235613202',1,'Lecture');
INSERT INTO "Student_Enrollment" VALUES ('212235613252',1,'Lecture');
INSERT INTO "Student_Enrollment" VALUES ('222235532003',1,'Lecture');
INSERT INTO "Student_Enrollment" VALUES ('232335547802',1,'Lecture');
INSERT INTO "Student_Enrollment" VALUES ('232435701003',1,'Lecture');
INSERT INTO "Student_Enrollment" VALUES ('242435560611',1,'Lecture');
INSERT INTO "Student_Enrollment" VALUES ('242435560804',1,'Lecture');
INSERT INTO "Student_Enrollment" VALUES ('242435585405',1,'Lecture');
INSERT INTO "Student_Enrollment" VALUES ('242435589205',1,'Lecture');
INSERT INTO "Student_Enrollment" VALUES ('242435632617',1,'Lecture');
INSERT INTO "Student_Enrollment" VALUES ('242435635409',1,'Lecture');
INSERT INTO "Student_Enrollment" VALUES ('242535679413',1,'Lecture');
INSERT INTO "Student_Enrollment" VALUES ('242535680913',1,'Lecture');
INSERT INTO "Student_Enrollment" VALUES ('242535684108',1,'Lecture');
INSERT INTO "Student_Enrollment" VALUES ('242535684120',1,'Lecture');
INSERT INTO "Student_Enrollment" VALUES ('242535713410',1,'Lecture');
INSERT INTO "Student_Enrollment" VALUES ('242535715111',1,'Lecture');
INSERT INTO "Student_Enrollment" VALUES ('242535716808',1,'Lecture');
INSERT INTO "Student_Enrollment" VALUES ('242535719117',1,'Lecture');
INSERT INTO "Student_Enrollment" VALUES ('242535721301',1,'Lecture');
INSERT INTO "Student_Enrollment" VALUES ('252535564607',1,'Lecture');
INSERT INTO "Student_Enrollment" VALUES ('252535565905',1,'Lecture');
INSERT INTO "Student_Enrollment" VALUES ('252535566719',1,'Lecture');
INSERT INTO "Student_Enrollment" VALUES ('252535568418',1,'Lecture');
INSERT INTO "Student_Enrollment" VALUES ('252535569316',1,'Lecture');
INSERT INTO "Student_Enrollment" VALUES ('252535569708',1,'Lecture');
INSERT INTO "Student_Enrollment" VALUES ('252535570512',1,'Lecture');
INSERT INTO "Student_Enrollment" VALUES ('252535572016',1,'Lecture');
INSERT INTO "Student_Enrollment" VALUES ('252535572020',1,'Lecture');
INSERT INTO "Student_Enrollment" VALUES ('252535572111',1,'Lecture');
INSERT INTO "Student_Enrollment" VALUES ('252535583912',1,'Lecture');
INSERT INTO "Student_Enrollment" VALUES ('252535594503',1,'Lecture');
INSERT INTO "Student_Enrollment" VALUES ('252535597112',1,'Lecture');
INSERT INTO "Student_Enrollment" VALUES ('252535600505',1,'Lecture');
INSERT INTO "Student_Enrollment" VALUES ('252535602905',1,'Lecture');
INSERT INTO "Student_Enrollment" VALUES ('252535607820',1,'Lecture');
INSERT INTO "Student_Enrollment" VALUES ('252535608014',1,'Lecture');
INSERT INTO "Student_Enrollment" VALUES ('252535608213',1,'Lecture');
INSERT INTO "Student_Enrollment" VALUES ('252535625705',1,'Lecture');
INSERT INTO "Student_Enrollment" VALUES ('252535628513',1,'Lecture');
INSERT INTO "Student_Enrollment" VALUES ('252535645019',1,'Lecture');
INSERT INTO "Student_Enrollment" VALUES ('252535648716',1,'Lecture');
INSERT INTO "Student_Enrollment" VALUES ('252535654313',1,'Lecture');
INSERT INTO "Student_Enrollment" VALUES ('252535678707',1,'Lecture');
INSERT INTO "Student_Enrollment" VALUES ('2.52536E+11',1,'TD');
INSERT INTO "Student_Enrollment" VALUES ('212235613202',1,'TD');
INSERT INTO "Student_Enrollment" VALUES ('212235613252',1,'TD');
INSERT INTO "Student_Enrollment" VALUES ('222235532003',1,'TD');
INSERT INTO "Student_Enrollment" VALUES ('232335547802',1,'TD');
INSERT INTO "Student_Enrollment" VALUES ('232435701003',1,'TD');
INSERT INTO "Student_Enrollment" VALUES ('242435560611',1,'TD');
INSERT INTO "Student_Enrollment" VALUES ('242435560804',1,'TD');
INSERT INTO "Student_Enrollment" VALUES ('242435585405',1,'TD');
INSERT INTO "Student_Enrollment" VALUES ('242435589205',1,'TD');
INSERT INTO "Student_Enrollment" VALUES ('242435632617',1,'TD');
INSERT INTO "Student_Enrollment" VALUES ('242435635409',1,'TD');
INSERT INTO "Student_Enrollment" VALUES ('242535679413',1,'TD');
INSERT INTO "Student_Enrollment" VALUES ('242535680913',1,'TD');
INSERT INTO "Student_Enrollment" VALUES ('242535684108',1,'TD');
INSERT INTO "Student_Enrollment" VALUES ('242535684120',1,'TD');
INSERT INTO "Student_Enrollment" VALUES ('242535713410',1,'TD');
INSERT INTO "Student_Enrollment" VALUES ('242535715111',1,'TD');
INSERT INTO "Student_Enrollment" VALUES ('242535716808',1,'TD');
INSERT INTO "Student_Enrollment" VALUES ('242535719117',1,'TD');
INSERT INTO "Student_Enrollment" VALUES ('242535721301',1,'TD');
INSERT INTO "Student_Enrollment" VALUES ('252535564607',1,'TD');
INSERT INTO "Student_Enrollment" VALUES ('252535565905',1,'TD');
INSERT INTO "Student_Enrollment" VALUES ('252535566719',1,'TD');
INSERT INTO "Student_Enrollment" VALUES ('252535568418',1,'TD');
INSERT INTO "Student_Enrollment" VALUES ('252535569316',1,'TD');
INSERT INTO "Student_Enrollment" VALUES ('252535569708',1,'TD');
INSERT INTO "Student_Enrollment" VALUES ('252535570512',1,'TD');
INSERT INTO "Student_Enrollment" VALUES ('252535572016',1,'TD');
INSERT INTO "Student_Enrollment" VALUES ('252535572020',1,'TD');
INSERT INTO "Student_Enrollment" VALUES ('252535572111',1,'TD');
INSERT INTO "Student_Enrollment" VALUES ('252535583912',1,'TD');
INSERT INTO "Student_Enrollment" VALUES ('252535594503',1,'TD');
INSERT INTO "Student_Enrollment" VALUES ('252535597112',1,'TD');
INSERT INTO "Student_Enrollment" VALUES ('252535600505',1,'TD');
INSERT INTO "Student_Enrollment" VALUES ('252535602905',1,'TD');
INSERT INTO "Student_Enrollment" VALUES ('252535607820',1,'TD');
INSERT INTO "Student_Enrollment" VALUES ('252535608014',1,'TD');
INSERT INTO "Student_Enrollment" VALUES ('252535608213',1,'TD');
INSERT INTO "Student_Enrollment" VALUES ('252535625705',1,'TD');
INSERT INTO "Student_Enrollment" VALUES ('252535628513',1,'TD');
INSERT INTO "Student_Enrollment" VALUES ('252535645019',1,'TD');
INSERT INTO "Student_Enrollment" VALUES ('252535648716',1,'TD');
INSERT INTO "Student_Enrollment" VALUES ('252535654313',1,'TD');
INSERT INTO "Student_Enrollment" VALUES ('252535678707',1,'TD');
INSERT INTO "Student_Enrollment" VALUES ('2.52536E+11',8,'Lecture');
INSERT INTO "Student_Enrollment" VALUES ('212235613202',8,'Lecture');
INSERT INTO "Student_Enrollment" VALUES ('212235613252',8,'Lecture');
INSERT INTO "Student_Enrollment" VALUES ('222235532003',8,'Lecture');
INSERT INTO "Student_Enrollment" VALUES ('232335547802',8,'Lecture');
INSERT INTO "Student_Enrollment" VALUES ('232435701003',8,'Lecture');
INSERT INTO "Student_Enrollment" VALUES ('242435560611',8,'Lecture');
INSERT INTO "Student_Enrollment" VALUES ('242435560804',8,'Lecture');
INSERT INTO "Student_Enrollment" VALUES ('242435585405',8,'Lecture');
INSERT INTO "Student_Enrollment" VALUES ('242435589205',8,'Lecture');
INSERT INTO "Student_Enrollment" VALUES ('242435632617',8,'Lecture');
INSERT INTO "Student_Enrollment" VALUES ('242435635409',8,'Lecture');
INSERT INTO "Student_Enrollment" VALUES ('242535679413',8,'Lecture');
INSERT INTO "Student_Enrollment" VALUES ('242535680913',8,'Lecture');
INSERT INTO "Student_Enrollment" VALUES ('242535684108',8,'Lecture');
INSERT INTO "Student_Enrollment" VALUES ('242535684120',8,'Lecture');
INSERT INTO "Student_Enrollment" VALUES ('242535713410',8,'Lecture');
INSERT INTO "Student_Enrollment" VALUES ('242535715111',8,'Lecture');
INSERT INTO "Student_Enrollment" VALUES ('242535716808',8,'Lecture');
INSERT INTO "Student_Enrollment" VALUES ('242535719117',8,'Lecture');
INSERT INTO "Student_Enrollment" VALUES ('242535721301',8,'Lecture');
INSERT INTO "Student_Enrollment" VALUES ('252535564607',8,'Lecture');
INSERT INTO "Student_Enrollment" VALUES ('252535565905',8,'Lecture');
INSERT INTO "Student_Enrollment" VALUES ('252535566719',8,'Lecture');
INSERT INTO "Student_Enrollment" VALUES ('252535568418',8,'Lecture');
INSERT INTO "Student_Enrollment" VALUES ('252535569316',8,'Lecture');
INSERT INTO "Student_Enrollment" VALUES ('252535569708',8,'Lecture');
INSERT INTO "Student_Enrollment" VALUES ('252535570512',8,'Lecture');
INSERT INTO "Student_Enrollment" VALUES ('252535572016',8,'Lecture');
INSERT INTO "Student_Enrollment" VALUES ('252535572020',8,'Lecture');
INSERT INTO "Student_Enrollment" VALUES ('252535572111',8,'Lecture');
INSERT INTO "Student_Enrollment" VALUES ('252535583912',8,'Lecture');
INSERT INTO "Student_Enrollment" VALUES ('252535594503',8,'Lecture');
INSERT INTO "Student_Enrollment" VALUES ('252535597112',8,'Lecture');
INSERT INTO "Student_Enrollment" VALUES ('252535600505',8,'Lecture');
INSERT INTO "Student_Enrollment" VALUES ('252535602905',8,'Lecture');
INSERT INTO "Student_Enrollment" VALUES ('252535607820',8,'Lecture');
INSERT INTO "Student_Enrollment" VALUES ('252535608014',8,'Lecture');
INSERT INTO "Student_Enrollment" VALUES ('252535608213',8,'Lecture');
INSERT INTO "Student_Enrollment" VALUES ('252535625705',8,'Lecture');
INSERT INTO "Student_Enrollment" VALUES ('252535628513',8,'Lecture');
INSERT INTO "Student_Enrollment" VALUES ('252535645019',8,'Lecture');
INSERT INTO "Student_Enrollment" VALUES ('252535648716',8,'Lecture');
INSERT INTO "Student_Enrollment" VALUES ('252535654313',8,'Lecture');
INSERT INTO "Student_Enrollment" VALUES ('252535678707',8,'Lecture');
INSERT INTO "Student_Enrollment" VALUES ('2.52536E+11',8,'TD');
INSERT INTO "Student_Enrollment" VALUES ('212235613202',8,'TD');
INSERT INTO "Student_Enrollment" VALUES ('212235613252',8,'TD');
INSERT INTO "Student_Enrollment" VALUES ('222235532003',8,'TD');
INSERT INTO "Student_Enrollment" VALUES ('232335547802',8,'TD');
INSERT INTO "Student_Enrollment" VALUES ('232435701003',8,'TD');
INSERT INTO "Student_Enrollment" VALUES ('242435560611',8,'TD');
INSERT INTO "Student_Enrollment" VALUES ('242435560804',8,'TD');
INSERT INTO "Student_Enrollment" VALUES ('242435585405',8,'TD');
INSERT INTO "Student_Enrollment" VALUES ('242435589205',8,'TD');
INSERT INTO "Student_Enrollment" VALUES ('242435632617',8,'TD');
INSERT INTO "Student_Enrollment" VALUES ('242435635409',8,'TD');
INSERT INTO "Student_Enrollment" VALUES ('242535679413',8,'TD');
INSERT INTO "Student_Enrollment" VALUES ('242535680913',8,'TD');
INSERT INTO "Student_Enrollment" VALUES ('242535684108',8,'TD');
INSERT INTO "Student_Enrollment" VALUES ('242535684120',8,'TD');
INSERT INTO "Student_Enrollment" VALUES ('242535713410',8,'TD');
INSERT INTO "Student_Enrollment" VALUES ('242535715111',8,'TD');
INSERT INTO "Student_Enrollment" VALUES ('242535716808',8,'TD');
INSERT INTO "Student_Enrollment" VALUES ('242535719117',8,'TD');
INSERT INTO "Student_Enrollment" VALUES ('242535721301',8,'TD');
INSERT INTO "Student_Enrollment" VALUES ('252535564607',8,'TD');
INSERT INTO "Student_Enrollment" VALUES ('252535565905',8,'TD');
INSERT INTO "Student_Enrollment" VALUES ('252535566719',8,'TD');
INSERT INTO "Student_Enrollment" VALUES ('252535568418',8,'TD');
INSERT INTO "Student_Enrollment" VALUES ('252535569316',8,'TD');
INSERT INTO "Student_Enrollment" VALUES ('252535569708',8,'TD');
INSERT INTO "Student_Enrollment" VALUES ('252535570512',8,'TD');
INSERT INTO "Student_Enrollment" VALUES ('252535572016',8,'TD');
INSERT INTO "Student_Enrollment" VALUES ('252535572020',8,'TD');
INSERT INTO "Student_Enrollment" VALUES ('252535572111',8,'TD');
INSERT INTO "Student_Enrollment" VALUES ('252535583912',8,'TD');
INSERT INTO "Student_Enrollment" VALUES ('252535594503',8,'TD');
INSERT INTO "Student_Enrollment" VALUES ('252535597112',8,'TD');
INSERT INTO "Student_Enrollment" VALUES ('252535600505',8,'TD');
INSERT INTO "Student_Enrollment" VALUES ('252535602905',8,'TD');
INSERT INTO "Student_Enrollment" VALUES ('252535607820',8,'TD');
INSERT INTO "Student_Enrollment" VALUES ('252535608014',8,'TD');
INSERT INTO "Student_Enrollment" VALUES ('252535608213',8,'TD');
INSERT INTO "Student_Enrollment" VALUES ('252535625705',8,'TD');
INSERT INTO "Student_Enrollment" VALUES ('252535628513',8,'TD');
INSERT INTO "Student_Enrollment" VALUES ('252535645019',8,'TD');
INSERT INTO "Student_Enrollment" VALUES ('252535648716',8,'TD');
INSERT INTO "Student_Enrollment" VALUES ('252535654313',8,'TD');
INSERT INTO "Student_Enrollment" VALUES ('252535678707',8,'TD');
INSERT INTO "Students" VALUES ('252535572111','ABI','NORELHOUDA','abi.norelhouda@univ.test','5535649111','01-01-2003','Active');
INSERT INTO "Students" VALUES ('242535684120','ALI ZEGHLACHE','MERYEM','ali.zeghlache.meryem@univ.test','5535683713','01-01-2003','Active');
INSERT INTO "Students" VALUES ('252535602905','ATMANE','KAWTHERFATIMAE ZAHRA','atmane.kawtherfatimae@univ.test','5535568812','01-01-2003','Active');
INSERT INTO "Students" VALUES ('252535570512','AZAZ','MOHAMED ISLAM','azaz.mohamed@univ.test','5535556206','01-01-2003','Active');
INSERT INTO "Students" VALUES ('252535566719','BACHIRI','MANAL','bachiri.manal@univ.test','5535669220','01-01-2003','Active');
INSERT INTO "Students" VALUES ('242435632617','BELDJOUDI','AMANI MEGDOUDA','beldjoudi.amani@univ.test','5535678613','01-01-2003','Active');
INSERT INTO "Students" VALUES ('252535564607','BELDJOUDI','Hanine','beldjoudi.hanine@univ.test','5535679302','01-01-2003','Active');
INSERT INTO "Students" VALUES ('242535684108','BENALLIA','NADJEM EDDINE','benallia.nadjem@univ.test','5535583714','01-01-2003','Active');
INSERT INTO "Students" VALUES ('252535597112','BEN AMOR','Badr','benamor.badr@univ.test','5535574020','01-01-2003','Active');
INSERT INTO "Students" VALUES ('252535569708','BENLAITER','ABDELMOUMIN','benlaiter.abdelmoumin@univ.test','5535575102','01-01-2003','Active');
INSERT INTO "Students" VALUES ('252535625705','BENLOKRICHI','CHOAYB','benlokrichi.choayb@univ.test','5535571812','01-01-2003','Active');
INSERT INTO "Students" VALUES ('252535628513','BEN SALAH','DAIA EDDINE','bensalah.daia@univ.test','5535633506','01-01-2003','Active');
INSERT INTO "Students" VALUES ('252535607820','BEN SELIKH','KHALID BEN ELWALID','benselikh.khalid@univ.test','5535628510','01-01-2003','Active');
INSERT INTO "Students" VALUES ('252535569316','BENTOUMI','ANES ABD EL OUAHAB','bentoumi.anes@univ.test','5535677807','01-01-2003','Active');
INSERT INTO "Students" VALUES ('252535678707','BLIZAK','DALAL','blizak.dalal@univ.test','5535679705','01-01-2003','Active');
INSERT INTO "Students" VALUES ('252535648716','BOUDILMI','RANIA','boudilmi.rania@univ.test','5535566807','01-01-2003','Active');
INSERT INTO "Students" VALUES ('252535645019','BOUKHALET','Aya','boukhalet.aya@univ.test','5535662418','01-01-2003','Active');
INSERT INTO "Students" VALUES ('242435635409','BOULARES','SAFAA','boulares.safaa@univ.test','5535626013','01-01-2003','Active');
INSERT INTO "Students" VALUES ('222235532003','DEBBAH','HAITHEM','debbah.haithem@univ.test','5535597519','01-01-2003','Active');
INSERT INTO "Students" VALUES ('252535594503','DJEGHLOUL','YASSINE MOATAZ BILLAH','djeghloul.yassine@univ.test','5535570920','01-01-2003','Active');
INSERT INTO "Students" VALUES ('242435560804','FERHAT','RIHAB LAADJ','ferhat.rihab@univ.test','5535566817','01-01-2003','Active');
INSERT INTO "Students" VALUES ('252535572020','GAGUI','ISLAM ABDERRACHID','gagui.islam@univ.test','5535565418','01-01-2003','Active');
INSERT INTO "Students" VALUES ('242535679413','GAGUI','ABDELILLAH','gagui.abdelillah@univ.test','5535519217','01-01-2003','Active');
INSERT INTO "Students" VALUES ('252535608014','GHADBANE','ANES','ghadbane.anes@univ.test','5535565220','01-01-2003','Active');
INSERT INTO "Students" VALUES ('232435701003','HACHEMI','BRAHIM','hachemi.brahim@univ.test','5535638301','01-01-2003','Active');
INSERT INTO "Students" VALUES ('242535713410','HAMIDI','AMIRA','hamidi.amira@univ.test','5535718411','01-01-2003','Active');
INSERT INTO "Students" VALUES ('252535654313','HEDJERCI','OMAYMA','hedjerci.omayma@univ.test','5535608917','01-01-2003','Active');
INSERT INTO "Students" VALUES ('242535719117','KAMEL','BRAHIM','kamel.brahim@univ.test','5535720817','01-01-2003','Active');
INSERT INTO "Students" VALUES ('252535572016','KHALILI','MOHEMED LAMIN','khalili.mohemed@univ.test','5535720215','01-01-2003','Active');
INSERT INTO "Students" VALUES ('242535716808','KHATTAB','NESRINE','khattab.nesrine@univ.test','5535618809','01-01-2003','Active');
INSERT INTO "Students" VALUES ('252535568418','LASSELAT','Adem','lasselat.adem@univ.test','5535702301','01-01-2003','Active');
INSERT INTO "Students" VALUES ('252535565905','LEBACHI','MOHAMED AMINE','lebachi.mohamed@univ.test','5535626105','01-01-2003','Active');
INSERT INTO "Students" VALUES ('242535721301','LEBOUAZDA','Mohamed yahia','lebouazda.yahia@univ.test','5535686718','01-01-2003','Active');
INSERT INTO "Students" VALUES ('242435589205','MAMMERI','Khouloud','mammeri.khouloud@univ.test','5535573008','01-01-2003','Active');
INSERT INTO "Students" VALUES ('252535583912','MEGAACHE','YOUCEF','megaache.youcef@univ.test','5535558301','01-01-2003','Active');
INSERT INTO "Students" VALUES ('252535600505','MESSEGUEM','AMDJED','messeguem.amdjed@univ.test','5535571513','01-01-2003','Active');
INSERT INTO "Students" VALUES ('242435585405','NECHE','AYMEN','neche.aymen@univ.test','5535639509','01-01-2003','Active');
INSERT INTO "Students" VALUES ('242435560611','RAHMANI','EL BARAE ABDELMOUMIN','rahmani.elbarae@univ.test','5535687704','01-01-2003','Active');
INSERT INTO "Students" VALUES ('242535715111','ROUBI','SALAH EDDINE','roubi.salah@univ.test','5535568017','01-01-2003','Active');
INSERT INTO "Students" VALUES ('242535680913','SAIAHI','KHEDIDJA','saiahi.khedidja@univ.test','5535713920','01-01-2003','Active');
INSERT INTO "Students" VALUES ('252535608213','TAIBI','RAOUNAK','taibi.raounak@univ.test','5535694312','01-01-2003','Active');
INSERT INTO "Students" VALUES ('232335547802','TEMMAR','MOHAMED AYOUB','temmar.ayoub@univ.test','5535556202','01-01-2003','Active');
INSERT INTO "Students" VALUES ('212235613202','ZIANE','YEHIA','ziane.yehia@univ.test','5535571006','01-01-2003','Active');
INSERT INTO "Students" VALUES ('212235613252','زوارق','عبدو','zouareg.abdou@univ.test','5535701416','01-01-2003','Active');
INSERT INTO "Students" VALUES ('2.52536E+11','ABDELAZIZ','HOUMAME','abdelaziz.houmame@univ.test','5535572111','01-01-2003','Active');
INSERT INTO "Subjects" VALUES (1,'Bases de données');
INSERT INTO "Subjects" VALUES (2,'Algorithmes');
INSERT INTO "Subjects" VALUES (3,'Programmation');
INSERT INTO "Subjects" VALUES (22,'Bases de Données Avancées');
INSERT INTO "Subjects" VALUES (23,'Algorithmique et Structures de Données');
INSERT INTO "Subjects" VALUES (24,'Programmation Orientée Objet');
INSERT INTO "Teachers" VALUES (1,'Dr Ghemougui Abdessettar');
INSERT INTO "Teachers" VALUES (2,'Dr Ghemougui Abdessettar');
INSERT INTO "Teachers" VALUES (3,'Dr Ghemougui Abdessettar
');
INSERT INTO "Teachers" VALUES (4,'Dr Ghemougui Abdessettar');
INSERT INTO "Teachers" VALUES (5,'Dr Ghemougui Abdessettar');
INSERT INTO "Teachers" VALUES (6,'Dr Ghemougui Abdessettar');
INSERT INTO "Teachers" VALUES (7,'Dr Ghemougui Abdessettar');
INSERT INTO "Teachers" VALUES (8,'Dr Ghemougui Abdessettar');
INSERT INTO "Teachers" VALUES (9,'Dr Ghemougui Abdessettar');
INSERT INTO "Teachers" VALUES (10,'Dr Ghemougui Abdessettar');
INSERT INTO "Teachers" VALUES (11,'Dr Ghemougui Abdessettar');
INSERT INTO "Teachers" VALUES (12,'Dr Ghemougui Abdessettar');
INSERT INTO "Teachers" VALUES (13,'Dr. Ghemougui Abdessettar');
INSERT INTO "Teachers" VALUES (14,'Dr. Ghemougui Abdessettar');
INSERT INTO "Teachers" VALUES (15,'Dr. Ghemougui Abdessettar');
INSERT INTO "Teachers" VALUES (16,'Dr. Ghemougui Abdessettar');
INSERT INTO "Teachers" VALUES (17,'Dr. Ghemougui Abdessettar');
INSERT INTO "Teachers" VALUES (18,'Dr. Ghemougui Abdessettar');
INSERT INTO "Teachers" VALUES (19,'Dr. Ghemougui Abdessettar');
INSERT INTO "Teachers" VALUES (20,'Dr. Ghemougui Abdessettar');
INSERT INTO "Teachers" VALUES (21,'Dr. Ghemougui Abdessettar');
INSERT INTO "Teachers" VALUES (22,'Dr. Ghemougui Abdessettar');
INSERT INTO "Teachers" VALUES (23,'Dr. Ghemougui Abdessettar');
INSERT INTO "Teachers" VALUES (24,'Dr. Ghemougui Abdessettar');
INSERT INTO "Teachers" VALUES (25,'Dr. Ghemougui Abdessettar');
INSERT INTO "Teachers" VALUES (26,'Dr. Ghemougui Abdessettar');
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
    c.unilevel,
    c.academic_year,

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
CREATE VIEW vw_Current_Session AS
SELECT
    sess.session_id,
    sess.session_date,
    sess.start_time,
    sess.status,

    tt.class_id,
    sub.subject_name,
    tt.session_type,
    tt.day_of_week,
    tt.start_time AS timetable_start,
    tt.end_time AS timetable_end,
    tt.room_name

FROM Sessions sess

JOIN Teacher_Timetable tt
    ON sess.timetable_id = tt.timetable_id

JOIN Subjects sub
    ON tt.subject_id = sub.subject_id

WHERE
    sess.session_date = DATE('now')
    AND TIME('now') BETWEEN tt.start_time AND tt.end_time;
CREATE VIEW vw_Next_Session AS
SELECT
    sess.session_id,
    sess.session_date,
    sess.start_time,

    sub.subject_name,
    tt.class_id,
    tt.session_type,
    tt.room_name

FROM Sessions sess

JOIN Teacher_Timetable tt
    ON sess.timetable_id = tt.timetable_id

JOIN Subjects sub
    ON tt.subject_id = sub.subject_id

WHERE
    sess.status = 'Scheduled'
    AND (
        sess.session_date > DATE('now')
        OR (
            sess.session_date = DATE('now')
            AND sess.start_time > TIME('now')
        )
    )

ORDER BY sess.session_date ASC, sess.start_time ASC
LIMIT 1;
CREATE VIEW vw_Ordered_Students_By_Class AS
SELECT
    se.class_id,
    s.registration_number,
    s.first_name,
    s.last_name,
    s.first_name || ' ' || s.last_name AS full_name

FROM Student_Enrollment se
JOIN Students s
    ON se.registration_number = s.registration_number

WHERE s.status = 'Active'

-- ⚠️ مهم: نضيف ORDER BY مع class
ORDER BY se.class_id, s.last_name, s.first_name;
CREATE VIEW vw_Recent_Sessions AS
SELECT
    sess.session_id,
    sess.session_date,
    sess.status AS session_status,
    tt.class_id,
    sub.subject_name,
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
CREATE VIEW vw_Session_Attendance_Detail AS
SELECT
    a.attendance_id,
    sess.session_id,
    sess.session_date,
    tt.class_id,
    sub.subject_name,
    tt.session_type,
    s.registration_number,
    s.first_name || ' ' || s.last_name AS student_name,
    a.status,
    a.arrival_time,
    a.notes AS attendance_notes

FROM Attendance a

JOIN Students s
    ON a.registration_number = s.registration_number

JOIN Sessions sess
    ON a.session_id = sess.session_id

JOIN Teacher_Timetable tt
    ON sess.timetable_id = tt.timetable_id

JOIN Subjects sub
    ON tt.subject_id = sub.subject_id;
CREATE VIEW vw_Session_Attendance_Rate AS
SELECT
    sess.session_id,
    tt.class_id,

    ROUND(
        (SUM(CASE WHEN a.status IN ('Present','Late') THEN 1 ELSE 0 END) * 100.0) /
        COUNT(a.attendance_id),
        2
    ) AS attendance_rate

FROM Sessions sess
JOIN Teacher_Timetable tt
    ON sess.timetable_id = tt.timetable_id
LEFT JOIN Attendance a
    ON sess.session_id = a.session_id

GROUP BY sess.session_id, tt.class_id;
CREATE VIEW vw_Session_Details AS
SELECT
    sess.session_id,
    sess.session_date,
    sess.status AS session_status,
    tt.timetable_id,
    tt.class_id,
    sub.subject_name,
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
CREATE VIEW vw_Student_Attendance_Summary AS
SELECT
    s.registration_number,
    s.first_name || ' ' || s.last_name AS student_name,
    se.class_id,

    COUNT(a.attendance_id) AS total_sessions,

    SUM(CASE WHEN a.status = 'Present' THEN 1 ELSE 0 END) AS sessions_present,
    SUM(CASE WHEN a.status = 'Absent' THEN 1 ELSE 0 END) AS sessions_absent,
    SUM(CASE WHEN a.status = 'Late' THEN 1 ELSE 0 END) AS sessions_late,
    SUM(CASE WHEN a.status = 'Excused' THEN 1 ELSE 0 END) AS sessions_excused,

    ROUND(
        (SUM(CASE WHEN a.status IN ('Present', 'Late') THEN 1 ELSE 0 END) * 100.0) /
        NULLIF(COUNT(a.attendance_id), 0),
        2
    ) AS attendance_rate

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
    se.class_id;
CREATE VIEW vw_Student_Performance AS
SELECT
    s.registration_number,
    s.first_name || ' ' || s.last_name AS student_name,
    se.class_id,

    COUNT(a.attendance_id) AS total_evaluations,

    ROUND(AVG(a.participation_score), 2) AS avg_participation,
    ROUND(AVG(a.discipline_score), 2) AS avg_discipline,
    ROUND(AVG(a.preparation_score), 2) AS avg_preparation,

    ROUND(
        (AVG(a.participation_score) +
         AVG(a.discipline_score) +
         AVG(a.preparation_score)) / 3.0,
        2
    ) AS overall_average,

    MIN(a.participation_score) AS min_participation,
    MAX(a.participation_score) AS max_participation

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
    se.class_id;
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
    c.unilevel,
    c.academic_year
FROM Students s
LEFT JOIN Student_Enrollment se
    ON s.registration_number = se.registration_number
LEFT JOIN Classes c
    ON se.class_id = c.class_id;
CREATE VIEW vw_Subject_Performance AS
SELECT
    sub.subject_name,
    tt.class_id,

    COUNT(DISTINCT se.registration_number) AS students_enrolled,

    COUNT(DISTINCT sess.session_id) AS sessions_held,

    COUNT(DISTINCT CASE
        WHEN sess.status = 'Completed'
        THEN sess.session_id
    END) AS sessions_completed,

    ROUND(AVG(a.participation_score), 2) AS avg_participation,
    ROUND(AVG(a.discipline_score), 2) AS avg_discipline,
    ROUND(AVG(a.preparation_score), 2) AS avg_preparation,

    ROUND(AVG(
        CASE
            WHEN a.status IN ('Present', 'Late') THEN 100.0
            ELSE 0
        END
    ), 2) AS attendance_rate

FROM Teacher_Timetable tt

JOIN Subjects sub
    ON tt.subject_id = sub.subject_id

LEFT JOIN Sessions sess
    ON tt.timetable_id = sess.timetable_id

LEFT JOIN Student_Enrollment se
    ON tt.class_id = se.class_id

LEFT JOIN Students s
    ON se.registration_number = s.registration_number
    AND s.status = 'Active'

LEFT JOIN Attendance a
    ON sess.session_id = a.session_id
    AND se.registration_number = a.registration_number

GROUP BY
    sub.subject_name,
    tt.class_id;
CREATE VIEW vw_Weekly_Schedule AS
SELECT
    tt.timetable_id,
    tt.class_id,
    sub.subject_name,
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
