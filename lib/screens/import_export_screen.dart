import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../database/db_helper.dart';
import '../app_colors.dart';

// NOTE: أضف هذه الـ packages في pubspec.yaml:
//   file_picker: ^8.0.0
//   csv: ^6.0.0
//   path_provider: ^2.1.2
//   share_plus: ^9.0.0

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

  // ── Import ────────────────────────────────────────────────────────────────

  Future<void> _pickFile() async {
    // Requires file_picker package — uncomment when available:
    //
    // final result = await FilePicker.platform.pickFiles(
    //   type: FileType.custom,
    //   allowedExtensions: ['csv', 'xlsx'],
    // );
    // if (result == null) return;
    // final ext  = result.files.single.extension ?? 'csv';
    // final path = result.files.single.path!;
    // _parseCSV(File(path));

    _showFormatSheet();
  }

  void _showFormatSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'CSV Format Required',
              style: GoogleFonts.lexend(
                fontWeight: FontWeight.bold,
                color: AppColors.textMain,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'registration_number,first_name,last_name\n'
                '252535649116,ABI,NORELHOUDA\n'
                '242535683703,ALI,MERYEM',
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _infoRow(
              Icons.check_circle_outline,
              AppColors.success,
              'First row = header',
            ),
            _infoRow(
              Icons.check_circle_outline,
              AppColors.success,
              'Columns: registration_number, first_name, last_name',
            ),
            _infoRow(
              Icons.info_outline,
              AppColors.warning,
              'Duplicates are skipped automatically',
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  Navigator.pop(context);
                  _loadDemoPreview();
                },
                child: Text(
                  'Load Demo Preview',
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
    );
  }

  void _loadDemoPreview() {
    setState(() {
      _previewRows = [
        {
          'registration_number': '252535000001',
          'first_name': 'DEMO',
          'last_name': 'STUDENT_A',
        },
        {
          'registration_number': '252535000002',
          'first_name': 'DEMO',
          'last_name': 'STUDENT_B',
        },
        {
          'registration_number': '252535649116',
          'first_name': 'ABI',
          'last_name': 'NORELHOUDA',
        },
      ];
      _previewErrors = [];
      _importResult = null;
    });
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
      // ✅ DBHelper.importStudents (signature: rows, classId)
      final result = await DBHelper.importStudents(
        _previewRows,
        _selectedClassId!,
      );
      final inserted = result['inserted'] as int;
      final skipped = result['skipped'] as int;
      final errors = result['errors'] as List<String>;

      setState(() {
        _importSuccess = errors.isEmpty || inserted > 0;
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

  // ── Export ────────────────────────────────────────────────────────────────

  Future<void> _doExport() async {
    setState(() {
      _exporting = true;
      _exportResult = null;
    });
    try {
      // ✅ getAttendanceExportData (classId optional)
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

      // بناء CSV
      final header =
          'registration_number,student_name,class_name,'
          'subject,session_type,session_date,start_time,'
          'status,notes,participation,discipline,preparation';

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

      // حفظ الملف (يحتاج path_provider + share_plus):
      // final dir  = await getTemporaryDirectory();
      // final file = File('${dir.path}/attendance_export.csv');
      // await file.writeAsString(csv);
      // await Share.shareXFiles([XFile(file.path)], text: 'Attendance Export');

      setState(() {
        _exportResult =
            'Ready · ${rows.length} records\n(Add share_plus to enable file sharing)';
        _exporting = false;
      });
    } catch (e) {
      setState(() {
        _exportResult = 'Export failed: $e';
        _exporting = false;
      });
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

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

  // ── Import Tab ────────────────────────────────────────────────────────────
  Widget _buildImportTab() => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      // Step 1
      _stepCard(
        step: '1',
        title: 'Choose File',
        subtitle: 'CSV or XLSX with student data',
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
                  'Tap to pick CSV / XLSX',
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

      // Step 2
      _stepCard(
        step: '2',
        title: 'Select Class',
        subtitle: 'Students will be enrolled here',
        child: _classDropdown(),
      ),
      const SizedBox(height: 16),

      // Step 3: Preview
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

      // Result
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

  // ── Export Tab ────────────────────────────────────────────────────────────
  Widget _buildExportTab() => ListView(
    padding: const EdgeInsets.all(20),
    children: [
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

      if (_exportResult != null) ...[
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.successBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.success.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: AppColors.success),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _exportResult!,
                  style: GoogleFonts.lexend(
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],

      const SizedBox(height: 24),
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

  // ── Shared helpers ────────────────────────────────────────────────────────
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
          icon: const Icon(Icons.expand_more, color: Color(0xFF94A3B8)),
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
