// Basic smoke test for Pocket Journal app

import 'package:flutter_test/flutter_test.dart';

import 'package:personal_journal_app/main.dart';

void main() {
  testWidgets('App starts and shows title', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const PocketJournalApp());

    // Wait for initialization
    await tester.pumpAndSettle();

    // Verify that the app title appears
    expect(find.text('Pocket Journal'), findsOneWidget);
  });
}
