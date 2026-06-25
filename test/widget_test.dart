import 'package:flutter_test/flutter_test.dart';

import 'package:test_flutter_app/main.dart';

void main() {
  testWidgets('PatchQuest smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const PatchQuestApp());

    // Verify that the title is present.
    expect(find.text('PatchQuest'), findsWidgets);
  });
}
