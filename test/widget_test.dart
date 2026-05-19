import 'package:flutter_test/flutter_test.dart';

import 'package:attendance_app/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const AttendixApp());
    await tester.pumpAndSettle();
    expect(find.text('Track Attendance.'), findsOneWidget);
  });
}
