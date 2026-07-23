import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:josi_ride/core/constants/app_routes.dart';
import 'package:josi_ride/core/location/location_providers.dart';
import 'package:josi_ride/core/location/location_service.dart';
import 'package:josi_ride/core/location/reverse_geocoding_service.dart';
import 'package:josi_ride/core/mock/josi_mock_data.dart';
import 'package:josi_ride/core/mock/josi_models.dart';
import 'package:josi_ride/core/providers/app_providers.dart';
import 'package:josi_ride/core/repositories/repositories.dart';
import 'package:josi_ride/core/services/api_client.dart';
import 'package:josi_ride/core/services/profile_photo_picker.dart';
import 'package:josi_ride/core/theme/josi_colors.dart';
import 'package:josi_ride/core/theme/josi_theme.dart';
import 'package:josi_ride/core/widgets/josi_google_map.dart';
import 'package:josi_ride/main.dart';

VoidCallback? _mockLocationCall;

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

  testWidgets('restore timeout still advances past splash',
      (WidgetTester tester) async {
    await _pumpApp(
      tester,
      authRepository: const _RestoreTimeoutAuthRepository(),
    );

    expect(find.byKey(const ValueKey<String>('splash-screen')), findsOneWidget);

    await _finishSplash(tester);

    expect(find.byKey(const ValueKey<String>('role-selection-screen')),
        findsOneWidget);
    expect(find.text('Welcome to Josi Ride'), findsOneWidget);
  });

  testWidgets('approved rider session restore opens dashboard directly',
      (WidgetTester tester) async {
    await _pumpApp(
      tester,
      authRepository: const _ApprovedRiderAuthRepository(),
    );

    await _finishSplash(tester);

    expect(find.byKey(const ValueKey<String>('rider-home-screen')),
        findsOneWidget);
    expect(
        find.byKey(const ValueKey<String>('rider-application-status-screen')),
        findsNothing);
    expect(find.byKey(const ValueKey<String>('rider-location-access-screen')),
        findsNothing);
  });

  testWidgets('guest customer dashboard access redirects to customer login',
      (WidgetTester tester) async {
    await _pumpToRoleSelection(tester);

    final BuildContext context = tester.element(
      find.byKey(const ValueKey<String>('role-selection-screen')),
    );
    context.go(AppRoutes.customerHome);
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('login-screen')), findsOneWidget);
    expect(find.text('Customer Login'), findsOneWidget);
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
    expect(find.text('Continue with Google'), findsNothing);
    _expectVisibleInViewport(
        tester, find.byKey(const ValueKey<String>('login-button')));
    _expectVisibleInViewport(tester, find.text('Create account'));

    await tester.enterText(find.byType(TextField).at(0), 'customer@josi.test');
    await tester.enterText(find.byType(TextField).at(1), 'Password123!');
    await tester.tap(find.byKey(const ValueKey<String>('login-button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 650));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('customer-home-screen')),
        findsOneWidget);
    expect(find.text('Where to?'), findsOneWidget);
    expect(find.text('Destination'), findsOneWidget);
    expect(find.text('Courier'), findsOneWidget);
    expect(
        tester.widget<Text>(find.text('Current Location')).style?.fontSize, 14);
    expect(tester.widget<Text>(find.text('Destination')).style?.fontSize, 16);
    expect(find.text('No recent locations yet.'), findsOneWidget);
    _expectVisibleInViewport(tester, find.text('Home'));
    _expectVisibleInViewport(tester, find.text('Activity'));
    _expectVisibleInViewport(tester, find.text('Rider'));

    await tester.tap(find.text('Activity').last);
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('customer-activity-screen')),
        findsOneWidget);
    expect(find.text('Bookings'), findsWidgets);
    expect(find.text('No trips yet.'), findsOneWidget);
  });

  testWidgets(
      'login validates a short password before any loading state or request',
      (WidgetTester tester) async {
    await _pumpApp(tester, authRepository: const _NeverSignInAuthRepository());
    await _finishSplash(tester);

    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    expect(find.text('Customer Login'), findsOneWidget);

    await tester.enterText(find.byType(TextField).at(0), 'customer@josi.test');
    await tester.enterText(find.byType(TextField).at(1), 'short');
    await tester.tap(find.byKey(const ValueKey<String>('login-button')));
    await tester.pump();

    // Feedback is immediate: no spinner, no navigation, still on login.
    expect(find.text('Password must be at least 8 characters.'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.byKey(const ValueKey<String>('login-screen')), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('customer-home-screen')),
        findsNothing);

    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey<String>('login-screen')), findsOneWidget);
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
    expect(find.text('No recent locations yet.'), findsOneWidget);
    expect(find.text('No trips yet.'), findsOneWidget);
    expect(find.text('No saved addresses yet.'), findsOneWidget);

    await tester.tap(
        find.byKey(const ValueKey<String>('home-current-location-button')));
    await tester.pumpAndSettle();

    expect(locationCalls, 1);
    expect(find.text('Wuse 2, Abuja, Federal Capital Territory, Nigeria'),
        findsOneWidget);
    expect(find.textContaining('9.07650'), findsNothing);
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
    expect(find.text('Continue with Google'), findsNothing);
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

    await tester.enterText(find.byType(TextField).at(0), 'Amina Yusuf');
    await tester.enterText(find.byType(TextField).at(1), 'amina@josi.test');
    await tester.enterText(find.byType(TextField).at(2), '+2348023456789');
    await tester.enterText(find.byType(TextField).at(3), 'Password123!');
    await tester.enterText(find.byType(TextField).at(4), 'Password123!');
    await tester
        .tap(find.byKey(const ValueKey<String>('rider-sign-up-button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 650));
    await tester.pumpAndSettle();

    expect(
        find.byKey(const ValueKey<String>('rider-application-status-screen')),
        findsOneWidget);
    expect(find.text('Welcome, Amina'), findsOneWidget);
    expect(find.text('Required Steps'), findsOneWidget);
    expect(find.text('Profile Picture'), findsOneWidget);
    expect(find.text('Bank Account Details'), findsOneWidget);
    expect(find.text('Riding Details'), findsOneWidget);
    expect(find.text('Driving Details'), findsNothing);
    expect(find.text('Submitted Steps'), findsNothing);
    expect(find.text('Government ID'), findsNothing);
    expect(
        tester.widget<Text>(find.text('Welcome, Amina')).style?.fontSize, 20);
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

  testWidgets('approved rider login opens dashboard directly',
      (WidgetTester tester) async {
    await _pumpApp(
      tester,
      authRepository: const _ApprovedRiderLoginAuthRepository(),
    );

    await _finishSplash(tester);

    await tester.tap(find.text('Drive with Us'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(0), 'rider@josi.test');
    await tester.enterText(find.byType(TextField).at(1), 'Password123!');
    await tester.tap(find.byKey(const ValueKey<String>('login-button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 650));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('rider-home-screen')),
        findsOneWidget);
    expect(
        find.byKey(const ValueKey<String>('rider-application-status-screen')),
        findsNothing);
    expect(find.byKey(const ValueKey<String>('rider-location-access-screen')),
        findsNothing);
  });

  testWidgets('submitted onboarding skips welcome screen before approval',
      (WidgetTester tester) async {
    await _pumpApp(
      tester,
      authRepository: const _SubmittedRiderLoginAuthRepository(),
      riderRepository: _FakeRiderRepository(
        onboarding: const RiderOnboarding(
          profile: JosiMockData.riderProfile,
          bankAccount: RiderBankAccount(
            bankName: 'Josi Bank',
            accountName: 'Amina Yusuf',
            accountNumber: '0123456789',
          ),
          ridingDetails: JosiMockData.vehicle,
          profilePictureComplete: true,
          bankAccountComplete: true,
          ridingDetailsComplete: true,
          isSubmitted: true,
        ),
      ),
    );

    await _finishSplash(tester);
    await tester.tap(find.text('Drive with Us'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(0), 'rider@josi.test');
    await tester.enterText(find.byType(TextField).at(1), 'Password123!');
    await tester.tap(find.byKey(const ValueKey<String>('login-button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('rider-home-screen')),
        findsOneWidget);
    expect(
        find.byKey(const ValueKey<String>('rider-application-status-screen')),
        findsNothing);
    expect(find.byKey(const ValueKey<String>('rider-location-access-screen')),
        findsNothing);
  });

  testWidgets('rider account completion flow includes bank details',
      (WidgetTester tester) async {
    final _FakeProfilePhotoPicker profilePhotoPicker = _FakeProfilePhotoPicker(
      cameraPath: 'camera-selfie.jpg',
      galleryPath: 'gallery-selfie.png',
    );
    await _loginAsRider(tester, profilePhotoPicker: profilePhotoPicker);

    expect(
        find.byKey(const ValueKey<String>('rider-application-status-screen')),
        findsOneWidget);
    await tester.tap(find.text('Profile Picture'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('rider-profile-picture-screen')),
        findsOneWidget);
    expect(find.text('Profile Picture'), findsWidgets);
    expect(find.text('Please Upload a Clear Selfie'), findsOneWidget);
    expect(find.text('Add Profile Photo'), findsOneWidget);
    expect(find.text('Upload Documents'), findsNothing);

    await tester
        .tap(find.byKey(const ValueKey<String>('rider-flow-back-button')).last);
    await tester.pumpAndSettle();

    expect(
        find.byKey(const ValueKey<String>('rider-application-status-screen')),
        findsOneWidget);

    await tester.tap(find.text('Profile Picture'));
    await tester.pumpAndSettle();

    await tester
        .tap(find.byKey(const ValueKey<String>('rider-profile-photo-picker')));
    await tester.pumpAndSettle();

    expect(find.text('Take a selfie'), findsOneWidget);
    expect(find.text('Choose from gallery'), findsOneWidget);

    await tester
        .tap(find.byKey(const ValueKey<String>('rider-profile-photo-gallery')));
    await tester.pumpAndSettle();

    expect(profilePhotoPicker.pickedSources,
        <ProfilePhotoSource>[ProfilePhotoSource.gallery]);
    expect(find.text('gallery-selfie.png'), findsOneWidget);

    await tester
        .tap(find.byKey(const ValueKey<String>('rider-profile-photo-picker')));
    await tester.pumpAndSettle();
    await tester
        .tap(find.byKey(const ValueKey<String>('rider-profile-photo-camera')));
    await tester.pumpAndSettle();

    expect(profilePhotoPicker.pickedSources, <ProfilePhotoSource>[
      ProfilePhotoSource.gallery,
      ProfilePhotoSource.camera,
    ]);
    expect(find.text('camera-selfie.jpg'), findsOneWidget);
    await tester.tap(
        find.byKey(const ValueKey<String>('rider-bottom-action-continue')));
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

    await tester.enterText(find.byType(TextField).at(0), '0123456789');
    await tester.enterText(
        find.byType(TextField).at(1), 'Josi Microfinance Bank');
    await tester.enterText(find.byType(TextField).at(2), 'Amina Yusuf');
    await tester.tap(
        find.byKey(const ValueKey<String>('rider-bottom-action-continue')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('rider-vehicle-setup-screen')),
        findsOneWidget);
    expect(find.text('Complete Your Riding Details'), findsOneWidget);
    expect(find.text('Government ID'), findsNothing);
    expect(find.text('Documents'), findsNothing);
  });

  testWidgets(
      'rider onboarding profile setup only asks for address gender city',
      (WidgetTester tester) async {
    await _loginAsRider(tester);

    final BuildContext context = tester.element(
      find.byKey(const ValueKey<String>('rider-application-status-screen')),
    );
    context.go(AppRoutes.riderProfileSetup);
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('rider-profile-setup-screen')),
        findsOneWidget);
    expect(find.text('Complete Your Profile'), findsOneWidget);
    expect(find.text('Address'), findsOneWidget);
    expect(find.text('Gender'), findsOneWidget);
    expect(find.text('City You Drive In'), findsOneWidget);
    expect(find.text('Name'), findsNothing);
    expect(find.text('Email'), findsNothing);
    expect(find.text('Phone Number'), findsNothing);
    expect(find.text('Terms & Condition'), findsNothing);
    expect(find.text('Profile Picture'), findsNothing);
  });

  testWidgets('rider riding details uses uploaded form structure',
      (WidgetTester tester) async {
    final _FakeRiderRepository riderRepository = _FakeRiderRepository(
      onboarding: RiderOnboarding(
        profile: _testRiderProfile(city: 'Ibadan', state: 'Oyo'),
      ),
    );
    await _loginAsRider(tester, riderRepository: riderRepository);

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
    expect(find.text('Other'), findsOneWidget);
    expect(find.text('Vehicle setup'), findsNothing);
    expect(find.text('Vehicle documents'), findsNothing);
    expect(find.text('Vehicle registration'), findsNothing);
    expect(find.text('Save vehicle'), findsNothing);

    await tester
        .tap(find.byKey(const ValueKey<String>('rider-flow-back-button')).last);
    await tester.pumpAndSettle();

    expect(
        find.byKey(const ValueKey<String>('rider-application-status-screen')),
        findsOneWidget);

    await tester.tap(find.text('Riding Details'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('rider-vehicle-setup-screen')),
        findsOneWidget);
    expect(find.text('Complete Your Riding Details'), findsOneWidget);

    final Finder continueButton =
        find.byKey(const ValueKey<String>('rider-bottom-action-continue')).last;
    expect(continueButton, findsOneWidget);
    expect(tester.getSize(continueButton).height, 52);

    await tester.enterText(find.byType(TextField).at(0), 'Toyota');
    await tester.enterText(find.byType(TextField).at(1), 'Corolla');
    await tester.enterText(find.byType(TextField).at(2), 'White');
    await tester.enterText(find.byType(TextField).at(3), 'ABC 482 JK');
    await tester.enterText(find.byType(TextField).at(4), 'REG-2408-JR');
    await tester.tap(continueButton);
    await tester.pump();
    await tester.pumpAndSettle();

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
    await _completeRiderOnboarding(tester);

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

    expect(locationCalls, greaterThanOrEqualTo(1));
    expect(find.byKey(const ValueKey<String>('rider-home-screen')),
        findsOneWidget);
    expect(find.text('Online'), findsOneWidget);
    expect(find.text('Pre - Booked'), findsOneWidget);
    expect(find.text('Today Earned'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('NGN 4200'), findsOneWidget);
    expect(find.text('Finding jobs'), findsNothing);
    expect(
      find.byKey(const ValueKey<String>('rider-search-jobs-fab')),
      findsOneWidget,
    );
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
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Bookings'), findsOneWidget);
    expect(find.text('Wallet'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);

    await tester.tap(
        find.byKey(const ValueKey<String>('rider-dashboard-profile-button')));
    await tester.pumpAndSettle();

    expect(find.text('Rider account'), findsOneWidget);
    expect(find.text('Your profile'), findsOneWidget);
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
        .tap(find.byKey(const ValueKey<String>('rider-search-jobs-fab')));
    await tester.pump();

    expect(find.byKey(const ValueKey<String>('rider-finding-jobs-panel')),
        findsOneWidget);
    expect(find.text('Finding jobs'), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('rider-finding-jobs-progress')),
        findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pump();

    expect(find.byKey(const ValueKey<String>('rider-ride-request-sheet')),
        findsOneWidget);
    expect(find.text('Ride Request'), findsOneWidget);
    expect(tester.widget<Text>(find.text('Ride Request')).style?.fontSize, 18);
    expect(find.text('Esther Howard'), findsOneWidget);
    expect(find.text('Wuse Market'), findsOneWidget);
    expect(find.text('Jabi Lake Mall'), findsOneWidget);
    expect(find.text('30'), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));

    expect(find.text('29'), findsOneWidget);
    expect(find.text('Accept'), findsOneWidget);
    expect(find.text('Decline'), findsOneWidget);

    await tester
        .tap(find.byKey(const ValueKey<String>('rider-ride-request-accept')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('rider-active-trip-screen')),
        findsOneWidget);
    expect(find.text('Customer Location'), findsWidgets);
  });

  testWidgets('rider dashboard declines request and shows not found',
      (WidgetTester tester) async {
    await _loginAsRider(tester);

    final BuildContext context = tester.element(
      find.byKey(const ValueKey<String>('rider-application-status-screen')),
    );
    context.go(AppRoutes.riderHome);
    await tester.pumpAndSettle();

    await tester
        .tap(find.byKey(const ValueKey<String>('rider-search-jobs-fab')));
    await tester.pump(const Duration(seconds: 2));
    await tester.pump();

    expect(find.byKey(const ValueKey<String>('rider-ride-request-sheet')),
        findsOneWidget);

    await tester
        .tap(find.byKey(const ValueKey<String>('rider-ride-request-decline')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));

    expect(find.text('No ride found'), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('rider-ride-request-sheet')),
        findsNothing);
  });

  testWidgets('rider dashboard search shows not found when no actual trips',
      (WidgetTester tester) async {
    await _loginAsRider(
      tester,
      riderRepository: _FakeRiderRepository(trips: const <Trip>[]),
    );

    final BuildContext context = tester.element(
      find.byKey(const ValueKey<String>('rider-application-status-screen')),
    );
    context.go(AppRoutes.riderHome);
    await tester.pumpAndSettle();

    await tester
        .tap(find.byKey(const ValueKey<String>('rider-search-jobs-fab')));
    await tester.pump(const Duration(seconds: 2));
    await tester.pump();

    expect(find.text('No ride found'), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('rider-ride-request-sheet')),
        findsNothing);
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
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

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
    expect(find.text('Esther Howard'), findsOneWidget);
    expect(find.text('CRN : #TRP-2408'), findsOneWidget);
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
    expect(find.text('Musa Danjuma'), findsOneWidget);
    expect(find.text('CRN : #TRP-2409'), findsOneWidget);
    expect(find.text('Track Rider'), findsNothing);

    await tester.tap(
        find.byKey(const ValueKey<String>('rider-bookings-tab-cancelled')));
    await tester.pumpAndSettle();

    expect(find.text('Cancelled'), findsWidgets);
    expect(
        tester.widget<Text>(find.text('Cancelled').first).style?.fontSize, 17);
    expect(find.text('Cancelled'), findsWidgets);
    expect(find.text('Ada Okoro'), findsOneWidget);
    expect(find.text('CRN : #TRP-2410'), findsOneWidget);
    expect(find.text('Track Rider'), findsNothing);
  });

  testWidgets('rider wallet displays backend wallet values',
      (WidgetTester tester) async {
    await _loginAsRider(tester);

    final BuildContext context = tester.element(
      find.byKey(const ValueKey<String>('rider-application-status-screen')),
    );
    context.go(AppRoutes.riderWallet);
    await tester.pumpAndSettle();

    expect(find.text('Wallet'), findsWidgets);
    expect(find.text('Earnings and settlement'), findsOneWidget);
    expect(find.text('NGN 7,700'), findsWidgets);
    expect(find.text('Total earnings NGN 11,000'), findsOneWidget);
    expect(find.text('NGN 900'), findsOneWidget);
    expect(find.text('NGN 4,200'), findsWidgets);
    expect(find.text('Trip earning'), findsWidgets);
    expect(find.text('CRN : #TRP-2409'), findsOneWidget);
    expect(find.text('NGN 42,600'), findsNothing);
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

    await tester.enterText(find.byType(TextField).at(0), '0123456789');
    await tester.enterText(
        find.byType(TextField).at(1), 'Josi Microfinance Bank');
    await tester.enterText(find.byType(TextField).at(2), 'Amina Yusuf');
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

    await tester.enterText(find.byType(TextField).at(0), 'Toyota');
    await tester.enterText(find.byType(TextField).at(1), 'Corolla');
    await tester.enterText(find.byType(TextField).at(2), 'White');
    await tester.enterText(find.byType(TextField).at(3), 'ABC 482 JK');
    await tester.enterText(find.byType(TextField).at(4), 'REG-2408-JR');
    await tester.tap(
        find.byKey(const ValueKey<String>('rider-bottom-action-save-changes')));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Settings'));
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    expect(
        find.byKey(const ValueKey<String>('settings-screen')), findsOneWidget);
    await tester.tap(
        find.byKey(const ValueKey<String>('settings-item-password-manager')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('password-manager-sheet')),
        findsOneWidget);
    await tester.enterText(
        find.byKey(const ValueKey<String>('current-password-update-field')),
        'Password123!');
    await tester.enterText(
        find.byKey(const ValueKey<String>('new-password-update-field')),
        'NewPassword123!');
    await tester.enterText(
        find.byKey(const ValueKey<String>('confirm-password-update-field')),
        'NewPassword123!');
    await tester
        .tap(find.byKey(const ValueKey<String>('password-manager-submit')));
    await tester.pumpAndSettle();

    expect(find.text('Password updated successfully.'), findsOneWidget);
    await tester
        .tap(find.byKey(const ValueKey<String>('settings-back-button')));
    await tester.pumpAndSettle();

    await tester.ensureVisible(
        find.byKey(const ValueKey<String>('rider-logout-button')));
    await tester.tap(find.byKey(const ValueKey<String>('rider-logout-button')));
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
    expect(find.text('Confirm Password'), findsOneWidget);
    expect(find.text('Sign Up'), findsOneWidget);
    _expectVisibleInViewport(
        tester, find.byKey(const ValueKey<String>('customer-sign-up-button')));
    _expectVisibleInViewport(tester, find.text('Log in'));

    await tester.enterText(find.byType(TextField).at(0), 'Abdulrasheed Aliyu');
    await tester.enterText(find.byType(TextField).at(1), 'abdul@example.com');
    await tester.enterText(find.byType(TextField).at(2), '+2348012345678');
    await tester.enterText(find.byType(TextField).at(3), 'Password123!');
    await tester.enterText(find.byType(TextField).at(4), 'Password123!');
    await tester.ensureVisible(
        find.byKey(const ValueKey<String>('customer-sign-up-button')));
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

    await tester.enterText(find.byType(TextField).first, 'abdul@example.com');
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

    for (int index = 0; index < 6; index += 1) {
      await tester.enterText(
        find.byKey(ValueKey<String>('otp-$index')),
        '${index + 1}',
      );
    }
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

    await tester.enterText(find.byType(TextField).at(0), 'Password123!');
    await tester.enterText(find.byType(TextField).at(1), 'Password123!');
    await tester
        .tap(find.byKey(const ValueKey<String>('reset-password-button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('login-screen')), findsOneWidget);
    expect(find.text('Customer Login'), findsOneWidget);
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
    expect(find.byKey(const ValueKey<String>('destination-screen-title')),
        findsOneWidget);
    expect(find.text('Saved Places'), findsOneWidget);
    expect(find.text('Confirm'), findsOneWidget);
    _expectVisibleInViewport(
        tester, find.byKey(const ValueKey<String>('destination-screen-title')));
    expect(tester.widget<Text>(find.text('Saved Places')).style?.fontSize, 16);

    await tester.tap(find
        .byKey(const ValueKey<String>('destination-current-location-field')));
    await tester.pumpAndSettle();

    expect(locationCalls, 2);
    expect(find.text('Wuse 2, Abuja, Federal Capital Territory, Nigeria'),
        findsWidgets);
    expect(find.textContaining('9.07650'), findsNothing);

    await tester
        .tap(find.byKey(const ValueKey<String>('destination-location-field')));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(80, 220));
    await tester.pumpAndSettle();
    expect(find.text('Jabi, Abuja, Federal Capital Territory, Nigeria'),
        findsWidgets);
    expect(find.textContaining('7.46340'), findsNothing);

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
    _expectCustomerNavLabelColor(tester, 'Rider', JosiColors.red);

    await tester
        .tap(find.byKey(const ValueKey<String>('destination-confirm-button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('customer-ride-found-screen')),
        findsOneWidget);
    expect(find.text('Book Mini'), findsNothing);
    expect(find.byKey(const ValueKey<String>('request-ride-bottom-sheet')),
        findsOneWidget);
    expect(find.byKey(const ValueKey<String>('request-ride-bike-icon')),
        findsOneWidget);
    expect(find.text('Ride Found'), findsOneWidget);
    expect(find.text('1 available'), findsOneWidget);
    expect(find.text('Ayo Balogun'), findsOneWidget);
    expect(find.text('Red Bajaj Boxer'), findsOneWidget);
    expect(find.text('JOS-123AB'), findsOneWidget);
    expect(find.text('Request Rider'), findsOneWidget);
    expect(
        find.byKey(const ValueKey<String>('request-ride-driver-details-link')),
        findsOneWidget);

    await tester.tap(
        find.byKey(const ValueKey<String>('request-ride-driver-details-link')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('customer-driver-details-screen')),
        findsOneWidget);
    expect(find.text('Rider Details'), findsOneWidget);
    expect(find.text('Ayo Balogun'), findsWidgets);
    expect(find.text('+2348000000004'), findsWidgets);
    expect(find.textContaining('Wuse 2'), findsOneWidget);
    expect(find.text('Rider assigned'), findsWidgets);
    expect(find.text('Rider Contact'), findsOneWidget);
    expect(find.text('Bike Details'), findsOneWidget);
    expect(find.text('Red Bajaj Boxer'), findsWidgets);
    expect(find.text('JOS-123AB'), findsOneWidget);
    expect(find.text('example@gmail.com'), findsNothing);
    expect(find.text('Hyundai Verna'), findsNothing);

    await tester
        .tap(find.byKey(const ValueKey<String>('driver-details-tab-review')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('driver-details-review-panel')),
        findsOneWidget);
    expect(find.text('No rider reviews yet.'), findsOneWidget);

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
    expect(find.text('Rider Arrived'), findsWidgets);
    expect(find.text('Ayo Balogun'), findsOneWidget);
    expect(find.textContaining('Red Bajaj Boxer'), findsOneWidget);
    expect(find.text('OTP - 6546'), findsNothing);
    expect(find.text('Bike Number'), findsOneWidget);
    expect(find.text('JOS-123AB'), findsWidgets);
    expect(find.text('Rate Rider'), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('active-trip-call-button')),
        findsOneWidget);
    expect(find.text('Cancel Ride'), findsNothing);

    await tester.tap(find.byKey(const ValueKey<String>('trip-preview-button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('customer-trip-completed-screen')),
        findsOneWidget);
    expect(find.text('Rate Rider'), findsOneWidget);
    expect(find.text('Ayo Balogun'), findsOneWidget);
    expect(find.text('Red Bajaj Boxer'), findsOneWidget);
    expect(find.text('JOS-123AB'), findsOneWidget);
    expect(find.text('NGN 3500 is due for this trip.'), findsOneWidget);
    expect(find.text('How was your trip with\nAyo Balogun'), findsOneWidget);
    expect(find.text('Your overall rating'), findsOneWidget);
    expect(find.byIcon(Icons.star_rounded), findsNWidgets(5));
    expect(find.byKey(const ValueKey<String>('trip-rating-review-field')),
        findsOneWidget);
    expect(find.text('Submit'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey<String>('trip-rating-review-field')),
      'Fast pickup and careful riding.',
    );
    await tester
        .tap(find.byKey(const ValueKey<String>('submit-trip-rating-button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('customer-home-screen')),
        findsOneWidget);

    await tester.tap(find.text('Activity').last);
    await tester.pumpAndSettle();
    await tester
        .tap(find.byKey(const ValueKey<String>('activity-tab-completed')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('booking-activity-list')),
        findsOneWidget);
    expect(find.text('Ayo Balogun'), findsOneWidget);
    expect(find.text('Red Bajaj Boxer'), findsOneWidget);
    expect(find.text('JOS-123AB'), findsOneWidget);
    expect(find.textContaining('Jun 18, 2026'), findsOneWidget);
    expect(find.text('Reschedule'), findsNothing);
    expect(
        find.byKey(const ValueKey<String>('booking-sms-button')), findsNothing);

    final Finder pendingCard =
        find.byKey(const ValueKey<String>('booking-activity-card-1'));
    await tester.tapAt(tester.getTopLeft(pendingCard) + const Offset(28, 28));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('customer-driver-details-screen')),
        findsOneWidget);
    expect(find.text('Ayo Balogun'), findsWidgets);
    expect(find.text('Red Bajaj Boxer'), findsWidgets);
    expect(find.text('JOS-123AB'), findsOneWidget);
    await tester
        .tap(find.byKey(const ValueKey<String>('driver-details-tab-review')));
    await tester.pumpAndSettle();
    expect(find.text('Fast pickup and careful riding.'), findsOneWidget);
  });

  testWidgets('customer ride search can show a not found state',
      (WidgetTester tester) async {
    await _loginAsCustomer(tester);

    final BuildContext homeContext = tester.element(
      find.byKey(const ValueKey<String>('customer-home-screen')),
    );
    homeContext.go(AppRoutes.customerRideNotFound);
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

    expect(find.byKey(const ValueKey<String>('customer-activity-screen')),
        findsOneWidget);
    expect(find.text('Bookings'), findsWidgets);
    expect(find.byKey(const ValueKey<String>('activity-tab-active')),
        findsOneWidget);
    expect(find.byKey(const ValueKey<String>('activity-tab-completed')),
        findsOneWidget);
    expect(find.byKey(const ValueKey<String>('activity-tab-cancelled')),
        findsOneWidget);
    expect(find.text('No trips yet.'), findsOneWidget);
    expect(find.text('Jenny Wilson'), findsNothing);
    expect(find.text('Reschedule'), findsNothing);
    expect(find.text('History and active requests'), findsNothing);
    _expectCustomerNavLabelColor(tester, 'Activity', JosiColors.red);

    final Text bookingsTitle = tester.widget<Text>(find.text('Bookings').first);
    expect(bookingsTitle.style?.fontSize, 20);
    final Text activeTab = tester.widget<Text>(find.text('Active'));
    expect(activeTab.style?.fontSize, 16);

    await tester
        .tap(find.byKey(const ValueKey<String>('activity-tab-completed')));
    await tester.pumpAndSettle();

    expect(find.text('No trips yet.'), findsOneWidget);
    expect(find.text('Byron Barlow'), findsNothing);
    expect(find.text('Robert Fox'), findsNothing);

    await tester
        .tap(find.byKey(const ValueKey<String>('activity-tab-cancelled')));
    await tester.pumpAndSettle();

    expect(find.text('No trips yet.'), findsOneWidget);
    expect(find.text('Cancelled by Rider'), findsNothing);
    expect(find.text('Cody Fisher'), findsNothing);
  });

  testWidgets('customer booking card searches pending ride and cancels ride',
      (WidgetTester tester) async {
    await _loginAsCustomer(tester);

    await tester.tap(find.text('Rider').last);
    await tester.pumpAndSettle();
    await tester
        .tap(find.byKey(const ValueKey<String>('destination-confirm-button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('customer-ride-found-screen')),
        findsOneWidget);

    final BuildContext rideFoundContext = tester.element(
      find.byKey(const ValueKey<String>('customer-ride-found-screen')),
    );
    rideFoundContext.go(AppRoutes.customerTrips);
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('booking-activity-card-1')),
        findsOneWidget);
    expect(find.text('Searching for rider'), findsOneWidget);
    expect(find.text('Cancel Ride'), findsOneWidget);

    final Finder pendingCard =
        find.byKey(const ValueKey<String>('booking-activity-card-1'));
    await tester.tapAt(tester.getTopLeft(pendingCard) + const Offset(28, 28));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Searching Ride...', skipOffstage: false), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('customer-ride-found-screen')),
        findsOneWidget);

    final BuildContext searchContext = tester.element(
      find.byKey(const ValueKey<String>('customer-ride-found-screen')),
    );
    searchContext.go(AppRoutes.customerTrips);
    await tester.pumpAndSettle();

    await tester
        .tap(find.byKey(const ValueKey<String>('booking-cancel-button-1')));
    await tester.pump();
    expect(find.text('Cancelling...'), findsOneWidget);
    await tester.pumpAndSettle();

    expect(find.text('Ride cancelled successfully.'), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('activity-tab-cancelled')),
        findsOneWidget);
    expect(find.text('Cancelled'), findsWidgets);
    expect(find.byKey(const ValueKey<String>('booking-activity-card-1')),
        findsOneWidget);
    expect(find.text('Cancel Ride'), findsNothing);
  });

  testWidgets('customer rider navigation opens destination screen',
      (WidgetTester tester) async {
    await _loginAsCustomer(tester);

    await tester.tap(find.text('Rider').last);
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('customer-destination-screen')),
        findsOneWidget);
    expect(find.byKey(const ValueKey<String>('destination-screen-title')),
        findsOneWidget);
    expect(find.byKey(const ValueKey<String>('destination-route-summary-card')),
        findsOneWidget);
    expect(find.text('Estimated distance'), findsOneWidget);
    expect(find.text('Estimated duration'), findsOneWidget);
    expect(find.text('Saved Places'), findsOneWidget);
    expect(find.text('Confirm'), findsOneWidget);
    _expectCustomerNavLabelColor(tester, 'Rider', JosiColors.red);

    await tester
        .tap(find.byKey(const ValueKey<String>('destination-confirm-button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('customer-ride-found-screen')),
        findsOneWidget);
    expect(find.text('Ride Found'), findsOneWidget);
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
    expect(find.text('Activity'), findsOneWidget);
    expect(find.text('Rider'), findsOneWidget);
    expect(find.text('Bookings'), findsNothing);
    expect(find.text('Wallet'), findsNothing);
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

    await tester.enterText(find.byType(TextField).at(0), 'Ada Johnson');
    await tester.enterText(find.byType(TextField).at(1), '+2348099990000');
    await tester.enterText(find.byType(TextField).at(2), 'ada@example.com');
    await tester
        .tap(find.byKey(const ValueKey<String>('profile-update-button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('customer-profile-screen')),
        findsOneWidget);
    expect(find.text('Ada Johnson'), findsOneWidget);
    expect(find.text('Profile updated successfully.'), findsOneWidget);
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
    expect(find.text('No saved addresses yet.'), findsOneWidget);
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

    await tester.enterText(
      find.descendant(
        of: find.byKey(const ValueKey<String>('complete-address-field')),
        matching: find.byType(TextField),
      ),
      '12 Jabi Lake Road, Abuja',
    );
    await tester.tap(find.byKey(const ValueKey<String>('save-address-button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('customer-manage-address-screen')),
        findsOneWidget);
    expect(find.text('12 Jabi Lake Road, Abuja'), findsOneWidget);
    expect(find.text('Address saved successfully.'), findsOneWidget);
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

    final Text helpTitle = tester.widget<Text>(find.text('Help Center'));
    expect(helpTitle.style?.fontSize, 18);
    final Text faqTab = tester.widget<Text>(find.text('FAQ'));
    expect(faqTab.style?.fontSize, 15);
    final Text faqCategory = tester.widget<Text>(find.text('All'));
    expect(faqCategory.style?.fontSize, 14);
    final Text faqQuestion =
        tester.widget<Text>(find.text('What if I need to cancel a booking?'));
    expect(faqQuestion.style?.fontSize, 14);

    await tester.tap(find.byKey(const ValueKey<String>('help-tab-contact-us')));
    await tester.pumpAndSettle();

    expect(find.text('Customer Service'), findsOneWidget);
    expect(find.text('WhatsApp'), findsOneWidget);
    expect(find.text('+234 9162599418'), findsOneWidget);
    expect(find.text('(480) 555-0103'), findsNothing);
    expect(find.text('Website'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Facebook'), findsOneWidget);
    expect(find.text('Twitter'), findsOneWidget);
    expect(find.text('Instagram'), findsOneWidget);
    expect(find.text('What if I need to cancel a booking?'), findsNothing);

    final Text contactLabel = tester.widget<Text>(find.text('WhatsApp'));
    expect(contactLabel.style?.fontSize, 16);

    await tester
        .tap(find.byKey(const ValueKey<String>('help-contact-website')));
    await tester.pumpAndSettle();
    expect(find.text('jositransport.com'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey<String>('help-contact-email')));
    await tester.pumpAndSettle();
    expect(find.text('support@jositransport.com'), findsOneWidget);

    for (final String social in <String>['facebook', 'twitter', 'instagram']) {
      final Finder socialRow =
          find.byKey(ValueKey<String>('help-contact-$social'));
      await tester.ensureVisible(socialRow);
      await tester.tap(socialRow);
      await tester.pumpAndSettle();
    }
    expect(find.text('Josi Ride'), findsNWidgets(3));
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

Future<void> _pumpApp(
  WidgetTester tester, {
  AuthRepository authRepository = const _FakeAuthRepository(),
  RiderRepository? riderRepository,
  WalletRepository? walletRepository,
  ProfilePhotoPicker? profilePhotoPicker,
}) async {
  JosiGoogleMap.debugUseStaticMap = true;
  tester.view.physicalSize = const Size(430, 932);
  tester.view.devicePixelRatio = 1;
  addTearDown(() {
    JosiGoogleMap.debugUseStaticMap = false;
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(authRepository),
        customerRepositoryProvider.overrideWithValue(_FakeCustomerRepository()),
        riderRepositoryProvider
            .overrideWithValue(riderRepository ?? _FakeRiderRepository()),
        walletRepositoryProvider.overrideWithValue(
            walletRepository ?? const _FakeWalletRepository()),
        profilePhotoPickerProvider.overrideWithValue(
          profilePhotoPicker ?? _FakeProfilePhotoPicker(),
        ),
        locationServiceProvider.overrideWithValue(
          _FakeLocationService(onCall: () => _mockLocationCall?.call()),
        ),
        reverseGeocodingServiceProvider.overrideWithValue(
          const _FakeReverseGeocodingService(),
        ),
      ],
      child: const JosiApp(),
    ),
  );
}

class _FakeAuthRepository extends AuthRepository {
  const _FakeAuthRepository();

  @override
  Future<JosiUser?> restoreSession() async => null;

  @override
  Future<AuthResult> signIn({
    required String identity,
    required String password,
    String role = 'customer',
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
    return AuthResult.authenticated(
      role == 'rider' || role == 'courier'
          ? JosiMockData.rider
          : JosiMockData.customer,
      message: 'Login successful',
    );
  }

  @override
  Future<AuthResult> registerCustomer({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
    return const AuthResult.authenticated(
      JosiMockData.customer,
      message: 'Customer registration successful',
    );
  }

  @override
  Future<AuthResult> registerRider({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
    String role = 'rider',
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
    return const AuthResult.authenticated(
      JosiMockData.rider,
      message: 'Rider registration successful',
    );
  }

  @override
  Future<String> requestPasswordReset(String emailOrPhone) async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
    return 'If this account exists, a reset code has been sent.';
  }

  @override
  Future<void> verifyResetCode({
    required String emailOrPhone,
    required String code,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
  }

  @override
  Future<String> resetPassword({
    required String emailOrPhone,
    required String code,
    required String password,
    required String passwordConfirmation,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
    return 'Password reset. You can now log in securely.';
  }

  @override
  Future<String> changePassword({
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
    return 'Password updated successfully.';
  }

  @override
  Future<void> signOut() async {}
}

class _NeverSignInAuthRepository extends _FakeAuthRepository {
  const _NeverSignInAuthRepository();

  @override
  Future<AuthResult> signIn({
    required String identity,
    required String password,
    String role = 'customer',
  }) async {
    throw StateError(
      'signIn must not be called when client-side validation fails.',
    );
  }
}

class _RestoreTimeoutAuthRepository extends _FakeAuthRepository {
  const _RestoreTimeoutAuthRepository();

  @override
  Future<JosiUser?> restoreSession() async {
    throw const ApiException('The request timed out. Please try again.');
  }
}

class _ApprovedRiderAuthRepository extends _FakeAuthRepository {
  const _ApprovedRiderAuthRepository();

  static const JosiUser _approvedRider = JosiUser(
    id: 'drv_approved',
    name: 'Amina Yusuf',
    email: 'amina@josi.ng',
    phone: '+234 802 345 6789',
    role: AppRole.rider,
    applicationStatus: RiderApplicationStatus.approved,
  );

  @override
  Future<JosiUser?> restoreSession() async => _approvedRider;

  @override
  Future<AuthResult> signIn({
    required String identity,
    required String password,
    String role = 'customer',
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
    return AuthResult.authenticated(
      role == 'rider' || role == 'courier'
          ? _approvedRider
          : JosiMockData.customer,
      message: 'Login successful',
    );
  }
}

class _ApprovedRiderLoginAuthRepository extends _ApprovedRiderAuthRepository {
  const _ApprovedRiderLoginAuthRepository();

  @override
  Future<JosiUser?> restoreSession() async => null;
}

class _SubmittedRiderLoginAuthRepository extends _FakeAuthRepository {
  const _SubmittedRiderLoginAuthRepository();

  static const JosiUser _submittedRider = JosiUser(
    id: 'drv_submitted',
    name: 'Amina Yusuf',
    email: 'amina@josi.ng',
    phone: '+234 802 345 6789',
    role: AppRole.rider,
    applicationStatus: RiderApplicationStatus.underReview,
  );

  @override
  Future<JosiUser?> restoreSession() async => null;

  @override
  Future<AuthResult> signIn({
    required String identity,
    required String password,
    String role = 'customer',
  }) async {
    return const AuthResult.authenticated(
      _submittedRider,
      message: 'Login successful',
    );
  }
}

class _FakeWalletRepository extends WalletRepository {
  const _FakeWalletRepository();

  @override
  Future<WalletSummary> summary(AppRole role) async {
    if (role != AppRole.rider) {
      return JosiMockData.customerWallet;
    }

    return const WalletSummary(
      balance: 'NGN 7,700',
      totalEarnings: 'NGN 11,000',
      availableBalance: 'NGN 7,700',
      pendingRemittance: 'NGN 900',
      todayEarnings: 'NGN 4,200',
    );
  }

  @override
  Future<List<WalletTransaction>> transactions(AppRole role) async {
    if (role != AppRole.rider) {
      return JosiMockData.transactions;
    }

    return const <WalletTransaction>[
      WalletTransaction(
        title: 'Trip earning',
        subtitle: 'CRN : #TRP-2409',
        amount: 'NGN 4,200',
        isCredit: true,
        status: 'Completed',
      ),
      WalletTransaction(
        title: 'Trip earning',
        subtitle: 'CRN : #TRP-2411',
        amount: 'NGN 6,800',
        isCredit: true,
        status: 'Completed',
      ),
    ];
  }
}

class _FakeProfilePhotoPicker implements ProfilePhotoPicker {
  _FakeProfilePhotoPicker({
    this.cameraPath = 'camera-selfie.jpg',
    this.galleryPath = 'gallery-selfie.png',
  });

  final String? cameraPath;
  final String? galleryPath;
  final List<ProfilePhotoSource> pickedSources = <ProfilePhotoSource>[];

  @override
  Future<String?> pick(ProfilePhotoSource source) async {
    pickedSources.add(source);
    return source == ProfilePhotoSource.camera ? cameraPath : galleryPath;
  }
}

class _FakeCustomerRepository extends CustomerRepository {
  _FakeCustomerRepository();

  JosiUser _profile = JosiMockData.customer;
  final List<CustomerSavedAddress> _addresses = <CustomerSavedAddress>[];
  final List<Trip> _trips = <Trip>[];
  bool _arrivalReturned = false;

  @override
  Future<JosiUser> profile() async => _profile;

  @override
  Future<JosiUser> updateProfile({
    required String name,
    required String phone,
    required String email,
    String? gender,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 20));
    final List<String> nameParts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((String value) => value.isNotEmpty)
        .toList();
    _profile = JosiUser(
      id: _profile.id,
      name: name.trim(),
      email: email.trim(),
      phone: phone.trim(),
      role: _profile.role,
      city: _profile.city,
      firstName: nameParts.isEmpty ? null : nameParts.first,
      lastName: nameParts.length > 1 ? nameParts.skip(1).join(' ') : null,
      gender: gender == 'Select' ? null : gender,
    );
    return _profile;
  }

  @override
  Future<List<String>> recentLocations() async => const <String>[];

  @override
  Future<List<CustomerSavedAddress>> savedAddresses() async =>
      List<CustomerSavedAddress>.unmodifiable(_addresses);

  @override
  Future<CustomerSavedAddress> createSavedAddress({
    required String label,
    required String address,
    String? floor,
    String? landmark,
    double? latitude,
    double? longitude,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 20));
    final CustomerSavedAddress savedAddress = CustomerSavedAddress(
      id: '${_addresses.length + 1}',
      title: label,
      address: address.trim(),
      floor: floor?.trim(),
      landmark: landmark?.trim(),
    );
    _addresses.add(savedAddress);
    return savedAddress;
  }

  @override
  Future<List<Trip>> trips() async => List<Trip>.unmodifiable(_trips);

  @override
  Future<Trip> requestTrip({
    required String pickupAddress,
    required double pickupLatitude,
    required double pickupLongitude,
    required String destinationAddress,
    required double destinationLatitude,
    required double destinationLongitude,
    String paymentMethod = 'cash',
    String serviceType = 'ride',
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 20));
    final Trip trip = Trip(
      id: '${_trips.length + 1}',
      pickup: pickupAddress.trim(),
      destination: destinationAddress.trim(),
      fare: 'NGN 3500',
      status: TripStatus.searching,
      paymentMethod: PaymentMethod.cash,
      dateLabel: '2026-06-18T08:30:00Z',
      riderName: '',
      customerName: _profile.displayName,
      distance: '',
      duration: '',
    );
    _trips.add(trip);
    return trip;
  }

  @override
  Future<Trip> trip(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 20));
    final Trip trip = _trips.firstWhere(
      (Trip value) => value.id == id,
      orElse: () =>
          throw const ApiException('Trip was not returned by the API.'),
    );
    if (trip.riderName.isNotEmpty && !_arrivalReturned) {
      _arrivalReturned = true;
      final Trip arrived = _copyTrip(trip, isArrivedAtPickup: true);
      _replaceTrip(arrived);
      return arrived;
    }
    return trip;
  }

  @override
  Future<List<AvailableRider>> availableRiders(String tripId) async {
    await Future<void>.delayed(const Duration(milliseconds: 20));
    if (!_trips.any((Trip trip) => trip.id == tripId)) {
      return const <AvailableRider>[];
    }
    return const <AvailableRider>[
      AvailableRider(
        id: '44',
        name: 'Ayo Balogun',
        phone: '+2348000000004',
        vehicleLabel: 'Red Bajaj Boxer',
        plateNumber: 'JOS-123AB',
        city: 'Abuja',
        state: 'FCT',
      ),
    ];
  }

  @override
  Future<Trip> requestRider({
    required String tripId,
    required String riderProfileId,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 20));
    final Trip trip = _trips.firstWhere(
      (Trip value) => value.id == tripId,
      orElse: () =>
          throw const ApiException('Trip was not returned by the API.'),
    );
    final Trip requested = _copyTrip(
      trip,
      riderId: riderProfileId,
      riderName: 'Ayo Balogun',
      riderPhone: '+2348000000004',
      vehicleLabel: 'Red Bajaj Boxer',
      plateNumber: 'JOS-123AB',
      status: TripStatus.searching,
      isArrivedAtPickup: false,
    );
    _arrivalReturned = false;
    _replaceTrip(requested);
    return requested;
  }

  @override
  Future<String> submitRiderReview({
    required String tripId,
    required int rating,
    String? review,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 20));
    final Trip trip = _trips.firstWhere(
      (Trip value) => value.id == tripId,
      orElse: () =>
          throw const ApiException('Trip was not returned by the API.'),
    );
    _replaceTrip(_copyTrip(
      trip,
      status: TripStatus.completed,
      reviewRating: rating,
      reviewText: review,
    ));
    return 'Rider review submitted successfully';
  }

  @override
  Future<Trip> cancelTrip({
    required String tripId,
    String reason = 'Cancelled by customer',
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 20));
    final Trip trip = _trips.firstWhere(
      (Trip value) => value.id == tripId,
      orElse: () =>
          throw const ApiException('Trip was not returned by the API.'),
    );
    final Trip cancelled = _copyTrip(
      trip,
      status: TripStatus.cancelled,
    );
    _replaceTrip(cancelled);
    return cancelled;
  }

  void _replaceTrip(Trip updated) {
    final int index = _trips.indexWhere((Trip trip) => trip.id == updated.id);
    if (index == -1) {
      _trips.add(updated);
      return;
    }
    _trips[index] = updated;
  }
}

Trip _copyTrip(
  Trip trip, {
  String? id,
  String? pickup,
  String? destination,
  String? fare,
  TripStatus? status,
  PaymentMethod? paymentMethod,
  String? dateLabel,
  String? riderName,
  String? customerName,
  String? distance,
  String? duration,
  String? riderId,
  String? riderPhone,
  String? vehicleLabel,
  String? plateNumber,
  bool? isArrivedAtPickup,
  double? amount,
  DateTime? requestedAt,
  DateTime? completedAt,
  DateTime? cancelledAt,
  int? reviewRating,
  String? reviewText,
}) {
  return Trip(
    id: id ?? trip.id,
    pickup: pickup ?? trip.pickup,
    destination: destination ?? trip.destination,
    fare: fare ?? trip.fare,
    status: status ?? trip.status,
    paymentMethod: paymentMethod ?? trip.paymentMethod,
    dateLabel: dateLabel ?? trip.dateLabel,
    riderName: riderName ?? trip.riderName,
    customerName: customerName ?? trip.customerName,
    distance: distance ?? trip.distance,
    duration: duration ?? trip.duration,
    amount: amount ?? trip.amount,
    requestedAt: requestedAt ?? trip.requestedAt,
    completedAt: completedAt ?? trip.completedAt,
    cancelledAt: cancelledAt ?? trip.cancelledAt,
    riderId: riderId ?? trip.riderId,
    riderPhone: riderPhone ?? trip.riderPhone,
    vehicleLabel: vehicleLabel ?? trip.vehicleLabel,
    plateNumber: plateNumber ?? trip.plateNumber,
    isArrivedAtPickup: isArrivedAtPickup ?? trip.isArrivedAtPickup,
    reviewRating: reviewRating ?? trip.reviewRating,
    reviewText: reviewText ?? trip.reviewText,
  );
}

RiderProfile _testRiderProfile({
  String? city,
  String? state,
}) {
  const RiderProfile base = JosiMockData.riderProfile;
  return RiderProfile(
    fullName: base.fullName,
    phone: base.phone,
    gender: base.gender,
    dateOfBirth: base.dateOfBirth,
    address: base.address,
    city: city ?? base.city,
    state: state ?? base.state,
    rating: base.rating,
    completedTrips: base.completedTrips,
    profilePhoto: base.profilePhoto,
    licenseNumber: base.licenseNumber,
    applicationStatus: base.applicationStatus,
    bankName: base.bankName,
    bankAccountName: base.bankAccountName,
    bankAccountNumber: base.bankAccountNumber,
  );
}

class _FakeRiderRepository extends RiderRepository {
  _FakeRiderRepository({
    RiderOnboarding? onboarding,
    List<Trip>? trips,
  }) : _onboarding = onboarding ??
            const RiderOnboarding(
              profile: JosiMockData.riderProfile,
            ) {
    _trips.addAll(trips ?? _defaultRiderTrips);
  }

  RiderOnboarding _onboarding;
  final List<Trip> _trips = <Trip>[];

  static final List<Trip> _defaultRiderTrips = <Trip>[
    Trip(
      id: 'TRP-2408',
      pickup: 'Wuse Market',
      destination: 'Jabi Lake Mall',
      fare: 'NGN 3500',
      status: TripStatus.searching,
      paymentMethod: PaymentMethod.cash,
      dateLabel: 'Now',
      riderName: 'Amina Yusuf',
      customerName: 'Esther Howard',
      distance: '7.6 km',
      duration: '18 mins',
      amount: 3500,
      requestedAt: DateTime.now(),
      riderId: '44',
      riderPhone: '+2348000000004',
      vehicleLabel: 'Red Bajaj Boxer',
      plateNumber: 'JOS-123AB',
    ),
    Trip(
      id: 'TRP-2409',
      pickup: 'Garki Area 11',
      destination: 'Central Business District',
      fare: 'NGN 4200',
      status: TripStatus.completed,
      paymentMethod: PaymentMethod.cash,
      dateLabel: 'Jun 26, 2026, 10:30 AM',
      riderName: 'Amina Yusuf',
      customerName: 'Musa Danjuma',
      distance: '5.2 km',
      duration: '14 mins',
      amount: 4200,
      requestedAt: DateTime.now(),
      completedAt: DateTime.now(),
      riderId: '44',
      riderPhone: '+2348000000004',
      vehicleLabel: 'Red Bajaj Boxer',
      plateNumber: 'JOS-123AB',
    ),
    Trip(
      id: 'TRP-2410',
      pickup: 'Utako Market',
      destination: 'Wuye District',
      fare: 'NGN 2100',
      status: TripStatus.cancelled,
      paymentMethod: PaymentMethod.cash,
      dateLabel: 'Jun 25, 2026, 03:20 PM',
      riderName: 'Amina Yusuf',
      customerName: 'Ada Okoro',
      distance: '3.1 km',
      duration: '11 mins',
      amount: 2100,
      requestedAt: DateTime.now().subtract(const Duration(days: 1)),
      cancelledAt: DateTime.now().subtract(const Duration(days: 1)),
      riderId: '44',
      riderPhone: '+2348000000004',
      vehicleLabel: 'Red Bajaj Boxer',
      plateNumber: 'JOS-123AB',
    ),
  ];

  @override
  Future<JosiUser> profile() async => JosiMockData.rider;

  @override
  Future<RiderOnboarding> onboarding() async => _onboarding;

  @override
  Future<RiderProfile> riderProfile() async =>
      _onboarding.profile ?? JosiMockData.riderProfile;

  @override
  Future<Vehicle> vehicle() async =>
      _onboarding.ridingDetails ?? JosiMockData.vehicle;

  @override
  Future<List<DocumentRequirement>> documents() async => JosiMockData.documents;

  @override
  Future<List<Trip>> availableTrips() async => List<Trip>.unmodifiable(_trips);

  @override
  Future<Trip> trip(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 20));
    return _trips.firstWhere(
      (Trip trip) => trip.id == id,
      orElse: () =>
          throw const ApiException('Trip was not returned by the API.'),
    );
  }

  @override
  Future<Trip> acceptTrip(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 20));
    final Trip trip = await this.trip(id);
    final Trip accepted = _copyTrip(trip, status: TripStatus.active);
    _replaceTrip(accepted);
    return accepted;
  }

  @override
  Future<Trip> declineTrip(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 20));
    final Trip trip = await this.trip(id);
    _trips.removeWhere((Trip value) => value.id == id);
    return _copyTrip(trip, status: TripStatus.cancelled);
  }

  @override
  Future<Trip> markArrivedAtPickup(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 20));
    final Trip trip = await this.trip(id);
    final Trip arrived = _copyTrip(
      trip,
      status: TripStatus.active,
      isArrivedAtPickup: true,
    );
    _replaceTrip(arrived);
    return arrived;
  }

  @override
  Future<RiderOnboarding> updateProfile({
    required String fullName,
    required String phone,
    required String gender,
    required String city,
    String? state,
    String? address,
    String? profilePhoto,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 20));
    _onboarding = RiderOnboarding(
      profile: _profile(
        fullName: fullName,
        phone: phone,
        gender: gender,
        address: address,
        city: city,
        state: state,
        profilePhoto: profilePhoto,
        bank: _onboarding.bankAccount,
      ),
      bankAccount: _onboarding.bankAccount,
      ridingDetails: _onboarding.ridingDetails,
      profilePictureComplete: _onboarding.profilePictureComplete ||
          (profilePhoto?.trim().isNotEmpty ?? false),
      bankAccountComplete: _onboarding.bankAccountComplete,
      ridingDetailsComplete: _onboarding.ridingDetailsComplete,
      isSubmitted: _onboarding.isSubmitted,
    );
    return _onboarding;
  }

  @override
  Future<RiderOnboarding> saveProfilePicture({
    required String profilePhoto,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 20));
    _onboarding = RiderOnboarding(
      profile: _profile(profilePhoto: profilePhoto),
      bankAccount: _onboarding.bankAccount,
      ridingDetails: _onboarding.ridingDetails,
      profilePictureComplete: true,
      bankAccountComplete: _onboarding.bankAccountComplete,
      ridingDetailsComplete: _onboarding.ridingDetailsComplete,
      isSubmitted: _onboarding.isSubmitted,
    );
    return _onboarding;
  }

  @override
  Future<RiderOnboarding> saveBankAccount({
    required String accountNumber,
    required String bankName,
    required String accountName,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 20));
    final RiderBankAccount bank = RiderBankAccount(
      bankName: bankName,
      accountName: accountName,
      accountNumber: accountNumber,
    );
    _onboarding = RiderOnboarding(
      profile: _profile(
        profilePhoto: _onboarding.profile?.profilePhoto,
        bank: bank,
      ),
      bankAccount: bank,
      ridingDetails: _onboarding.ridingDetails,
      profilePictureComplete: _onboarding.profilePictureComplete,
      bankAccountComplete: true,
      ridingDetailsComplete: _onboarding.ridingDetailsComplete,
      isSubmitted: _onboarding.isSubmitted,
    );
    return _onboarding;
  }

  @override
  Future<RiderOnboarding> saveRidingDetails({
    required String vehicleType,
    required String brand,
    required String model,
    required String color,
    required String plateNumber,
    required String registrationNumber,
    required String city,
    String? state,
    String? licenseNumber,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 20));
    _onboarding = RiderOnboarding(
      profile: _profile(
        profilePhoto: _onboarding.profile?.profilePhoto,
        bank: _onboarding.bankAccount,
      ),
      bankAccount: _onboarding.bankAccount,
      ridingDetails: Vehicle(
        type: vehicleType,
        brand: brand,
        model: model,
        color: color,
        plateNumber: plateNumber,
        registrationNumber: registrationNumber,
        chassisNumber: '',
        engineNumber: '',
      ),
      profilePictureComplete: _onboarding.profilePictureComplete,
      bankAccountComplete: _onboarding.bankAccountComplete,
      ridingDetailsComplete: true,
      isSubmitted: _onboarding.isSubmitted,
    );
    return _onboarding;
  }

  @override
  Future<RiderOnboarding> submitOnboarding() async {
    await Future<void>.delayed(const Duration(milliseconds: 20));
    if (!_onboarding.isComplete) {
      throw const ApiException(
        'Complete all required rider account sections before submitting.',
        errors: <String, Object?>{
          'onboarding': <String>[
            'Complete all required rider account sections before submitting.'
          ],
        },
      );
    }

    _onboarding = RiderOnboarding(
      profile: _onboarding.profile,
      bankAccount: _onboarding.bankAccount,
      ridingDetails: _onboarding.ridingDetails,
      profilePictureComplete: true,
      bankAccountComplete: true,
      ridingDetailsComplete: true,
      isSubmitted: true,
      submittedAt: '2026-06-17T00:00:00Z',
    );
    return _onboarding;
  }

  RiderProfile _profile({
    String? fullName,
    String? phone,
    String? gender,
    String? address,
    String? city,
    String? state,
    String? profilePhoto,
    RiderBankAccount? bank,
  }) {
    final RiderProfile base = JosiMockData.riderProfile;
    return RiderProfile(
      fullName: fullName ?? base.fullName,
      phone: phone ?? base.phone,
      gender: gender ?? base.gender,
      dateOfBirth: base.dateOfBirth,
      address: address ?? base.address,
      city: city ?? base.city,
      state: state ?? base.state,
      rating: base.rating,
      completedTrips: base.completedTrips,
      profilePhoto: profilePhoto,
      bankName: bank?.bankName,
      bankAccountName: bank?.accountName,
      bankAccountNumber: bank?.accountNumber,
      applicationStatus: RiderApplicationStatus.underReview,
    );
  }

  void _replaceTrip(Trip updated) {
    final int index = _trips.indexWhere((Trip trip) => trip.id == updated.id);
    if (index == -1) {
      _trips.add(updated);
      return;
    }
    _trips[index] = updated;
  }
}

Future<void> _finishSplash(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 2200));
  await tester.pumpAndSettle();
}

