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
    expect(
        find.byKey(const ValueKey<String>('splash-tagline')), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('splash-loader')), findsOneWidget);
    expect(find.bySemanticsLabel('Josi splash logo'), findsOneWidget);

    await _finishSplash(tester);

    expect(find.byKey(const ValueKey<String>('role-selection-screen')),
        findsOneWidget);
    expect(find.text('Welcome to Josi Ride'), findsOneWidget);
    expect(find.text('Continue as Customer'), findsOneWidget);
    expect(find.text('Continue as Rider'), findsOneWidget);
    _expectVisibleInViewport(tester, find.text('Get Started'));
    _expectVisibleInViewport(tester, find.text('Drive with Us'));
    _expectVisibleInViewport(tester, find.text('POWERED BY JOSI RIDE'));
  });

  testWidgets('customer role opens customer login and signs into customer home',
      (WidgetTester tester) async {
    await _pumpToRoleSelection(tester);

    _expectVisibleInViewport(tester, find.text('Get Started'));
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
    _expectVisibleInViewport(
        tester, find.byKey(const ValueKey<String>('login-button')));
    _expectVisibleInViewport(tester, find.text('Continue with Google'));
    _expectVisibleInViewport(tester, find.text('Create account'));

    await tester.tap(find.byKey(const ValueKey<String>('login-button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 650));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('customer-home-screen')),
        findsOneWidget);
    expect(find.text('Where to?'), findsOneWidget);
    expect(find.text('Destination'), findsOneWidget);
    expect(find.text('Last Trip'), findsOneWidget);
    _expectVisibleInViewport(tester, find.text('Home'));
    _expectVisibleInViewport(tester, find.text('Activity'));
  });

  testWidgets(
      'rider role opens rider login and create account reaches rider signup',
      (WidgetTester tester) async {
    await _pumpToRoleSelection(tester);

    _expectVisibleInViewport(tester, find.text('Drive with Us'));
    await tester.tap(find.text('Drive with Us'));
    await tester.pumpAndSettle();

    expect(find.text('Rider Login'), findsOneWidget);
    expect(find.text('Rider Dashboard Access'), findsOneWidget);
    _expectVisibleInViewport(tester, find.text('Create account'));

    await tester.tap(find.text('Create account'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('rider-register-screen')),
        findsOneWidget);
    expect(find.text('Drive with Josi Ride'), findsOneWidget);
    expect(find.text('Start earning on your own schedule'), findsOneWidget);
    expect(find.text('Vehicle Type'), findsOneWidget);
    expect(find.text('Sign Up to Drive'), findsOneWidget);
    _expectVisibleInViewport(
        tester, find.byKey(const ValueKey<String>('rider-sign-up-button')));
    _expectVisibleInViewport(tester, find.text('Continue with Google'));
    _expectVisibleInViewport(tester, find.text('Log in'));

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

    _expectVisibleInViewport(tester, find.text('Get Started'));
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    _expectVisibleInViewport(tester, find.text('Create account'));
    await tester.tap(find.text('Create account'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('customer-register-screen')),
        findsOneWidget);
    expect(find.text('Create Account'), findsOneWidget);
    expect(find.text('Join Josi Ride today'), findsOneWidget);
    expect(find.text('Full Name'), findsOneWidget);
    expect(find.text('Sign Up'), findsOneWidget);
    _expectVisibleInViewport(
        tester, find.byKey(const ValueKey<String>('customer-sign-up-button')));
    _expectVisibleInViewport(tester, find.text('Continue with Google'));
    _expectVisibleInViewport(tester, find.text('Log in'));

    await tester
        .tap(find.byKey(const ValueKey<String>('customer-sign-up-button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 650));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('customer-home-screen')),
        findsOneWidget);
    expect(find.text('Where to?'), findsOneWidget);
  });

  testWidgets('forgot password flow uses redline recovery screens',
      (WidgetTester tester) async {
    await _pumpToRoleSelection(tester);

    _expectVisibleInViewport(tester, find.text('Get Started'));
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    _expectVisibleInViewport(tester, find.text('Forgot Password?'));
    await tester.tap(find.text('Forgot Password?'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('forgot-password-screen')),
        findsOneWidget);
    expect(find.text('Forgot Password'), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('forgot-identity-field')),
        findsOneWidget);
    _expectVisibleInViewport(
        tester, find.byKey(const ValueKey<String>('send-reset-code-button')));

    await tester
        .tap(find.byKey(const ValueKey<String>('send-reset-code-button')));
    await tester.pumpAndSettle();

    expect(find.text('If this account exists, a reset code has been sent.'),
        findsOneWidget);
    _expectVisibleInViewport(tester, find.text('ENTER CODE'));

    await tester.tap(find.text('ENTER CODE'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('verify-reset-code-screen')),
        findsOneWidget);
    expect(find.text('Verify Code'), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('otp-0')), findsOneWidget);
    _expectVisibleInViewport(
        tester, find.byKey(const ValueKey<String>('verify-reset-code-button')));

    await tester
        .tap(find.byKey(const ValueKey<String>('verify-reset-code-button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('reset-password-screen')),
        findsOneWidget);
    expect(find.text('Reset Password'), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('new-password-field')),
        findsOneWidget);
    expect(find.byKey(const ValueKey<String>('confirm-password-field')),
        findsOneWidget);
    _expectVisibleInViewport(
        tester, find.byKey(const ValueKey<String>('reset-password-button')));

    await tester
        .tap(find.byKey(const ValueKey<String>('reset-password-button')));
    await tester.pumpAndSettle();

    expect(find.text('Password reset. You can now log in securely.'),
        findsOneWidget);
    _expectVisibleInViewport(tester, find.text('BACK TO LOGIN'));
  });

  testWidgets('customer destination screen confirms trip',
      (WidgetTester tester) async {
    await _loginAsCustomer(tester);

    _expectVisibleInViewport(
        tester, find.byKey(const ValueKey<String>('home-destination-tile')));
    await tester
        .tap(find.byKey(const ValueKey<String>('home-destination-tile')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('customer-destination-screen')),
        findsOneWidget);
    expect(find.text('Destination'), findsOneWidget);
    expect(find.text('Saved Places'), findsOneWidget);
    expect(find.text('Confirm'), findsOneWidget);
    _expectVisibleInViewport(tester,
        find.byKey(const ValueKey<String>('destination-confirm-button')));
    _expectVisibleInViewport(tester, find.text('Activity'));

    await tester
        .tap(find.byKey(const ValueKey<String>('destination-confirm-button')));
    await tester.pumpAndSettle();

    expect(find.text('Confirm trip'), findsOneWidget);
    expect(find.text('Fare estimate and payment'), findsOneWidget);
  });

  testWidgets('customer fixed bottom navigation opens activity',
      (WidgetTester tester) async {
    await _loginAsCustomer(tester);

    await tester.tap(find.text('Activity').last);
    await tester.pumpAndSettle();

    expect(find.text('Trips'), findsWidgets);
    expect(find.text('History and active requests'), findsOneWidget);
  });

  testWidgets('customer profile opens editable profile form',
      (WidgetTester tester) async {
    await _loginAsCustomer(tester);

    await tester.tap(find.text('Profile').last);
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('customer-profile-screen')),
        findsOneWidget);
    expect(find.text('Your profile'), findsOneWidget);
    expect(find.text('Manage Address'), findsOneWidget);
    expect(find.text('Payment Methods'), findsOneWidget);

    await tester.tap(find.text('Your profile'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('edit-profile-screen')),
        findsOneWidget);
    expect(find.text('Your Profile'), findsOneWidget);
    expect(find.text('Name'), findsOneWidget);
    expect(find.text('Phone Number'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Gender'), findsOneWidget);
    _expectVisibleInViewport(
        tester, find.byKey(const ValueKey<String>('profile-update-button')));
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
  await tester.pump(const Duration(milliseconds: 2200));
  await tester.pumpAndSettle();
}

Future<void> _pumpToRoleSelection(WidgetTester tester) async {
  await _pumpApp(tester);
  await _finishSplash(tester);
}

Future<void> _loginAsCustomer(WidgetTester tester) async {
  await _pumpToRoleSelection(tester);
  _expectVisibleInViewport(tester, find.text('Get Started'));
  await tester.tap(find.text('Get Started'));
  await tester.pumpAndSettle();
  _expectVisibleInViewport(
      tester, find.byKey(const ValueKey<String>('login-button')));
  await tester.tap(find.byKey(const ValueKey<String>('login-button')));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 650));
  await tester.pumpAndSettle();
}

void _expectVisibleInViewport(WidgetTester tester, Finder finder) {
  expect(finder, findsOneWidget);

  final Rect rect = tester.getRect(finder);
  final Size viewportSize =
      tester.view.physicalSize / tester.view.devicePixelRatio;

  expect(rect.left, greaterThanOrEqualTo(0));
  expect(rect.top, greaterThanOrEqualTo(0));
  expect(rect.right, lessThanOrEqualTo(viewportSize.width));
  expect(rect.bottom, lessThanOrEqualTo(viewportSize.height));
}
