import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:josi_ride/src/app.dart';
import 'package:josi_ride/src/theme/josi_colors.dart';
import 'package:josi_ride/src/theme/josi_theme.dart';

void main() {
  testWidgets('starts on splash and advances to sign in', (WidgetTester tester) async {
    await tester.pumpWidget(const JosiRideApp());

    expect(find.byKey(const ValueKey<String>('splash-screen')), findsOneWidget);
    expect(find.text('Josi Ride'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 2300));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('sign-in-screen')), findsOneWidget);
    expect(find.text('Enter your number'), findsOneWidget);
    expect(find.text('Sign in with Google'), findsOneWidget);
  });

  testWidgets('valid sign in moves rider to the home shell', (WidgetTester tester) async {
    await tester.pumpWidget(const JosiRideApp());
    await tester.pump(const Duration(milliseconds: 2300));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey<String>('terms-checkbox')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey<String>('continue-button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('ride-home-screen')), findsOneWidget);
    expect(find.text('Where to?'), findsOneWidget);
    expect(find.text('Later'), findsOneWidget);
  });

  testWidgets('terms gate blocks incomplete sign in', (WidgetTester tester) async {
    await tester.pumpWidget(const JosiRideApp());
    await tester.pump(const Duration(milliseconds: 2300));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey<String>('continue-button')));
    await tester.pump();

    expect(find.byKey(const ValueKey<String>('sign-in-screen')), findsOneWidget);
    expect(find.text('Accept the terms to continue.'), findsOneWidget);
  });

  test('theme uses Josi brand color and Urbanist typography', () {
    final ThemeData theme = JosiTheme.light;

    expect(theme.colorScheme.primary, JosiColors.red);
    expect(theme.textTheme.bodyMedium?.fontFamily, 'Urbanist');
    expect(theme.textTheme.headlineLarge?.fontFamily, 'Urbanist');
  });
}
