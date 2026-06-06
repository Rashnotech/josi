import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:josi_ride/core/theme/josi_colors.dart';
import 'package:josi_ride/core/theme/josi_theme.dart';
import 'package:josi_ride/main.dart';

void main() {
  testWidgets('starts on splash and advances to onboarding',
      (WidgetTester tester) async {
    await _pumpApp(tester);

    expect(find.byKey(const ValueKey<String>('splash-screen')), findsOneWidget);
    expect(find.bySemanticsLabel('Josi logo'), findsOneWidget);

    await _finishSplash(tester);

    expect(find.byKey(const ValueKey<String>('onboarding-screen')),
        findsOneWidget);
    expect(find.text('Fast city rides and deliveries'), findsOneWidget);
  });

  testWidgets('role selection opens login and customer home after mock auth',
      (WidgetTester tester) async {
    await _pumpToRoleSelection(tester);

    await tester.tap(find.text('Log in'));
    await tester.pumpAndSettle();

    expect(find.text('Access Josi'), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('login-identity-field')),
        findsOneWidget);
    expect(find.byKey(const ValueKey<String>('login-password-field')),
        findsOneWidget);

    await tester.tap(find.byKey(const ValueKey<String>('login-button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 650));
    await tester.pumpAndSettle();

    expect(find.text('Ready for your next city move?'), findsOneWidget);
    expect(find.text('Where are you going?'), findsOneWidget);
    expect(find.text('Book Ride'), findsOneWidget);
  });

  testWidgets('customer bottom navigation opens wallet',
      (WidgetTester tester) async {
    await _loginAsCustomer(tester);

    await tester.tap(find.text('Wallet').last);
    await tester.pumpAndSettle();

    expect(find.text('Payments and transactions'), findsOneWidget);
    expect(find.text('Available balance'), findsOneWidget);
    expect(find.text('Add money'), findsOneWidget);
  });

  testWidgets('rider registration ends at application status checklist',
      (WidgetTester tester) async {
    await _pumpToRoleSelection(tester);

    await tester.tap(find.text('Continue as Rider'));
    await tester.pumpAndSettle();

    expect(find.text('Rider registration'), findsOneWidget);

    for (int index = 0; index < 3; index++) {
      await tester
          .tap(find.text(index == 2 ? 'Submit application' : 'Continue'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 650));
      await tester.pumpAndSettle();
    }

    expect(find.text('Application status'), findsOneWidget);
    expect(find.text('Profile completed'), findsOneWidget);
    expect(find.text('Documents uploaded'), findsOneWidget);
    expect(find.text('Admin approval'), findsOneWidget);
  });

  test('theme uses Josi red, Material 3, and Inter typography', () {
    final ThemeData theme = JosiTheme.light;

    expect(theme.useMaterial3, isTrue);
    expect(theme.colorScheme.primary, JosiColors.red);
    expect(theme.colorScheme.secondary, JosiColors.charcoal);
    expect(theme.scaffoldBackgroundColor, JosiColors.surface);
    expect(theme.textTheme.bodyMedium?.fontFamily, 'Inter');
  });
}

Future<void> _pumpApp(WidgetTester tester) async {
  await tester.pumpWidget(const ProviderScope(child: JosiApp()));
}

Future<void> _finishSplash(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 1800));
  await tester.pumpAndSettle();
}

Future<void> _pumpToRoleSelection(WidgetTester tester) async {
  await _pumpApp(tester);
  await _finishSplash(tester);
  await tester.tap(find.text('Skip'));
  await tester.pumpAndSettle();
}

Future<void> _loginAsCustomer(WidgetTester tester) async {
  await _pumpToRoleSelection(tester);
  await tester.tap(find.text('Log in'));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const ValueKey<String>('login-button')));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 650));
  await tester.pumpAndSettle();
}