Future<void> _pumpToRoleSelection(
  WidgetTester tester, {
  RiderRepository? riderRepository,
  WalletRepository? walletRepository,
  ProfilePhotoPicker? profilePhotoPicker,
}) async {
  await _pumpApp(
    tester,
    riderRepository: riderRepository,
    walletRepository: walletRepository,
    profilePhotoPicker: profilePhotoPicker,
  );
  await _finishSplash(tester);
}

Future<void> _loginAsCustomer(WidgetTester tester) async {
  await _pumpToRoleSelection(tester);
  _expectVisibleInViewport(tester, find.text('Get Started'));
  await tester.tap(find.text('Get Started'));
  await tester.pumpAndSettle();
  _expectVisibleInViewport(
      tester, find.byKey(const ValueKey<String>('login-button')));
  await tester.enterText(find.byType(TextField).at(0), 'customer@josi.test');
  await tester.enterText(find.byType(TextField).at(1), 'Password123!');
  await tester.tap(find.byKey(const ValueKey<String>('login-button')));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 650));
  await tester.pumpAndSettle();
}

Future<void> _loginAsRider(
  WidgetTester tester, {
  RiderRepository? riderRepository,
  WalletRepository? walletRepository,
  ProfilePhotoPicker? profilePhotoPicker,
}) async {
  await _pumpToRoleSelection(
    tester,
    riderRepository: riderRepository,
    walletRepository: walletRepository,
    profilePhotoPicker: profilePhotoPicker,
  );
  _expectVisibleInViewport(tester, find.text('Drive with Us'));
  await tester.tap(find.text('Drive with Us'));
  await tester.pumpAndSettle();
  _expectVisibleInViewport(
      tester, find.byKey(const ValueKey<String>('login-button')));
  await tester.enterText(find.byType(TextField).at(0), 'rider@josi.test');
  await tester.enterText(find.byType(TextField).at(1), 'Password123!');
  await tester.tap(find.byKey(const ValueKey<String>('login-button')));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 650));
  await tester.pumpAndSettle();
}

