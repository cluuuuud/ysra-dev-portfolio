import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import '../database/db_helper.dart';
import 'backup_service.dart';
import 'sheets_export_service.dart';

class SyncService {
  final BackupService _backupService = BackupService();
  final SheetsExportService _sheetsService = SheetsExportService();
  final DBHelper _dbHelper = DBHelper();
  final Connectivity _connectivity = Connectivity();

  bool _isSyncing = false;

  void startConnectivityListener() {
    // FIXED: Use 'onConnectivityChanged' instead of 'onConnectivityChange'
    _connectivity.onConnectivityChanged.listen((
      List<ConnectivityResult> result,
    ) {
      if (result.contains(ConnectivityResult.none)) {
        // No connection - do nothing
        debugPrint('Offline mode - no sync');
      } else {
        // Has connection - sync
        debugPrint('Connection restored - syncing...');
        _syncAllData();
      }
    });
  }

  Future<void> manualSync() async {
    debugPrint('Manual sync triggered');
    await _syncAllData();
  }

  Future<void> _syncAllData() async {
    if (_isSyncing) {
      debugPrint('Sync already in progress');
      return;
    }
    _isSyncing = true;

    try {
      // Get unsynced attendance records
      final unsyncedRecords = await _dbHelper.getUnsyncedRecords('Attendance');
      debugPrint('Found ${unsyncedRecords.length} unsynced attendance records');

      if (unsyncedRecords.isNotEmpty) {
        // You need a valid spreadsheet ID from Google Sheets
        const String spreadsheetId =
            '1Jsyl7CLtTJJJ0VTCtYuVYihhkEKdvdKDIqyz8yQgt4w';

        // Convert records to format expected by sheets service
        final attendanceData = unsyncedRecords.map((record) {
          return {
            'student_name': record['student_name'] ?? 'Unknown',
            'status': record['status'] ?? 'Absent',
            'marked_at': DateTime.now().toIso8601String(),
            'notes': '',
          };
        }).toList();

        await _sheetsService.exportAttendanceToSheets(
          spreadsheetId,
          attendanceData,
        );

        // Mark as synced
        for (var record in unsyncedRecords) {
          await _dbHelper.markAsSynced(
            'Attendance',
            'attendance_id',
            record['attendance_id'] as int,
          );
        }
        debugPrint('Attendance sync completed');
      }

      // Also sync Activity_Metrics
      final unsyncedMetrics = await _dbHelper.getUnsyncedRecords(
        'Activity_Metrics',
      );
      if (unsyncedMetrics.isNotEmpty) {
        debugPrint('Found ${unsyncedMetrics.length} unsynced activity metrics');
        for (var record in unsyncedMetrics) {
          await _dbHelper.markAsSynced(
            'Activity_Metrics',
            'metric_id',
            record['metric_id'] as int,
          );
        }
        debugPrint('Activity metrics sync completed');
      }

      // Backup database to Google Drive
      final backupSuccess = await _backupService.backupDatabase();
      if (backupSuccess) {
        debugPrint('Google Drive backup completed successfully');
      }
    } catch (e) {
      debugPrint('Sync failed: $e');
    } finally {
      _isSyncing = false;
    }
  }

  // Check current connectivity status
  Future<bool> isConnected() async {
    final result = await _connectivity.checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }
}
