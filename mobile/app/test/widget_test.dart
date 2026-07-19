import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:josi_ride/core/theme/josi_theme.dart';
import 'package:josi_ride/features/auth/auth_screens.dart';

void main() {
  testWidgets('role selection renders compact entry actions',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: JosiTheme.light,
        home: const RoleSelectionScreen(),
      ),
    );

    expect(find.byKey(const ValueKey<String>('role-selection-screen')),
        findsOneWidget);
    expect(find.text('Welcome to Josi Ride'), findsOneWidget);
    expect(find.text('Continue as Customer'), findsOneWidget);
    expect(find.text('Continue as Rider'), findsOneWidget);
  });
}