Future<void> _completeRiderOnboarding(WidgetTester tester) async {
  expect(find.byKey(const ValueKey<String>('rider-application-status-screen')),
      findsOneWidget);

  await tester.tap(find.text('Profile Picture'));
  await tester.pumpAndSettle();
  await tester
      .tap(find.byKey(const ValueKey<String>('rider-profile-photo-picker')));
  await tester.pumpAndSettle();
  await tester
      .tap(find.byKey(const ValueKey<String>('rider-profile-photo-camera')));
  await tester.pumpAndSettle();
  await tester
      .tap(find.byKey(const ValueKey<String>('rider-bottom-action-continue')));
  await tester.pumpAndSettle();

  await tester.enterText(find.byType(TextField).at(0), '0123456789');
  await tester.enterText(find.byType(TextField).at(1), 'Josi Microfinance');
  await tester.enterText(find.byType(TextField).at(2), 'Amina Yusuf');
  await tester
      .tap(find.byKey(const ValueKey<String>('rider-bottom-action-continue')));
  await tester.pumpAndSettle();

  await tester.enterText(find.byType(TextField).at(0), 'Toyota');
  await tester.enterText(find.byType(TextField).at(1), 'Corolla');
  await tester.enterText(find.byType(TextField).at(2), 'White');
  await tester.enterText(find.byType(TextField).at(3), 'ABC 482 JK');
  await tester.enterText(find.byType(TextField).at(4), 'REG-2408-JR');
  await tester
      .tap(find.byKey(const ValueKey<String>('rider-bottom-action-continue')));
  await tester.pumpAndSettle();

  expect(find.byKey(const ValueKey<String>('rider-application-status-screen')),
      findsOneWidget);
}

