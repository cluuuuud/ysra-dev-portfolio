import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:attendance_app/database/db_helper.dart';
import 'package:flutter/foundation.dart' show debugPrint;

class BackupService {
  // ✅ NOTHING TO CHANGE HERE - This part is correct
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'https://www.googleapis.com/auth/drive.file',
    ], // ← CORRECT - leave this
  );

  Future<drive.DriveApi?> getDriveApi() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account == null) return null;

      final authentication = await account.authentication;
      final headers = {'Authorization': 'Bearer ${authentication.accessToken}'};
      final client = GoogleHttpClient(headers);
      return drive.DriveApi(client);
    } catch (e) {
      debugPrint('Sign-in failed: $e');
      return null;
    }
  }

  // ✅ NOTHING TO CHANGE - This backup method works as-is
  Future<bool> backupDatabase() async {
    try {
      final driveApi = await getDriveApi();
      if (driveApi == null) return false;

      // Get your database file
      final docsDir = await getApplicationDocumentsDirectory();
      final dbFile = File('${docsDir.path}/attendance.db');

      if (!await dbFile.exists()) {
        debugPrint('Database file not found');

        return false;
      }

      // Create backup filename with timestamp
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final fileName = 'attendance_backup_$timestamp.db';

      // Create Drive file
      final driveFile = drive.File()..name = fileName;

      // Upload
      final result = await driveApi.files.create(
        driveFile,
        uploadMedia: drive.Media(dbFile.openRead(), await dbFile.length()),
      );

      debugPrint('Backup successful! File ID: ${result.id}');
      return true;
    } catch (e) {
      debugPrint('Backup failed: $e');
      return false;
    }
  }
}

// Helper class for HTTP client with auth headers
class GoogleHttpClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  GoogleHttpClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _client.send(request);
  }
}
