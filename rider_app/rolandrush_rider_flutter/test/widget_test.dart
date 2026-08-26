// Basic smoke test — verifies the app boots to the Splash screen.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:rolandrush_rider/main.dart';

void main() {
  testWidgets('App boots to Splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: RolandRushRiderApp()));
    await tester.pump();
    expect(find.text('RolandRush'), findsOneWidget);
  });
}
