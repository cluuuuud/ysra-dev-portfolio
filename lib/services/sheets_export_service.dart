import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/sheets/v4.dart' as sheets;
import 'package:http/http.dart' as http;
import 'package:attendance_app/database/db_helper.dart';
import 'package:flutter/foundation.dart' show debugPrint;

class SheetsExportService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'https://www.googleapis.com/auth/spreadsheets',
    ], // ← CORRECT for Sheets
  );

  Future<sheets.SheetsApi?> getSheetsApi() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account == null) return null;

      final authentication = await account.authentication;
      final headers = {'Authorization': 'Bearer ${authentication.accessToken}'};
      final client = GoogleHttpClient(headers);
      return sheets.SheetsApi(client);
    } catch (e) {
      debugPrint('Failed to get Sheets API: $e');
      return null;
    }
  }

  // ✅ CHANGE THIS: Replace with YOUR spreadsheet ID
  Future<bool> exportAttendanceToSheets(
    String sessionId,
    List<Map<String, dynamic>> attendanceData,
  ) async {
    try {
      final sheetsApi = await getSheetsApi();
      if (sheetsApi == null) return false;

      // 🔴 YOU MUST CHANGE THIS - Get YOUR spreadsheet ID
      // Your spreadsheet ID is in the Google Sheets URL:
      // https://docs.google.com/spreadsheets/d/YOUR_SPREADSHEET_ID_HERE/edit
      final String yourSpreadsheetId =
          "1Jsyl7CLtTJJJ0VTCtYuVYihhkEKdvdKDIqyz8yQgt4w"; // ← REPLACE THIS

      // Prepare data rows
      List<List<dynamic>> values = [
        ['Student Name', 'Status', 'Time', 'Notes'],
      ];

      for (var record in attendanceData) {
        values.add([
          record['student_name'],
          record['status'],
          record['marked_at'],
          record['notes'] ?? '',
        ]);
      }

      // Update the sheet
      final valueRange = sheets.ValueRange();
      valueRange.values = values;

      await sheetsApi.spreadsheets.values.update(
        valueRange,
        yourSpreadsheetId, // ← USES YOUR ID HERE
        'Sheet1!A1',
        valueInputOption: 'USER_ENTERED',
      );

      debugPrint('Export successful!');
      return true;
    } catch (e) {
      debugPrint('Export failed: $e');
      return false;
    }
  }
}

// Same GoogleHttpClient class as above
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
