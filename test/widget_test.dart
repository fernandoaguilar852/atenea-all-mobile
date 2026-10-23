import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:atenea_all_mobile/app.dart';

void main() {
  testWidgets('App initializes correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: AteneaApp(),
      ),
    );

    // Verify that the app builds without errors
    expect(find.byType(AteneaApp), findsOneWidget);
  });
}
