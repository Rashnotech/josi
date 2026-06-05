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

    await tester.enterText(find.byKey(const ValueKey<String>('phone-field')), '8114510020');
    await tester.tap(find.byKey(const ValueKey<String>('terms-checkbox')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey<String>('continue-button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('ride-home-screen')), findsOneWidget);
    expect(find.text('Where to?'), findsOneWidget);
    expect(find.text('Later'), findsOneWidget);
  });

  testWidgets('account tab opens the customer account page', (WidgetTester tester) async {
    await tester.pumpWidget(const JosiRideApp());
    await tester.pump(const Duration(milliseconds: 2300));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const ValueKey<String>('phone-field')), '8114510020');
    await tester.tap(find.byKey(const ValueKey<String>('terms-checkbox')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey<String>('continue-button')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Account'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byKey(const ValueKey<String>('account-screen')), findsOneWidget);
    expect(find.text('Rik Space'), findsOneWidget);
    expect(find.bySemanticsLabel('Upload profile picture'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('Payment'), findsOneWidget);
    expect(find.text('Support'), findsOneWidget);
    expect(find.text('Safety'), findsOneWidget);
    expect(find.text('Saved places'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Promotions'), findsNothing);
    expect(find.text('Family Profile'), findsNothing);
    expect(find.text('Work Profile'), findsNothing);
  });

  testWidgets('terms gate blocks incomplete sign in', (WidgetTester tester) async {
    await tester.pumpWidget(const JosiRideApp());
    await tester.pump(const Duration(milliseconds: 2300));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey<String>('continue-button')));
    await tester.pump();

    expect(find.byKey(const ValueKey<String>('sign-in-screen')), findsOneWidget);
    expect(find.text('Enter at least 10 phone digits.'), findsOneWidget);
    expect(find.text('Accept the terms to continue.'), findsOneWidget);
  });

  test('theme uses Josi brand color and Inter typography', () {
    final ThemeData theme = JosiTheme.light;

    expect(theme.colorScheme.primary, JosiColors.red);
    expect(theme.textTheme.bodyMedium?.fontFamily, 'Inter');
    expect(theme.textTheme.headlineLarge?.fontFamily, 'Inter');
  });
}
