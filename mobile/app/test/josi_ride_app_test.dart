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
    expect(
        tester.widget<Text>(find.text('Current Location')).style?.fontSize, 14);
    expect(tester.widget<Text>(find.text('Destination')).style?.fontSize, 16);
    expect(tester.widget<Text>(find.text('Office')).style?.fontSize, 16);
    expect(find.text('Last Trip'), findsOneWidget);
    _expectVisibleInViewport(tester, find.text('Home'));
    _expectVisibleInViewport(tester, find.text('Bookings'));

    await tester.tap(find.byKey(const ValueKey<String>('home-last-trip-tile')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('customer-activity-screen')),
        findsOneWidget);
    expect(find.text('Bookings'), findsWidgets);
    expect(find.text('Trip detail'), findsNothing);
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
    expect(find.text('Riding Details'), findsOneWidget);
    expect(find.text('Driving Details'), findsNothing);
    expect(find.text('Submitted Steps'), findsNothing);
    expect(find.text('Government ID'), findsNothing);
    expect(
        tester.widget<Text>(find.text('Welcome!, Esther')).style?.fontSize, 20);
    expect(
        tester.widget<Text>(find.text('Required Steps')).style?.fontSize, 18);
    expect(
        tester.widget<Text>(find.text('Profile Picture')).style?.fontSize, 16);
    final Finder continueButton =
        find.byKey(const ValueKey<String>('rider-bottom-action-continue')).last;
    expect(continueButton, findsOneWidget);
    expect(tester.getSize(continueButton).height, 52);
    final ElevatedButton continueAction =
        tester.widget<ElevatedButton>(continueButton);
    expect(continueAction.style?.textStyle?.resolve(<WidgetState>{})?.fontSize,
        16);
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
    expect(find.textContaining('Upload Bank Document'), findsNothing);
    expect(find.text('Attach Bank Account Details'), findsNothing);
    expect(find.text('Upload Documents'), findsNothing);

    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(
        find.byKey(const ValueKey<String>('rider-application-status-screen')),
        findsOneWidget);
    expect(find.text('Government ID'), findsNothing);
    expect(find.text('Documents'), findsNothing);
  });

  testWidgets('rider riding details uses uploaded form structure',
      (WidgetTester tester) async {
    await _loginAsRider(tester);

    expect(find.text('Riding Details'), findsOneWidget);
    expect(find.text('Driving Details'), findsNothing);

    await tester.tap(find.text('Riding Details'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byKey(const ValueKey<String>('rider-vehicle-setup-screen')),
        findsOneWidget);
    expect(find.text('Complete Your Riding Details'), findsOneWidget);
    expect(
      find.text(
          "Don't worry, only you can see your riding data. No one else will be able to see it."),
      findsOneWidget,
    );
    expect(find.text('Vehicle Type'), findsOneWidget);
    expect(find.text('Vehicle Brand'), findsOneWidget);
    expect(find.text('Vehicle Model'), findsOneWidget);
    expect(find.text('Vehicle Color'), findsOneWidget);
    expect(find.text('Plate Number'), findsOneWidget);
    expect(find.text('Registration Number'), findsOneWidget);
    expect(find.text('City You Ride In'), findsOneWidget);
    expect(find.text('Vehicle setup'), findsNothing);
    expect(find.text('Vehicle documents'), findsNothing);
    expect(find.text('Vehicle registration'), findsNothing);
    expect(find.text('Save vehicle'), findsNothing);

    final Finder continueButton =
        find.byKey(const ValueKey<String>('rider-bottom-action-continue')).last;
    expect(continueButton, findsOneWidget);
    expect(tester.getSize(continueButton).height, 52);

    await tester.tap(continueButton);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(
        find.byKey(const ValueKey<String>('rider-application-status-screen')),
        findsOneWidget);
  });

  testWidgets('rider submission opens dashboard finding jobs',
      (WidgetTester tester) async {
    int locationCalls = 0;
    _mockDeviceLocation(
      tester,
      onCall: () {
        locationCalls++;
      },
    );
    await _loginAsRider(tester);

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('rider-submission-sheet')),
        findsOneWidget);
    expect(
        find.text('Application Submitted for\nVerification'), findsOneWidget);
    expect(find.text('Got it'), findsOneWidget);
    expect(
        tester
            .widget<Text>(find.text('Application Submitted for\nVerification'))
            .style
            ?.fontSize,
        20);
    expect(
        tester
            .widget<Text>(find.text(
                'We will get in touch in 48 Working\nhours. Be ready to for your ride!'))
            .style
            ?.fontSize,
        14);
    final Finder gotItButton =
        find.byKey(const ValueKey<String>('rider-submission-got-it'));
    expect(tester.getSize(gotItButton).height, 52);
    final ElevatedButton gotItAction =
        tester.widget<ElevatedButton>(gotItButton);
    expect(
        gotItAction.style?.textStyle?.resolve(<WidgetState>{})?.fontSize, 16);

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

    expect(locationCalls, 1);
    expect(find.byKey(const ValueKey<String>('rider-home-screen')),
        findsOneWidget);
    expect(find.text('Online'), findsOneWidget);
    expect(find.text('Pre - Booked'), findsOneWidget);
    expect(find.text('Today Earned'), findsOneWidget);
    expect(find.text('Finding Jobs'), findsOneWidget);
    expect(
        tester
            .getSize(find
                .byKey(const ValueKey<String>('rider-metric-prebooked-card')))
            .height,
        82);
    expect(
        tester
            .getSize(find.byKey(
                const ValueKey<String>('rider-metric-today-earned-card')))
            .height,
        82);
    expect(
        tester
            .getSize(
                find.byKey(const ValueKey<String>('rider-finding-jobs-button')))
            .height,
        52);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Bookings'), findsOneWidget);
    expect(find.text('Wallet'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
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
    expect(tester.widget<Text>(find.text('Ride Request')).style?.fontSize, 18);
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
    expect(
      tester
          .widgetList<Text>(find.text('Customer Location'))
          .every((Text widget) => widget.style?.fontSize == 18),
      isTrue,
    );
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
    expect(
        tester
            .widget<Text>(find.text('Arrived At Customer Location'))
            .style
            ?.fontSize,
        18);
    expect(find.text('Collect Cash'), findsOneWidget);

    await tester
        .tap(find.byKey(const ValueKey<String>('rider-collect-cash-button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('rider-collect-cash-screen')),
        findsOneWidget);
    expect(find.text('Cash Collected'), findsOneWidget);
    expect(find.text('Total Amount'), findsOneWidget);
    expect(
      tester
          .getSize(find.byKey(
              const ValueKey<String>('rider-bottom-action-cash-collected')))
          .height,
      52,
    );
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
    expect(find.text('Bookings'), findsWidgets);
    expect(find.text('Active'), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('rider-bookings-tab-active')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('rider-bookings-tab-completed')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('rider-bookings-tab-cancelled')),
      findsOneWidget,
    );
    expect(tester.widget<Text>(find.text('Active')).style?.fontSize, 17);
    expect(find.text('Jenny Wilson'), findsOneWidget);
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

  testWidgets('rider bookings tabs show completed and cancelled variants',
      (WidgetTester tester) async {
    await _loginAsRider(tester);

    final BuildContext context = tester.element(
      find.byKey(const ValueKey<String>('rider-application-status-screen')),
    );
    context.go(AppRoutes.riderTrips);
    await tester.pumpAndSettle();

    await tester.tap(
        find.byKey(const ValueKey<String>('rider-bookings-tab-completed')));
    await tester.pumpAndSettle();

    expect(find.text('Completed'), findsOneWidget);
    expect(tester.widget<Text>(find.text('Completed')).style?.fontSize, 17);
    expect(find.text('Byron Barlow'), findsOneWidget);
    expect(find.text('Robert Fox'), findsOneWidget);
    expect(find.text('Track Rider'), findsNothing);

    await tester.tap(
        find.byKey(const ValueKey<String>('rider-bookings-tab-cancelled')));
    await tester.pumpAndSettle();

    expect(find.text('Cancelled'), findsOneWidget);
    expect(tester.widget<Text>(find.text('Cancelled')).style?.fontSize, 17);
    expect(find.text('Cancelled by You'), findsOneWidget);
    expect(find.text('Cancelled by Rider'), findsOneWidget);
    expect(find.text('Cody Fisher'), findsOneWidget);
    expect(find.text('Ralph Edwards'), findsOneWidget);
    expect(find.text('Track Rider'), findsNothing);
  });

  testWidgets(
      'rider profile update menus save back and logout opens rider login',
      (WidgetTester tester) async {
    await _loginAsRider(tester);

    final BuildContext context = tester.element(
      find.byKey(const ValueKey<String>('rider-application-status-screen')),
    );
    context.go(AppRoutes.riderProfile);
    await tester.pumpAndSettle();

    expect(find.text('Your profile'), findsOneWidget);
    expect(find.text('Profile setup'), findsNothing);
    expect(find.text('Profile picture'), findsNothing);
    expect(find.text('Bank Account Details'), findsOneWidget);
    expect(find.text('Riding Details'), findsOneWidget);

    await tester.tap(find.text('Your profile'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('rider-profile-setup-screen')),
        findsOneWidget);
    expect(find.text('Your profile'), findsOneWidget);
    expect(find.text('Profile Picture'), findsOneWidget);
    expect(find.text('Complete Your Profile'), findsNothing);

    await tester.tap(
        find.byKey(const ValueKey<String>('rider-bottom-action-save-changes')));
    await tester.pumpAndSettle();

    expect(find.text('Your profile'), findsOneWidget);

    await tester.tap(find.text('Bank Account Details'));
    await tester.pumpAndSettle();

    expect(
        find.byKey(const ValueKey<String>('rider-bank-account-details-screen')),
        findsOneWidget);
    expect(find.text('Save changes'), findsOneWidget);

    await tester.tap(
        find.byKey(const ValueKey<String>('rider-bottom-action-save-changes')));
    await tester.pumpAndSettle();

    expect(find.text('Bank Account Details'), findsOneWidget);

    await tester.tap(find.text('Riding Details'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('rider-vehicle-setup-screen')),
        findsOneWidget);
    expect(find.text('Riding Details'), findsOneWidget);
    expect(find.text('Complete Your Riding Details'), findsNothing);
    expect(find.text('Save changes'), findsOneWidget);

    await tester.tap(
        find.byKey(const ValueKey<String>('rider-bottom-action-save-changes')));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Logout'));
    await tester.tap(find.text('Logout'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('login-screen')), findsOneWidget);
    expect(find.text('Rider Login'), findsOneWidget);
    expect(find.text('Customer Login'), findsNothing);
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
    expect(tester.widget<Text>(find.text('Saved Places')).style?.fontSize, 16);

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
    expect(
        tester
            .getSize(find
                .byKey(const ValueKey<String>('destination-confirm-button')))
            .height,
        52);
    _expectCustomerNavLabelColor(tester, 'Home', JosiColors.red);

    await tester
        .tap(find.byKey(const ValueKey<String>('destination-confirm-button')));
    await tester.pumpAndSettle();

    expect(
        find.byKey(const ValueKey<String>('customer-payment-methods-screen')),
        findsOneWidget);
    expect(find.text('Payment Methods'), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('payment-cash-option')),
        findsOneWidget);
    expect(find.byKey(const ValueKey<String>('payment-wallet-option')),
        findsOneWidget);
    expect(find.text('Credit & Debit Card'), findsOneWidget);
    expect(find.text('Add Card'), findsOneWidget);
    expect(find.text('More Payment Options'), findsNothing);
    expect(find.text('Paypal'), findsNothing);
    expect(find.text('Apple Pay'), findsNothing);
    expect(find.text('Google Pay'), findsNothing);
    expect(find.text('Confirm Payment'), findsOneWidget);
    expect(
        tester
            .getSize(
                find.byKey(const ValueKey<String>('confirm-payment-button')))
            .height,
        52);

    await tester
        .tap(find.byKey(const ValueKey<String>('confirm-payment-button')));
    await tester.pumpAndSettle();

    expect(
        find.byKey(const ValueKey<String>('customer-searching-rider-screen')),
        findsOneWidget);
    expect(find.text('Searching Ride...'), findsOneWidget);
    expect(find.text('Book Mini'), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('searching-ride-bike-icon')),
        findsOneWidget);
    expect(find.byKey(const ValueKey<String>('ride-map-bike-marker-0')),
        findsOneWidget);

    await tester.tap(find.byKey(const ValueKey<String>('book-mini-button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('customer-ride-found-screen')),
        findsOneWidget);
    expect(find.byKey(const ValueKey<String>('request-ride-bottom-sheet')),
        findsOneWidget);
    expect(find.byKey(const ValueKey<String>('request-ride-bike-icon')),
        findsOneWidget);
    expect(find.text('Ride Founded'), findsOneWidget);
    expect(find.text('Request Ride'), findsOneWidget);
    expect(
        find.byKey(const ValueKey<String>('request-ride-driver-details-link')),
        findsOneWidget);

    await tester.tap(
        find.byKey(const ValueKey<String>('request-ride-driver-details-link')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('customer-driver-details-screen')),
        findsOneWidget);
    expect(find.text('Driver Details'), findsOneWidget);
    expect(find.text('example@gmail.com'), findsOneWidget);
    expect(find.text('7,500+'), findsOneWidget);
    expect(find.text('10+'), findsOneWidget);
    expect(find.text('4.9+'), findsOneWidget);
    expect(find.text('4,956'), findsOneWidget);
    expect(find.text('Driver Contact'), findsOneWidget);
    expect(find.text('Car Details'), findsOneWidget);
    expect(find.text('Hyundai Verna'), findsOneWidget);
    expect(find.text('GR 678-UVWX'), findsOneWidget);

    await tester
        .tap(find.byKey(const ValueKey<String>('driver-details-tab-review')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('driver-details-review-panel')),
        findsOneWidget);
    expect(find.text('Clean car, fast pickup, and smooth driving.'),
        findsOneWidget);

    final BuildContext driverDetailsContext = tester.element(
      find.byKey(const ValueKey<String>('customer-driver-details-screen')),
    );
    driverDetailsContext.pop();
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('customer-ride-found-screen')),
        findsOneWidget);

    final Finder requestSheet =
        find.byKey(const ValueKey<String>('request-ride-bottom-sheet'));
    expect(tester.getSize(requestSheet).height, lessThan(330));
    final double collapsedTop = tester.getTopLeft(requestSheet).dy;
    await tester.drag(requestSheet, const Offset(0, -160));
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(requestSheet).dy, lessThan(collapsedTop - 80));

    await tester.tap(find.byKey(const ValueKey<String>('request-ride-button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('customer-active-trip-screen')),
        findsOneWidget);
    expect(find.text('Driver Arrived'), findsWidgets);
    expect(find.text('Jenny Wilson'), findsOneWidget);
    expect(find.text('Sedan'), findsOneWidget);
    expect(find.text('OTP - 6546'), findsOneWidget);
    expect(find.text('GR 678-UVWX'), findsOneWidget);
    expect(find.text('Trip preview'), findsOneWidget);
    expect(find.text('Cancel Ride'), findsNothing);

    await tester.tap(find.byKey(const ValueKey<String>('trip-preview-button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('customer-trip-completed-screen')),
        findsOneWidget);
    expect(find.text('Rate Driver'), findsOneWidget);
    expect(find.text('Jenny Wilson'), findsOneWidget);
    expect(find.text('Hyundai Verna'), findsOneWidget);
    expect(find.text('OR 678-UVWX'), findsOneWidget);
    expect(find.text('NGN 3,500 cash payment recorded for this trip.'),
        findsOneWidget);
    expect(find.text('How was your trip with\nJenny Wilson'), findsOneWidget);
    expect(find.text('Your overall rating'), findsOneWidget);
    expect(find.byIcon(Icons.star_rounded), findsNWidgets(5));
    expect(find.byKey(const ValueKey<String>('trip-rating-review-field')),
        findsOneWidget);
    expect(find.text('Submit'), findsOneWidget);

    await tester
        .tap(find.byKey(const ValueKey<String>('submit-trip-rating-button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('customer-home-screen')),
        findsOneWidget);
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
    await tester
        .tap(find.byKey(const ValueKey<String>('confirm-payment-button')));
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

  testWidgets('customer fixed bottom navigation opens bookings',
      (WidgetTester tester) async {
    await _loginAsCustomer(tester);

    await tester.tap(find.text('Bookings').last);
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('customer-activity-screen')),
        findsOneWidget);
    expect(find.text('Bookings'), findsWidgets);
    expect(find.byKey(const ValueKey<String>('activity-tab-active')),
        findsOneWidget);
    expect(find.byKey(const ValueKey<String>('activity-tab-completed')),
        findsOneWidget);
    expect(find.byKey(const ValueKey<String>('activity-tab-cancelled')),
        findsOneWidget);
    expect(find.text('Jenny Wilson'), findsOneWidget);
    expect(find.text('Reschedule'), findsOneWidget);
    expect(find.text('History and active requests'), findsNothing);
    _expectCustomerNavLabelColor(tester, 'Bookings', JosiColors.red);

    final Text bookingsTitle = tester.widget<Text>(find.text('Bookings').first);
    expect(bookingsTitle.style?.fontSize, 20);
    final Text activeTab = tester.widget<Text>(find.text('Active'));
    expect(activeTab.style?.fontSize, 16);

    await tester.tap(find.byKey(
        const ValueKey<String>('activity-driver-details-link-TRP-2409')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('customer-driver-details-screen')),
        findsOneWidget);
    expect(find.text('Driver Details'), findsOneWidget);
    expect(find.text('Jenny Wilson'), findsWidgets);

    final BuildContext activityDriverContext = tester.element(
      find.byKey(const ValueKey<String>('customer-driver-details-screen')),
    );
    activityDriverContext.pop();
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('customer-activity-screen')),
        findsOneWidget);

    await tester
        .tap(find.byKey(const ValueKey<String>('activity-tab-completed')));
    await tester.pumpAndSettle();

    expect(find.text('Byron Barlow'), findsOneWidget);
    expect(find.text('Robert Fox'), findsOneWidget);
    expect(find.text('Date & Time'), findsWidgets);

    await tester
        .tap(find.byKey(const ValueKey<String>('activity-tab-cancelled')));
    await tester.pumpAndSettle();

    expect(find.text('Cancelled by Driver'), findsOneWidget);
    expect(find.text('Cancelled by You'), findsOneWidget);
    expect(find.text('Cody Fisher'), findsOneWidget);
  });

  testWidgets('customer wallet navigation opens wallet',
      (WidgetTester tester) async {
    await _loginAsCustomer(tester);

    await tester.tap(find.text('Wallet').last);
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('customer-wallet-screen')),
        findsOneWidget);
    expect(find.text('Available balance'), findsOneWidget);
    expect(find.text('Transactions'), findsOneWidget);
    expect(find.text('Payment methods'), findsOneWidget);
    expect(find.text('Book a trip'), findsNothing);
    _expectCustomerNavLabelColor(tester, 'Wallet', JosiColors.red);
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
    expect(find.text('Notification'), findsNothing);
    expect(find.text('Pre-Booked Rides'), findsNothing);
    expect(find.text('Emergency Contact'), findsNothing);
    expect(find.text('Bookings'), findsOneWidget);
    expect(find.text('Wallet'), findsOneWidget);
    expect(find.text('Activity'), findsNothing);
    expect(find.text('Rides'), findsNothing);
    _expectCustomerNavLabelColor(tester, 'Profile', JosiColors.red);

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
    expect(
        tester
            .getSize(
                find.byKey(const ValueKey<String>('profile-update-button')))
            .height,
        52);
  });

  testWidgets('customer profile manage address opens add address flow',
      (WidgetTester tester) async {
    await _loginAsCustomer(tester);

    await tester.tap(find.text('Profile').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Manage Address'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('customer-manage-address-screen')),
        findsOneWidget);
    expect(find.text('Manage Address'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Office'), findsOneWidget);
    expect(find.text("Parent's House"), findsOneWidget);
    expect(find.text("Friend's House"), findsOneWidget);
    expect(
        find.text('1901 Thornridge Cir. Shiloh, Hawaii 81063'), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('add-new-address-button')),
        findsOneWidget);
    expect(find.text('Add New Address'), findsOneWidget);
    expect(
        tester
            .getSize(find
                .byKey(const ValueKey<String>('manage-address-apply-button')))
            .height,
        52);

    await tester
        .tap(find.byKey(const ValueKey<String>('add-new-address-button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('customer-add-address-screen')),
        findsOneWidget);
    expect(find.text('Add Address'), findsOneWidget);
    expect(find.text('Save address as *'), findsOneWidget);
    expect(find.text('Complete address'), findsOneWidget);
    expect(find.text('Enter address *'), findsOneWidget);
    expect(find.text('Floor'), findsOneWidget);
    expect(find.text('Landmark'), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('complete-address-field')),
        findsOneWidget);
    expect(find.byKey(const ValueKey<String>('address-floor-field')),
        findsOneWidget);
    expect(find.byKey(const ValueKey<String>('address-landmark-field')),
        findsOneWidget);
    expect(
        tester
            .getSize(find.byKey(const ValueKey<String>('save-address-button')))
            .height,
        52);

    await tester.tap(find.byKey(const ValueKey<String>('save-address-button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('customer-manage-address-screen')),
        findsOneWidget);
  });

  testWidgets('customer profile opens payment methods instead of wallet',
      (WidgetTester tester) async {
    await _loginAsCustomer(tester);

    await tester.tap(find.text('Profile').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Payment Methods'));
    await tester.pumpAndSettle();

    expect(
        find.byKey(const ValueKey<String>('customer-payment-methods-screen')),
        findsOneWidget);
    expect(find.text('Cash'), findsWidgets);
    expect(find.text('Wallet'), findsWidgets);
    expect(find.text('Credit & Debit Card'), findsOneWidget);
    expect(find.text('More Payment Options'), findsNothing);
    expect(find.text('Paypal'), findsNothing);
    expect(find.text('Apple Pay'), findsNothing);
    expect(find.text('Google Pay'), findsNothing);
    expect(find.text('Confirm Payment'), findsOneWidget);
    expect(find.text('Available balance'), findsNothing);
    expect(find.text('Add money'), findsNothing);
    expect(find.text('Transactions'), findsNothing);
  });

  testWidgets('customer settings and help center use uploaded tab layouts',
      (WidgetTester tester) async {
    await _loginAsCustomer(tester);

    await tester.tap(find.text('Profile').last);
    await tester.pumpAndSettle();

    final BuildContext profileContext = tester.element(
      find.byKey(const ValueKey<String>('customer-profile-screen')),
    );
    profileContext.go(AppRoutes.customerSettings);
    await tester.pumpAndSettle();

    expect(
        find.byKey(const ValueKey<String>('settings-screen')), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Notification Settings'), findsOneWidget);
    expect(find.text('Password Manager'), findsOneWidget);
    expect(find.text('Delete Account'), findsOneWidget);
    expect(find.text('Account preferences'), findsNothing);
    expect(find.text('Logout'), findsNothing);

    final Text settingsTitle = tester.widget<Text>(find.text('Settings'));
    expect(settingsTitle.style?.fontSize, 20);
    final Text notificationLabel =
        tester.widget<Text>(find.text('Notification Settings'));
    expect(notificationLabel.style?.fontSize, 20);

    final BuildContext settingsContext = tester.element(
      find.byKey(const ValueKey<String>('settings-screen')),
    );
    settingsContext.go(AppRoutes.customerSupport);
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('help-center-screen')),
        findsOneWidget);
    expect(find.text('Help Center'), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('help-search-field')),
        findsOneWidget);
    expect(find.byKey(const ValueKey<String>('help-tab-faq')), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('help-tab-contact-us')),
        findsOneWidget);
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Services'), findsOneWidget);
    expect(find.text('General'), findsOneWidget);
    expect(find.text('Account'), findsOneWidget);
    expect(find.text('What if I need to cancel a booking?'), findsOneWidget);
    expect(find.text('Is safe to use App?'), findsOneWidget);
    expect(find.text('Contact support'), findsNothing);

    final Text faqTab = tester.widget<Text>(find.text('FAQ'));
    expect(faqTab.style?.fontSize, 17);

    await tester.tap(find.byKey(const ValueKey<String>('help-tab-contact-us')));
    await tester.pumpAndSettle();

    expect(find.text('Customer Service'), findsOneWidget);
    expect(find.text('WhatsApp'), findsOneWidget);
    expect(find.text('(480) 555-0103'), findsOneWidget);
    expect(find.text('Website'), findsOneWidget);
    expect(find.text('Facebook'), findsOneWidget);
    expect(find.text('Twitter'), findsOneWidget);
    expect(find.text('Instagram'), findsOneWidget);
    expect(find.text('What if I need to cancel a booking?'), findsNothing);
  });

  test('theme follows the Josi light redline', () {
    final ThemeData theme = JosiTheme.light;

    expect(theme.useMaterial3, isTrue);
    expect(theme.colorScheme.primary, JosiColors.red);
    expect(JosiColors.red, const Color(0xFFE31837));
    expect(theme.colorScheme.secondary, JosiColors.charcoal);
    expect(theme.scaffoldBackgroundColor, JosiColors.surface);
    expect(theme.textTheme.bodyMedium?.fontFamily, 'Inter');
    expect(theme.textTheme.titleLarge?.fontSize, 18);
    expect(theme.textTheme.bodyMedium?.fontSize, 14);
    expect(theme.textTheme.labelLarge?.fontWeight, FontWeight.w600);
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

void _expectCustomerNavLabelColor(
  WidgetTester tester,
  String label,
  Color color,
) {
  final Text text = tester.widget<Text>(find.text(label).last);
  expect(text.style?.color, color);
}
