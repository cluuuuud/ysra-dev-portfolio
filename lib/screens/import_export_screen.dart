import 'dart:io';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../database/db_helper.dart';
import '../app_colors.dart';

class ImportExportScreen extends StatefulWidget {
  const ImportExportScreen({super.key});

  @override
  State<ImportExportScreen> createState() => _ImportExportScreenState();
}

class _ImportExportScreenState extends State<ImportExportScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  // ── Import state ──────────────────────────────────────────────────────────
  List<Map<String, dynamic>> _previewRows = [];
  List<String> _previewErrors = [];
  int? _selectedClassId;
  List<Map<String, dynamic>> _classes = [];
  bool _importing = false;
  String? _importResult;
  bool _importSuccess = false;

  // ── Export state ──────────────────────────────────────────────────────────
  int? _exportClassId;
  String _exportFormat = 'CSV';
  bool _exporting = false;
  String? _exportResult;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadClasses();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadClasses() async {
    final data = await DBHelper.getClasses();
    setState(() => _classes = data);
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  IMPORT
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );
      if (result == null || result.files.isEmpty) return;

      final path = result.files.single.path;
      if (path == null) {
        _showSnack('Could not read file path', isError: true);
        return;
      }

      await _parseCSV(File(path));
    } catch (e) {
      _showSnack('Error picking file: $e', isError: true);
    }
  }

  Future<void> _parseCSV(File file) async {
    try {
      final content = await file.readAsString();
      final rows = const CsvToListConverter(eol: '\n').convert(content);

      if (rows.isEmpty) {
        _showSnack('File is empty', isError: true);
        return;
      }

      // أول سطر = header
      final header = rows.first.map((e) => e.toString().trim()).toList();

      final regIdx = header.indexOf('registration_number');
      final fnIdx = header.indexOf('first_name');
      final lnIdx = header.indexOf('last_name');

      if (regIdx == -1 || fnIdx == -1 || lnIdx == -1) {
        _showSnack(
          'Missing columns: registration_number, first_name, last_name',
          isError: true,
        );
        return;
      }

      final parsed = <Map<String, dynamic>>[];
      final errors = <String>[];

      for (int i = 1; i < rows.length; i++) {
        final row = rows[i];
        if (row.length <= lnIdx) {
          errors.add('Row $i: not enough columns');
          continue;
        }
        final reg = row[regIdx].toString().trim();
        final fn = row[fnIdx].toString().trim();
        final ln = row[lnIdx].toString().trim();

        if (reg.isEmpty || fn.isEmpty || ln.isEmpty) {
          errors.add('Row $i: empty required field');
          continue;
        }

        parsed.add({
          'registration_number': reg,
          'first_name': fn,
          'last_name': ln,
        });
      }

      setState(() {
        _previewRows = parsed;
        _previewErrors = errors;
        _importResult = null;
      });

      if (parsed.isEmpty) {
        _showSnack('No valid rows found in file', isError: true);
      }
    } catch (e) {
      _showSnack('Parse error: $e', isError: true);
    }
  }

  Future<void> _confirmImport() async {
    if (_selectedClassId == null) {
      _showSnack('Please select a class first', isError: true);
      return;
    }
    if (_previewRows.isEmpty) {
      _showSnack('No rows to import', isError: true);
      return;
    }

    setState(() {
      _importing = true;
      _importResult = null;
    });

    try {
      final result = await DBHelper.importStudents(
        _previewRows,
        _selectedClassId!,
      );
      final inserted = result['inserted'] as int;
      final skipped = result['skipped'] as int;
      final errors = result['errors'] as List<String>;

      setState(() {
        _importSuccess = inserted > 0 || errors.isEmpty;
        _importResult = '$inserted imported · $skipped skipped';
        _previewErrors = errors.take(5).toList();
        _previewRows = [];
        _importing = false;
      });
    } catch (e) {
      setState(() {
        _importResult = 'Import failed: $e';
        _importSuccess = false;
        _importing = false;
      });
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  EXPORT
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> _doExport() async {
    setState(() {
      _exporting = true;
      _exportResult = null;
    });

    try {
      final rows = await DBHelper.getAttendanceExportData(
        classId: _exportClassId,
      );

      if (rows.isEmpty) {
        setState(() {
          _exportResult = 'No data found for the selected filter.';
          _exporting = false;
        });
        return;
      }

      // بناء البيانات المشتركة بين كل الصيغ
      final headers = [
        'registration_number',
        'student_name',
        'class_name',
        'subject',
        'session_type',
        'session_date',
        'start_time',
        'status',
        'notes',
        'participation',
        'discipline',
        'preparation',
      ];

      final dataRows = rows
          .map(
            (r) => [
              r['registration_number']?.toString() ?? '',
              r['student_name']?.toString() ?? '',
              r['class_name']?.toString() ?? '',
              r['subject_shortname']?.toString() ?? '',
              r['session_type']?.toString() ?? '',
              r['session_date']?.toString() ?? '',
              r['start_time']?.toString() ?? '',
              r['status']?.toString() ?? '',
              (r['notes'] ?? '').toString().replaceAll('"', "'"),
              (r['participation_score'] ?? 0).toString(),
              (r['discipline_score'] ?? 0).toString(),
              (r['preparation_score'] ?? 0).toString(),
            ],
          )
          .toList();

      final dir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      late File file;

      if (_exportFormat == 'CSV') {
        // ── CSV ────────────────────────────────────────────────────────────
        final csvData = [headers, ...dataRows];
        final csv = const ListToCsvConverter().convert(csvData);
        file = File('${dir.path}/attendance_$timestamp.csv');
        await file.writeAsString(csv);
      } else if (_exportFormat == 'Excel') {
        // ── Excel (TSV يفتح مباشرة في Excel) ──────────────────────────────
        final buffer = StringBuffer();
        buffer.writeln(headers.join('\t'));
        for (final row in dataRows) {
          buffer.writeln(row.map((c) => c.replaceAll('\t', ' ')).join('\t'));
        }
        file = File('${dir.path}/attendance_$timestamp.tsv');
        await file.writeAsString(buffer.toString());
      } else {
        // ── PDF (HTML → نص منسق قابل للمشاركة) ───────────────────────────
        final buffer = StringBuffer();
        buffer.writeln('ATTENDANCE REPORT');
        buffer.writeln(
          'Generated: ${DateTime.now().toString().substring(0, 16)}',
        );
        buffer.writeln('Records: ${rows.length}');
        buffer.writeln('=' * 60);
        buffer.writeln(headers.join(' | '));
        buffer.writeln('-' * 60);
        for (final row in dataRows) {
          buffer.writeln(row.join(' | '));
        }
        file = File('${dir.path}/attendance_$timestamp.txt');
        await file.writeAsString(buffer.toString());
      }

      // ── Share ───────────────────────────────────────────────────────────────
      try {
        await Share.shareXFiles(
          [XFile(file.path)],
          subject: 'Attendance Export',
          text: 'Attendance data — ${rows.length} records',
        );
      } catch (_) {
        // fallback: نعرض مسار الملف للمستخدم
        if (mounted) {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                'File Saved',
                style: GoogleFonts.lexend(fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${rows.length} records exported successfully.',
                    style: GoogleFonts.lexend(fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.divider,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SelectableText(
                      file.path,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'OK',
                    style: GoogleFonts.lexend(color: AppColors.primary),
                  ),
                ),
              ],
            ),
          );
        }
      }

      setState(() {
        _exportResult = '${rows.length} records exported as $_exportFormat';
        _exporting = false;
      });
    } catch (e) {
      setState(() {
        _exportResult = 'Export failed: $e';
        _exporting = false;
      });
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  BUILD
  // ══════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textMain),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Import / Export',
          style: GoogleFonts.lexend(
            color: AppColors.textMain,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textMuted,
          labelStyle: GoogleFonts.lexend(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          unselectedLabelStyle: GoogleFonts.lexend(fontSize: 14),
          tabs: const [
            Tab(text: 'Import'),
            Tab(text: 'Export'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildImportTab(), _buildExportTab()],
      ),
    );
  }

  // ── Import Tab ─────────────────────────────────────────────────────────────
  Widget _buildImportTab() => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      // Step 1 — اختيار الملف
      _stepCard(
        step: '1',
        title: 'Choose CSV File',
        subtitle: 'Columns: registration_number, first_name, last_name',
        child: GestureDetector(
          onTap: _pickFile,
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.upload_file_outlined,
                  color: AppColors.primary,
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap to pick CSV file',
                  style: GoogleFonts.lexend(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'registration_number, first_name, last_name',
                  style: GoogleFonts.lexend(
                    color: AppColors.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      const SizedBox(height: 16),

      // Step 2 — اختيار القسم
      _stepCard(
        step: '2',
        title: 'Select Class',
        subtitle: 'Students will be enrolled here',
        child: _classDropdown(),
      ),
      const SizedBox(height: 16),

      // Step 3 — Preview
      if (_previewRows.isNotEmpty)
        _stepCard(
          step: '3',
          title: 'Preview (${_previewRows.length} rows)',
          subtitle: 'Review before importing',
          child: Column(
            children: [
              ..._previewRows.take(5).map(_previewRow),
              if (_previewRows.length > 5)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '+ ${_previewRows.length - 5} more rows',
                    style: GoogleFonts.lexend(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ),
              if (_previewErrors.isNotEmpty) ...[
                const SizedBox(height: 10),
                ..._previewErrors.map(_errorRow),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _importing ? null : _confirmImport,
                  child: _importing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Confirm Import',
                          style: GoogleFonts.lexend(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),

      // نتيجة الاستيراد
      if (_importResult != null) ...[
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _importSuccess ? AppColors.successBg : AppColors.dangerBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: (_importSuccess ? AppColors.success : AppColors.danger)
                  .withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                _importSuccess
                    ? Icons.check_circle_outline
                    : Icons.error_outline,
                color: _importSuccess ? AppColors.success : AppColors.danger,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _importResult!,
                  style: GoogleFonts.lexend(
                    color: _importSuccess
                        ? AppColors.success
                        : AppColors.danger,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ],
  );

  // ── Export Tab ─────────────────────────────────────────────────────────────
  Widget _buildExportTab() => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      // Step 1 — فلتر اختياري
      _stepCard(
        step: '1',
        title: 'Filter (optional)',
        subtitle: 'Leave blank to export all',
        child: _classDropdown(
          value: _exportClassId,
          onChanged: (v) => setState(() => _exportClassId = v),
          hint: 'All classes',
        ),
      ),
      const SizedBox(height: 16),

      // Step 2 — صيغة التصدير
      _stepCard(
        step: '2',
        title: 'Export Format',
        subtitle: 'Choose output file type',
        child: Row(
          children: ['CSV', 'Excel', 'PDF'].map((fmt) {
            final sel = fmt == _exportFormat;
            const icons = {
              'CSV': Icons.table_chart_outlined,
              'Excel': Icons.grid_on_outlined,
              'PDF': Icons.picture_as_pdf_outlined,
            };
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _exportFormat = fmt),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: sel ? AppColors.primary : AppColors.divider,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: sel ? AppColors.primary : AppColors.border,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        icons[fmt]!,
                        color: sel ? Colors.white : AppColors.textMuted,
                        size: 22,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        fmt,
                        style: GoogleFonts.lexend(
                          color: sel ? Colors.white : AppColors.textSub,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
      const SizedBox(height: 16),

      // زر التصدير
      SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          onPressed: _exporting ? null : _doExport,
          icon: _exporting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Icon(Icons.download_outlined, color: Colors.white),
          label: Text(
            _exporting ? 'Preparing...' : 'Export $_exportFormat',
            style: GoogleFonts.lexend(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),

      // نتيجة التصدير
      if (_exportResult != null) ...[
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _exportResult!.contains('failed')
                ? AppColors.dangerBg
                : AppColors.successBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color:
                  (_exportResult!.contains('failed')
                          ? AppColors.danger
                          : AppColors.success)
                      .withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                _exportResult!.contains('failed')
                    ? Icons.error_outline
                    : Icons.check_circle_outline,
                color: _exportResult!.contains('failed')
                    ? AppColors.danger
                    : AppColors.success,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _exportResult!,
                  style: GoogleFonts.lexend(
                    color: _exportResult!.contains('failed')
                        ? AppColors.danger
                        : AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],

      const SizedBox(height: 24),

      // معلومات التصدير
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.divider,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Export includes',
              style: GoogleFonts.lexend(
                fontWeight: FontWeight.bold,
                color: AppColors.textMain,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 10),
            _infoRow(
              Icons.check_circle_outline,
              AppColors.success,
              'Student name & registration number',
            ),
            _infoRow(
              Icons.check_circle_outline,
              AppColors.success,
              'Attendance status per session',
            ),
            _infoRow(
              Icons.check_circle_outline,
              AppColors.success,
              'Participation, discipline & preparation scores',
            ),
            _infoRow(
              Icons.check_circle_outline,
              AppColors.success,
              'Session date, time, room & subject',
            ),
          ],
        ),
      ),
    ],
  );

  // ══════════════════════════════════════════════════════════════════════════
  //  SHARED WIDGETS
  // ══════════════════════════════════════════════════════════════════════════

  Widget _stepCard({
    required String step,
    required String title,
    required String subtitle,
    required Widget child,
  }) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  step,
                  style: GoogleFonts.lexend(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.lexend(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMain,
                    fontSize: 14,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.lexend(
                    color: AppColors.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 14),
        child,
      ],
    ),
  );

  Widget _classDropdown({
    int? value,
    ValueChanged<int?>? onChanged,
    String hint = 'Select a class',
  }) {
    final val = value ?? _selectedClassId;
    final onChange = onChanged ?? (v) => setState(() => _selectedClassId = v);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.divider,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: val,
          isExpanded: true,
          hint: Text(
            hint,
            style: GoogleFonts.lexend(color: AppColors.textMuted, fontSize: 13),
          ),
          style: GoogleFonts.lexend(color: AppColors.textMain, fontSize: 13),
          icon: const Icon(Icons.expand_more, color: AppColors.textMuted),
          items: _classes
              .map(
                (c) => DropdownMenuItem<int>(
                  value: c['class_id'] as int,
                  child: Text(c['class_name'] as String),
                ),
              )
              .toList(),
          onChanged: onChange,
        ),
      ),
    );
  }

  Widget _previewRow(Map<String, dynamic> r) => Container(
    margin: const EdgeInsets.only(bottom: 6),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color: AppColors.divider,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      children: [
        Expanded(
          child: Text(
            '${r['last_name']} ${r['first_name']}',
            style: GoogleFonts.lexend(
              color: AppColors.textMain,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          r['registration_number'] as String,
          style: GoogleFonts.lexend(color: AppColors.textMuted, fontSize: 11),
        ),
      ],
    ),
  );

  Widget _errorRow(String msg) => Container(
    margin: const EdgeInsets.only(bottom: 4),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: AppColors.dangerBg,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      children: [
        const Icon(
          Icons.warning_amber_outlined,
          color: AppColors.danger,
          size: 14,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            msg,
            style: GoogleFonts.lexend(color: AppColors.danger, fontSize: 11),
          ),
        ),
      ],
    ),
  );

  Widget _infoRow(IconData icon, Color color, String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(
      children: [
        Icon(icon, color: color, size: 15),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.lexend(color: AppColors.textMuted, fontSize: 12),
          ),
        ),
      ],
    ),
  );

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.lexend()),
        backgroundColor: isError ? AppColors.danger : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
