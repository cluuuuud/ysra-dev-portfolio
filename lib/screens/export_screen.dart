import 'dart:io';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:attendance_app/database/db_helper.dart';
import 'package:attendance_app/app_colors.dart';

class ImportExportScreen extends StatefulWidget {
  const ImportExportScreen({super.key});

  @override
  State<ImportExportScreen> createState() => _ImportExportScreenState();
}

class _ImportExportScreenState extends State<ImportExportScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab = TabController(length: 2, vsync: this);
  List<Map<String, dynamic>> _classes = [];
  List<Map<String, dynamic>> _preview = [];
  int? _importClassId;
  int? _exportClassId;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _loadClasses();
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  Future<void> _loadClasses() async {
    final c = await DBHelper.getClasses();
    setState(() => _classes = c);
  }

  Future<void> _pickCsv() async {
    try {
      final r = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['csv'],
        withData: true,
      );
      if (r == null || r.files.isEmpty) return;
      final f = r.files.single;
      String? text;
      if (f.bytes != null && f.bytes!.isNotEmpty) {
        text = String.fromCharCodes(f.bytes!);
      } else if (f.path != null) {
        text = await File(f.path!).readAsString();
      }
      if (text == null) return;
      final rows = const CsvToListConverter().convert(text.trim(), shouldParseNumbers: false);
      if (rows.isEmpty) return;
      final h = rows.first.map((e) => e.toString().toLowerCase().trim()).toList();
      final iR = h.indexOf('registration_number');
      final iF = h.indexOf('first_name');
      final iL = h.indexOf('last_name');
      if (iR < 0 || iF < 0 || iL < 0) {
        _snack('Header must include registration_number, first_name, last_name', err: true);
        return;
      }
      String cell(List<dynamic> row, int i) => i < row.length ? row[i].toString().trim() : '';
      final out = <Map<String, dynamic>>[];
      for (var k = 1; k < rows.length; k++) {
        final row = rows[k];
        out.add({
          'registration_number': cell(row, iR),
          'first_name': cell(row, iF),
          'last_name': cell(row, iL),
        });
      }
      setState(() => _preview = out.where((e) => e['registration_number']!.toString().isNotEmpty).toList());
    } catch (e) {
      _snack('$e', err: true);
    }
  }

  Future<void> _runImport() async {
    if (_importClassId == null || _preview.isEmpty) {
      _snack('Select class and CSV', err: true);
      return;
    }
    setState(() => _busy = true);
    try {
      final r = await DBHelper.importStudents(_preview, _importClassId!);
      _snack('Imported ${r['inserted']}, skipped ${r['skipped']}');
      setState(() => _preview = []);
    } finally {
      setState(() => _busy = false);
    }
  }

  Future<void> _runExport() async {
    setState(() => _busy = true);
    try {
      final rows = await DBHelper.getAttendanceExportData(classId: _exportClassId);
      if (rows.isEmpty) {
        _snack('No data', err: true);
        return;
      }
      const header =
          'registration_number,student_name,class_name,subject,session_type,session_date,start_time,status,notes,participation,discipline,preparation';
      final lines = rows.map(
        (r) =>
            '"${r['registration_number']}",'
            '"${r['student_name']}",'
            '"${r['class_name']}",'
            '"${r['subject_shortname']}",'
            '"${r['session_type']}",'
            '"${r['session_date']}",'
            '"${r['start_time']}",'
            '"${r['status']}",'
            '"${(r['notes'] ?? '').toString().replaceAll('"', "'")}",'
            '${r['participation_score'] ?? 0},'
            '${r['discipline_score'] ?? 0},'
            '${r['preparation_score'] ?? 0}',
      );
      final csv = '$header\n${lines.join('\n')}';
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/attendance_export.csv');
      await file.writeAsString(csv);
      await Share.shareXFiles([XFile(file.path)], text: 'ATTENDIX export');
      _snack('Exported ${rows.length} rows');
    } catch (e) {
      _snack('$e', err: true);
    } finally {
      setState(() => _busy = false);
    }
  }

  void _snack(String m, {bool err = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(m, style: GoogleFonts.lexend(color: Colors.white)),
        backgroundColor: err ? AppColors.danger : AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        title: Text('Import / Export', style: GoogleFonts.lexend(fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tab,
          tabs: const [Tab(text: 'Import'), Tab(text: 'Export')],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          ListView(
            padding: const EdgeInsets.all(20),
            children: [
              FilledButton(onPressed: _busy ? null : _pickCsv, child: const Text('Pick CSV')),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                // ignore: deprecated_member_use
                value: _importClassId,
                hint: const Text('Class'),
                items: _classes
                    .map((c) {
                      final id = DBHelper.parseId(c['class_id']);
                      if (id == null) return null;
                      return DropdownMenuItem(value: id, child: Text(c['class_name']?.toString() ?? ''));
                    })
                    .whereType<DropdownMenuItem<int>>()
                    .toList(),
                onChanged: (v) => setState(() => _importClassId = v),
              ),
              const SizedBox(height: 12),
              Text('Preview: ${_preview.length} rows'),
              FilledButton(onPressed: _busy ? null : _runImport, child: const Text('Import')),
            ],
          ),
          ListView(
            padding: const EdgeInsets.all(20),
            children: [
              DropdownButtonFormField<int?>(
                // ignore: deprecated_member_use
                value: _exportClassId,
                decoration: const InputDecoration(labelText: 'Filter by class'),
                items: [
                  const DropdownMenuItem<int?>(value: null, child: Text('All classes')),
                  ..._classes.map((c) {
                    final id = DBHelper.parseId(c['class_id']);
                    if (id == null) return null;
                    return DropdownMenuItem<int?>(
                      value: id,
                      child: Text(c['class_name']?.toString() ?? ''),
                    );
                  }).whereType<DropdownMenuItem<int?>>(),
                ],
                onChanged: (v) => setState(() => _exportClassId = v),
              ),
              const SizedBox(height: 12),
              FilledButton(onPressed: _busy ? null : _runExport, child: const Text('Export CSV & share')),
            ],
          ),
        ],
      ),
    );
  }
}