void _mockDeviceLocation(
  WidgetTester tester, {
  VoidCallback? onCall,
}) {
  _mockLocationCall = onCall;
  addTearDown(() {
    _mockLocationCall = null;
  });
}

class _FakeLocationService extends LocationService {
  const _FakeLocationService({this.onCall});

  final VoidCallback? onCall;

  @override
  Future<Position> currentPosition() async {
    onCall?.call();
    return Position(
      latitude: 9.0765,
      longitude: 7.3986,
      timestamp: DateTime(2026, 6, 13),
      accuracy: 8,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: 0,
      headingAccuracy: 0,
      speed: 0,
      speedAccuracy: 0,
    );
  }

  @override
  Future<bool> openAppSettings() async => true;
}

class _FakeReverseGeocodingService extends ReverseGeocodingService {
  const _FakeReverseGeocodingService();

  @override
  Future<String> addressFromCoordinates({
    required double latitude,
    required double longitude,
    String fallback = 'Selected location',
  }) async {
    if (latitude.toStringAsFixed(4) == '9.0816' &&
        longitude.toStringAsFixed(4) == '7.4634') {
      return 'Jabi, Abuja, Federal Capital Territory, Nigeria';
    }
    return 'Wuse 2, Abuja, Federal Capital Territory, Nigeria';
  }
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
