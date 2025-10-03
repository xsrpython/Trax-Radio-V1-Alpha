// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:trax_radio_butt/main.dart';

void main() {
  testWidgets('Trax Radio BUTT App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const TraxRadioBUTTApp());

    // Verify that our app loads with the correct title
    expect(find.text('🎵 Trax Radio BUTT App'), findsOneWidget);
    
    // Verify that the app shows the loading state initially
    expect(find.text('Initializing Audio Service...'), findsOneWidget);
  });
}
