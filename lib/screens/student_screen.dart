import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:attendance_app/database/db_helper.dart';
import 'package:attendance_app/app_colors.dart';

String _studentDisplayName(Map<String, dynamic> s) {
  final fn = (s['first_name'] ?? '').toString().trim();
  final ln = (s['last_name'] ?? '').toString().trim();
  final combined = '$fn $ln'.trim();
  if (combined.isNotEmpty) return combined;
  final full = (s['full_name'] ?? '').toString().trim();
  if (full.isNotEmpty) return full;
  return '—';
}

List<String> _splitStudentNameForEdit(Map<String, dynamic> s) {
  final fn = (s['first_name'] ?? '').toString().trim();
  final ln = (s['last_name'] ?? '').toString().trim();
  if (fn.isNotEmpty || ln.isNotEmpty) return [fn, ln];
  final full = (s['full_name'] ?? '').toString().trim();
  if (full.isEmpty) return ['', ''];
  final parts = full.split(RegExp(r'\s+'));
  if (parts.length == 1) return [parts[0], ''];
  return [parts.first, parts.sublist(1).join(' ')];
}

class StudentsScreen extends StatefulWidget {
  final int? classId;
  final String? className;

  const StudentsScreen({super.key, this.classId, this.className});

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  List<Map<String, dynamic>> _students = [];
  bool _loading = true;
  bool _initialized = false;
  int? _classId;
  String _className = 'Students';
  final _searchCtrl = TextEditingController();
  String _search = '';

  @override
  void initState() {
    super.initState();
    if (widget.classId != null) {
      _classId = widget.classId;
      _className = widget.className ?? 'Students';
      _load();
      _initialized = true;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map<String, dynamic>) {
        _classId = args['classId'] as int?;
        _className = args['className'] as String? ?? 'Students';
      } else if (args is int) {
        _classId = args;
      }
      _initialized = true;
      _load();
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (_classId == null) {
      setState(() => _loading = false);
      return;
    }
    setState(() => _loading = true);
    try {
      final data = await DBHelper.getStudentsByClass(_classId!);
      if (mounted) {
        setState(() {
          _students = data;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showAddDialog({Map<String, dynamic>? existing}) {
    final regCtrl = TextEditingController(
      text: existing?['registration_number'] as String? ?? '',
    );
    final split = existing != null
        ? _splitStudentNameForEdit(existing)
        : ['', ''];
    final firstCtrl = TextEditingController(text: split[0]);
    final lastCtrl = TextEditingController(text: split[1]);
    final emailCtrl = TextEditingController(
      text: existing?['email'] as String? ?? '',
    );
    final isEdit = existing != null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              isEdit ? 'Edit Student' : 'Add Student',
              style: GoogleFonts.lexend(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: regCtrl,
              enabled: !isEdit,
              decoration: const InputDecoration(labelText: 'Registration'),
            ),
            TextField(
              controller: firstCtrl,
              decoration: const InputDecoration(labelText: 'First name'),
            ),
            TextField(
              controller: lastCtrl,
              decoration: const InputDecoration(labelText: 'Last name'),
            ),
            TextField(
              controller: emailCtrl,
              decoration: const InputDecoration(labelText: 'Email (optional)'),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () async {
                      final reg = regCtrl.text.trim();
                      final first = firstCtrl.text.trim();
                      final last = lastCtrl.text.trim();
                      final email = emailCtrl.text.trim();
                      if (reg.isEmpty || first.isEmpty || last.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Fill all required fields'),
                          ),
                        );
                        return;
                      }
                      try {
                        if (isEdit) {
                          final d = await DBHelper.db;
                          final n = await d.update(
                            'Students',
                            {
                              'first_name': first,
                              'last_name': last,
                              if (email.isNotEmpty) 'email': email,
                            },
                            where: 'registration_number = ?',
                            whereArgs: [existing['registration_number']],
                          );
                          if (mounted) Navigator.pop(context);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(n > 0 ? 'Saved' : 'No change'),
                              ),
                            );
                          }
                        } else {
                          await DBHelper.insertStudentWithEnrollment(
                            registrationNumber: reg,
                            firstName: first,
                            lastName: last,
                            classId: _classId!,
                            email: email.isNotEmpty ? email : null,
                          );
                          if (mounted) Navigator.pop(context);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Student added')),
                            );
                          }
                        }
                        _load();
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text('$e')));
                        }
                      }
                    },
                    child: Text(isEdit ? 'Update' : 'Add'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> get _filtered {
    if (_search.isEmpty) return _students;
    final q = _search.toLowerCase();
    return _students.where((s) {
      final name = _studentDisplayName(s).toLowerCase();
      final reg = (s['registration_number'] ?? '').toString().toLowerCase();
      return name.contains(q) || reg.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        title: Text(
          _className,
          style: GoogleFonts.lexend(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (_classId != null)
            IconButton(
              icon: const Icon(Icons.person_add_outlined),
              onPressed: () => _showAddDialog(),
            ),
        ],
      ),
      body: _classId == null
          ? const Center(child: Text('No class'))
          : _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (v) => setState(() => _search = v),
                    decoration: const InputDecoration(
                      hintText: 'Search…',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _filtered.length,
                    itemBuilder: (_, i) {
                      final s = _filtered[i];
                      return ListTile(
                        title: Text(
                          _studentDisplayName(s),
                          style: GoogleFonts.lexend(),
                        ),
                        subtitle: Text(
                          s['registration_number']?.toString() ?? '',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () => _showAddDialog(existing: s),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
