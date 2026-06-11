import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:josi_ride/core/constants/app_routes.dart';
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

  testWidgets('customer home map fills screen and where to sheet drags up',
      (WidgetTester tester) async {
    int locationCalls = 0;
    _mockDeviceLocation(
      tester,
      onCall: () {
        locationCalls++;
      },
    );
    await _loginAsCustomer(tester);

    final Finder map = find.byKey(const ValueKey<String>('customer-home-map'));
    final Finder sheet =
        find.byKey(const ValueKey<String>('customer-where-to-sheet'));
    final Size viewportSize =
        tester.view.physicalSize / tester.view.devicePixelRatio;

    expect(map, findsOneWidget);
    final Rect mapRect = tester.getRect(map);
    expect(mapRect.left, 0);
    expect(mapRect.top, 0);
    expect(mapRect.right, viewportSize.width);
    expect(mapRect.height, greaterThan(viewportSize.height * 0.82));

    expect(sheet, findsOneWidget);
    final double collapsedTop = tester.getTopLeft(sheet).dy;

    await tester.drag(sheet, const Offset(0, -300));
    await tester.pumpAndSettle();

    final double expandedTop = tester.getTopLeft(sheet).dy;
    expect(expandedTop, lessThan(collapsedTop - 180));
    _expectVisibleInViewport(tester, find.text('Where to?'));

    await tester.tap(
        find.byKey(const ValueKey<String>('home-current-location-button')));
    await tester.pumpAndSettle();

    expect(locationCalls, 1);
    expect(find.text('Lat 9.07650, Lng 7.39860'), findsOneWidget);
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

    expect(
        find.byKey(const ValueKey<String>('rider-application-status-screen')),
        findsOneWidget);
    expect(find.text('Welcome!, Esther'), findsOneWidget);
    expect(find.text('Required Steps'), findsOneWidget);
    expect(find.text('Profile Picture'), findsOneWidget);
    expect(find.text('Bank Account Details'), findsOneWidget);
    expect(find.text('Government ID'), findsOneWidget);
  });

  testWidgets('rider account completion flow includes bank details',
      (WidgetTester tester) async {
    await _loginAsRider(tester);

    expect(
        find.byKey(const ValueKey<String>('rider-application-status-screen')),
        findsOneWidget);
    await tester.tap(find.text('Profile Picture'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('rider-profile-picture-screen')),
        findsOneWidget);
    expect(find.text('Profile Picture'), findsWidgets);
    expect(find.text('Please Upload a Clear Selfie'), findsOneWidget);
    expect(find.text('Upload Documents'), findsOneWidget);

    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(
        find.byKey(const ValueKey<String>('rider-bank-account-details-screen')),
        findsOneWidget);
    expect(find.text('Bank Account Details'), findsOneWidget);
    expect(find.text('Account Number'), findsOneWidget);
    expect(find.text('Bank Name'), findsOneWidget);
    expect(find.text('Account Name'), findsOneWidget);
    expect(find.text('Attach Bank Account Details'), findsOneWidget);

    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(find.text('Documents'), findsOneWidget);
    expect(find.text('KYC upload checklist'), findsOneWidget);
  });

  testWidgets('rider submission opens dashboard finding jobs',
      (WidgetTester tester) async {
    await _loginAsRider(tester);

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('rider-submission-sheet')),
        findsOneWidget);
    expect(
        find.text('Application Submitted for\nVerification'), findsOneWidget);
    expect(find.text('Got it'), findsOneWidget);

    await tester
        .tap(find.byKey(const ValueKey<String>('rider-submission-got-it')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('rider-location-access-screen')),
        findsOneWidget);
    expect(find.text('Enable Location Access'), findsOneWidget);
    expect(find.text('Allow Location Access'), findsOneWidget);

    await tester
        .tap(find.byKey(const ValueKey<String>('rider-location-allow-button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('rider-home-screen')),
        findsOneWidget);
    expect(find.text('Online'), findsOneWidget);
    expect(find.text('Pre - Booked'), findsOneWidget);
    expect(find.text('Today Earned'), findsOneWidget);
    expect(find.text('Finding Jobs'), findsOneWidget);
  });

  testWidgets('rider dashboard can accept an incoming ride request',
      (WidgetTester tester) async {
    await _loginAsRider(tester);

    final BuildContext context = tester.element(
      find.byKey(const ValueKey<String>('rider-application-status-screen')),
    );
    context.go(AppRoutes.riderHome);
    await tester.pumpAndSettle();

    await tester
        .tap(find.byKey(const ValueKey<String>('rider-finding-jobs-button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('rider-ride-request-sheet')),
        findsOneWidget);
    expect(find.text('Ride Request'), findsOneWidget);
    expect(find.text('Esther Howard'), findsOneWidget);
    expect(find.text('Accept'), findsOneWidget);
    expect(find.text('Decline'), findsOneWidget);

    await tester
        .tap(find.byKey(const ValueKey<String>('rider-ride-request-accept')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('rider-active-trip-screen')),
        findsOneWidget);
    expect(find.text('Customer Location'), findsWidgets);
  });

  testWidgets('rider active trip opens customer location interface',
      (WidgetTester tester) async {
    await _loginAsRider(tester);

    final BuildContext context = tester.element(
      find.byKey(const ValueKey<String>('rider-application-status-screen')),
    );
    context.go(AppRoutes.riderActiveTripPath('TRP-2408'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('rider-active-trip-screen')),
        findsOneWidget);
    expect(find.text('Customer Location'), findsWidgets);
    expect(find.text('Esther Howard'), findsOneWidget);
    expect(find.text('Cash Payment'), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('rider-active-trip-continue')),
        findsOneWidget);

    await tester
        .tap(find.byKey(const ValueKey<String>('rider-active-trip-continue')));
    await tester.pumpAndSettle();

    expect(find.text('Destination'), findsWidgets);
    expect(find.text('Navigate to Destination'), findsOneWidget);

    await tester.tap(find
        .byKey(const ValueKey<String>('rider-navigate-destination-button')));
    await tester.pumpAndSettle();

    expect(find.text('Arrived At Destination'), findsOneWidget);
    expect(find.text('Arrived At Customer Location'), findsOneWidget);
    expect(find.text('Collect Cash'), findsOneWidget);

    await tester
        .tap(find.byKey(const ValueKey<String>('rider-collect-cash-button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('rider-collect-cash-screen')),
        findsOneWidget);
    expect(find.text('Cash Collected'), findsOneWidget);
    expect(find.text('Total Amount'), findsOneWidget);
  });

  testWidgets('rider bookings can cancel and show success',
      (WidgetTester tester) async {
    await _loginAsRider(tester);

    final BuildContext context = tester.element(
      find.byKey(const ValueKey<String>('rider-application-status-screen')),
    );
    context.go(AppRoutes.riderTrips);
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('rider-bookings-screen')),
        findsOneWidget);
    expect(find.text('Bookings'), findsOneWidget);
    expect(find.text('Active'), findsOneWidget);
    expect(find.text('Track Rider'), findsOneWidget);

    await tester
        .tap(find.byKey(const ValueKey<String>('rider-booking-cancel-button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('rider-cancel-ride-screen')),
        findsOneWidget);
    expect(find.text('Please select the reason for cancelations:'),
        findsOneWidget);
    expect(find.text('Rider Not Available'), findsOneWidget);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Cancel Ride'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('rider-cancel-success-sheet')),
        findsOneWidget);
    expect(find.text('Booking Cancelled\nSuccessfully!'), findsOneWidget);

    await tester
        .tap(find.byKey(const ValueKey<String>('rider-cancel-success-got-it')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('rider-bookings-screen')),
        findsOneWidget);
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
    int locationCalls = 0;
    _mockDeviceLocation(
      tester,
      onCall: () {
        locationCalls++;
      },
    );
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
    _expectVisibleInViewport(
        tester, find.byKey(const ValueKey<String>('destination-screen-title')));

    await tester.tap(find
        .byKey(const ValueKey<String>('destination-current-location-field')));
    await tester.pumpAndSettle();

    expect(locationCalls, 1);
    expect(find.text('Lat 9.07650, Lng 7.39860'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey<String>('destination-location-field')),
      'Jabi Lake Mall',
    );
    await tester.pumpAndSettle();
    expect(find.text('Jabi Lake Mall'), findsOneWidget);

    _expectVisibleInViewport(tester,
        find.byKey(const ValueKey<String>('destination-confirm-button')));
    _expectVisibleInViewport(tester, find.text('Activity'));

    await tester
        .tap(find.byKey(const ValueKey<String>('destination-confirm-button')));
    await tester.pumpAndSettle();

    expect(
        find.byKey(const ValueKey<String>('customer-payment-methods-screen')),
        findsOneWidget);
    expect(find.text('Payment Methods'), findsOneWidget);
    expect(find.text('Payment method'), findsOneWidget);
    expect(find.text('Confirm request'), findsOneWidget);

    await tester.tap(find.text('Confirm request'));
    await tester.pumpAndSettle();

    expect(
        find.byKey(const ValueKey<String>('customer-searching-rider-screen')),
        findsOneWidget);
    expect(find.text('Searching Ride...'), findsOneWidget);
    expect(find.text('Book Mini'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey<String>('book-mini-button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('customer-ride-found-screen')),
        findsOneWidget);
    expect(find.text('Ride Founded'), findsOneWidget);
    expect(find.text('Request Ride'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey<String>('request-ride-button')));
    await tester.pumpAndSettle();

    expect(find.text('Active trip'), findsOneWidget);
    expect(find.text('Rider is en route'), findsOneWidget);
  });

  testWidgets('customer ride search can show a not found state',
      (WidgetTester tester) async {
    await _loginAsCustomer(tester);

    await tester
        .tap(find.byKey(const ValueKey<String>('home-destination-tile')));
    await tester.pumpAndSettle();
    await tester
        .tap(find.byKey(const ValueKey<String>('destination-confirm-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirm request'));
    await tester.pumpAndSettle();

    final BuildContext context = tester.element(
      find.byKey(const ValueKey<String>('customer-searching-rider-screen')),
    );
    context.go(AppRoutes.customerRideNotFound);
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('customer-ride-not-found-screen')),
        findsOneWidget);
    expect(find.byKey(const ValueKey<String>('ride-not-found-illustration')),
        findsOneWidget);
    expect(find.text('Ride Not Found'), findsOneWidget);
    expect(find.text('Try Again'), findsOneWidget);
  });

  testWidgets('customer fixed bottom navigation opens activity',
      (WidgetTester tester) async {
    await _loginAsCustomer(tester);

    await tester.tap(find.text('Activity').last);
    await tester.pumpAndSettle();

    expect(find.text('Trips'), findsWidgets);
    expect(find.text('History and active requests'), findsOneWidget);
  });

  testWidgets(
      'customer rides navigation opens destination instead of book trip',
      (WidgetTester tester) async {
    await _loginAsCustomer(tester);

    await tester.tap(find.text('Rides').last);
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('customer-destination-screen')),
        findsOneWidget);
    expect(find.text('Destination'), findsOneWidget);
    expect(find.text('Book a trip'), findsNothing);
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

Future<void> _loginAsRider(WidgetTester tester) async {
  await _pumpToRoleSelection(tester);
  _expectVisibleInViewport(tester, find.text('Drive with Us'));
  await tester.tap(find.text('Drive with Us'));
  await tester.pumpAndSettle();
  _expectVisibleInViewport(
      tester, find.byKey(const ValueKey<String>('login-button')));
  await tester.tap(find.byKey(const ValueKey<String>('login-button')));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 650));
  await tester.pumpAndSettle();
}

void _mockDeviceLocation(
  WidgetTester tester, {
  VoidCallback? onCall,
}) {
  const MethodChannel channel = MethodChannel('josi_ride/device_location');

  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
    channel,
    (MethodCall methodCall) async {
      expect(methodCall.method, 'currentPosition');
      onCall?.call();
      return <String, double>{
        'latitude': 9.0765,
        'longitude': 7.3986,
      };
    },
  );

  addTearDown(() {
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      null,
    );
  });
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
