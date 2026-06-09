import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:josi_ride/core/theme/josi_colors.dart';
import 'package:josi_ride/core/theme/josi_theme.dart';
import 'package:josi_ride/main.dart';

void main() {
  testWidgets('starts on red splash and advances to role selection',
      (WidgetTester tester) async {
    await _pumpApp(tester);

    expect(find.byKey(const ValueKey<String>('splash-screen')), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('splash-logo')), findsOneWidget);
    expect(find.bySemanticsLabel('Josi splash logo'), findsOneWidget);

    await _finishSplash(tester);

    expect(find.byKey(const ValueKey<String>('role-selection-screen')),
        findsOneWidget);
    expect(find.text('Welcome to Josi Ride'), findsOneWidget);
    expect(find.text('Continue as Customer'), findsOneWidget);
    expect(find.text('Continue as Rider'), findsOneWidget);
  });

  testWidgets('customer role opens customer login and signs into customer home',
      (WidgetTester tester) async {
    await _pumpToRoleSelection(tester);

    await tester.ensureVisible(find.text('Get Started'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    expect(find.text('Customer Login'), findsOneWidget);
    expect(find.text('Secure your ride. Enter your details below.'),
        findsOneWidget);
    expect(find.byKey(const ValueKey<String>('login-logo')), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('login-identity-field')),
        findsOneWidget);
    expect(find.byKey(const ValueKey<String>('login-password-field')),
        findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);

    await tester
        .ensureVisible(find.byKey(const ValueKey<String>('login-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey<String>('login-button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 650));
    await tester.pumpAndSettle();

    expect(find.text('Ready for your next city move?'), findsOneWidget);
    expect(find.text('Where are you going?'), findsOneWidget);
    expect(find.text('Book Ride'), findsOneWidget);
  });

  testWidgets(
      'rider role opens rider login and create account reaches rider signup',
      (WidgetTester tester) async {
    await _pumpToRoleSelection(tester);

    await tester.ensureVisible(find.text('Drive with Us'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Drive with Us'));
    await tester.pumpAndSettle();

    expect(find.text('Rider Login'), findsOneWidget);
    expect(find.text('Rider Dashboard Access'), findsOneWidget);

    await tester.ensureVisible(find.text('Create account'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Create account'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('rider-register-screen')),
        findsOneWidget);
    expect(find.text('Drive with Josi Ride'), findsOneWidget);
    expect(find.text('Start earning on your own schedule'), findsOneWidget);
    expect(find.text('Vehicle Type'), findsOneWidget);
    expect(find.text('Sign Up to Drive'), findsOneWidget);

    await tester.ensureVisible(
        find.byKey(const ValueKey<String>('rider-sign-up-button')));
    await tester.pumpAndSettle();
    await tester
        .tap(find.byKey(const ValueKey<String>('rider-sign-up-button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 650));
    await tester.pumpAndSettle();

    expect(find.text('Application status'), findsOneWidget);
    expect(find.text('Profile completed'), findsOneWidget);
    expect(find.text('Documents uploaded'), findsOneWidget);
    expect(find.text('Admin approval'), findsOneWidget);
  });

  testWidgets('customer create account opens customer signup and submits',
      (WidgetTester tester) async {
    await _pumpToRoleSelection(tester);

    await tester.ensureVisible(find.text('Get Started'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Create account'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Create account'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('customer-register-screen')),
        findsOneWidget);
    expect(find.text('Create Account'), findsOneWidget);
    expect(find.text('Join Josi Ride today'), findsOneWidget);
    expect(find.text('Full Name'), findsOneWidget);
    expect(find.text('Sign Up'), findsOneWidget);

    await tester.ensureVisible(
        find.byKey(const ValueKey<String>('customer-sign-up-button')));
    await tester.pumpAndSettle();
    await tester
        .tap(find.byKey(const ValueKey<String>('customer-sign-up-button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 650));
    await tester.pumpAndSettle();

    expect(find.text('Ready for your next city move?'), findsOneWidget);
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

  test('theme follows the Josi light redline', () {
    final ThemeData theme = JosiTheme.light;

    expect(theme.useMaterial3, isTrue);
    expect(theme.colorScheme.primary, JosiColors.red);
    expect(JosiColors.red, const Color(0xFFE31837));
    expect(theme.colorScheme.secondary, JosiColors.charcoal);
    expect(theme.scaffoldBackgroundColor, JosiColors.surface);
    expect(theme.textTheme.bodyMedium?.fontFamily, 'Inter');
  });
}

Future<void> _pumpApp(WidgetTester tester) async {
  tester.view.physicalSize = const Size(430, 932);
  tester.view.devicePixelRatio = 1;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
  await tester.pumpWidget(const ProviderScope(child: JosiApp()));
}

Future<void> _finishSplash(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 1800));
  await tester.pumpAndSettle();
}

Future<void> _pumpToRoleSelection(WidgetTester tester) async {
  await _pumpApp(tester);
  await _finishSplash(tester);
}

Future<void> _loginAsCustomer(WidgetTester tester) async {
  await _pumpToRoleSelection(tester);
  await tester.ensureVisible(find.text('Get Started'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Get Started'));
  await tester.pumpAndSettle();
  await tester
      .ensureVisible(find.byKey(const ValueKey<String>('login-button')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const ValueKey<String>('login-button')));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 650));
  await tester.pumpAndSettle();
}
