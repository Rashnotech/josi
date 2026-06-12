import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_assets.dart';
import '../../core/constants/app_routes.dart';
import '../../core/mock/josi_mock_data.dart';
import '../../core/mock/josi_models.dart';
import '../../core/providers/app_providers.dart';
import '../../core/theme/josi_colors.dart';
import '../../core/widgets/app_components.dart';

class RiderHomeScreen extends ConsumerStatefulWidget {
  const RiderHomeScreen({super.key});

  @override
  ConsumerState<RiderHomeScreen> createState() => _RiderHomeScreenState();
}

class _RiderHomeScreenState extends ConsumerState<RiderHomeScreen> {
  bool _isOnline = true;
  bool _showRideRequest = false;

  @override
  Widget build(BuildContext context) {
    final Trip requestTrip = JosiMockData.trips.first;

    return Scaffold(
      key: const ValueKey<String>('rider-home-screen'),
      backgroundColor: JosiColors.white,
      body: Stack(
        children: <Widget>[
          const Positioned.fill(child: _RiderDashboardMapBackdrop()),
          Positioned(
            left: 20,
            right: 20,
            top: MediaQuery.paddingOf(context).top + 48,
            child: _RiderDashboardHeader(
              isOnline: _isOnline,
              onToggle: () => setState(() => _isOnline = !_isOnline),
            ),
          ),
          if (!_showRideRequest)
            Positioned(
              left: 20,
              right: 20,
              top: MediaQuery.paddingOf(context).top + 122,
              child: const _RiderDashboardMetrics(),
            ),
          if (_showRideRequest)
            Positioned(
              left: 0,
              right: 0,
              top: MediaQuery.paddingOf(context).top + 260,
              child: const _RideRequestTimer(),
            ),
          Align(
            alignment: Alignment.bottomCenter,
            child: _showRideRequest
                ? _RideRequestSheet(
                    trip: requestTrip,
                    onDecline: () => setState(() => _showRideRequest = false),
                    onAccept: () => context
                        .go(AppRoutes.riderActiveTripPath(requestTrip.id)),
                  )
                : _FindingJobsPanel(
                    onFindingJobs: () =>
                        setState(() => _showRideRequest = true),
                  ),
          ),
        ],
      ),
      bottomNavigationBar:
          const AppBottomNav(role: AppNavRole.rider, selectedTab: 'home'),
    );
  }
}

class RiderLocationAccessScreen extends StatelessWidget {
  const RiderLocationAccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const ValueKey<String>('rider-location-access-screen'),
      backgroundColor: JosiColors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(30, 18, 30, 26),
              child: Column(
                children: <Widget>[
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: _RiderCircleBackButton(
                      fallbackRoute: AppRoutes.riderApplicationStatus,
                    ),
                  ),
                  const Spacer(flex: 2),
                  Container(
                    width: 128,
                    height: 128,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF7F7F7),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        AppAssets.location,
                        width: 62,
                        height: 62,
                        colorFilter: const ColorFilter.mode(
                          JosiColors.red,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),
                  Text(
                    'Enable Location Access',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: JosiColors.ink,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'We use your location to find nearby ride requests and guide your trips accurately.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: JosiColors.softMuted,
                          fontSize: 18,
                          height: 1.35,
                        ),
                  ),
                  const Spacer(flex: 3),
                  SizedBox(
                    width: double.infinity,
                    height: 62,
                    child: ElevatedButton(
                      key:
                          const ValueKey<String>('rider-location-allow-button'),
                      onPressed: () => context.go(AppRoutes.riderHome),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: JosiColors.red,
                        foregroundColor: JosiColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                        textStyle:
                            Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: JosiColors.white,
                                  fontSize: 21,
                                  fontWeight: FontWeight.w800,
                                ),
                      ),
                      child: const Text('Allow Location Access'),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    key: const ValueKey<String>('rider-location-maybe-later'),
                    onPressed: () => context.go(AppRoutes.riderHome),
                    child: Text(
                      'Maybe Later',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: JosiColors.softMuted,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class RiderApplicationStatusScreen extends StatelessWidget {
  const RiderApplicationStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const ValueKey<String>('rider-application-status-screen'),
      backgroundColor: JosiColors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(
              children: <Widget>[
                const Padding(
                  padding: EdgeInsets.fromLTRB(24, 10, 24, 0),
                  child: Row(
                    children: <Widget>[
                      _RiderCircleBackButton(
                          fallbackRoute: AppRoutes.roleSelection),
                      Spacer(),
                      SizedBox(width: 54),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  'Welcome!, Esther',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: JosiColors.ink,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 30),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Text(
                          'Required Steps',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: JosiColors.ink,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                  ),
                        ),
                        const SizedBox(height: 14),
                        _RiderStepTile(
                          label: 'Profile Picture',
                          onTap: () =>
                              context.go(AppRoutes.riderProfilePicture),
                        ),
                        const SizedBox(height: 12),
                        _RiderStepTile(
                          label: 'Bank Account Details',
                          onTap: () =>
                              context.go(AppRoutes.riderBankAccountDetails),
                        ),
                        const SizedBox(height: 12),
                        _RiderStepTile(
                          label: 'Driving Details',
                          onTap: () => context.go(AppRoutes.riderVehicleSetup),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _RiderFixedBottomAction(
        label: 'Continue',
        onPressed: () => _showSubmissionSheet(context),
      ),
    );
  }

  void _showSubmissionSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext bottomSheetContext) {
        return _ApplicationSubmittedSheet(
          onGotIt: () {
            Navigator.of(bottomSheetContext).pop();
            context.go(AppRoutes.riderLocationAccess);
          },
        );
      },
    );
  }
}

class RiderProfileSetupScreen extends StatefulWidget {
  const RiderProfileSetupScreen({super.key});

  @override
  State<RiderProfileSetupScreen> createState() =>
      _RiderProfileSetupScreenState();
}

class _RiderProfileSetupScreenState extends State<RiderProfileSetupScreen> {
  String _gender = 'Select';
  String _city = 'Jersey City, New Jersey';
  bool _acceptedTerms = true;

  @override
  Widget build(BuildContext context) {
    return _RiderFlowScaffold(
      key: const ValueKey<String>('rider-profile-setup-screen'),
      fallbackRoute: AppRoutes.riderApplicationStatus,
      headline: 'Complete Your Profile',
      subtitle:
          "Don't worry, only you can see your personal data. No one else will be able to see it.",
      bottomLabel: 'Continue',
      onBottomPressed: () => context.go(AppRoutes.riderProfilePicture),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const _RiderFormField(label: 'Name', hintText: 'Jenny Wilson'),
          const SizedBox(height: 14),
          const _RiderFormField(label: 'Email', hintText: 'example@gmail.com'),
          const SizedBox(height: 14),
          const _RiderPhoneField(),
          const SizedBox(height: 14),
          _RiderSelectField(
            label: 'Gender',
            value: _gender,
            items: const <String>['Select', 'Female', 'Male'],
            onChanged: (String? value) =>
                setState(() => _gender = value ?? _gender),
          ),
          const SizedBox(height: 14),
          _RiderSelectField(
            label: 'City You Drive In',
            value: _city,
            items: const <String>[
              'Jersey City, New Jersey',
              'Abuja, FCT',
              'Lagos, Lagos',
            ],
            onChanged: (String? value) =>
                setState(() => _city = value ?? _city),
          ),
          const SizedBox(height: 22),
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => setState(() => _acceptedTerms = !_acceptedTerms),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: _acceptedTerms ? JosiColors.red : JosiColors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color:
                            _acceptedTerms ? JosiColors.red : JosiColors.line),
                  ),
                  child: _acceptedTerms
                      ? const Icon(Icons.check_rounded,
                          color: JosiColors.white, size: 24)
                      : null,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      text: 'By Accept, you agree to Company ',
                      children: <InlineSpan>[
                        TextSpan(
                          text: 'Terms & Condition',
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: JosiColors.red,
                                    decoration: TextDecoration.underline,
                                    decorationColor: JosiColors.red,
                                  ),
                        ),
                      ],
                    ),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: JosiColors.ink,
                          fontSize: 17,
                          height: 1.35,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RiderProfilePictureScreen extends StatelessWidget {
  const RiderProfilePictureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _RiderFlowScaffold(
      key: const ValueKey<String>('rider-profile-picture-screen'),
      fallbackRoute: AppRoutes.riderProfileSetup,
      appBarTitle: 'Profile Picture',
      bottomLabel: 'Done',
      onBottomPressed: () => context.go(AppRoutes.riderBankAccountDetails),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _UploadRequirement('Please Upload a Clear Selfie'),
          SizedBox(height: 16),
          _UploadRequirement(
              'The Selfie Should have the applicants face alone'),
          SizedBox(height: 16),
          _UploadRequirement('Upload PDF / JPEG / PNG'),
          SizedBox(height: 26),
          Divider(color: JosiColors.line),
          SizedBox(height: 28),
          Text('Profile Picture',
              style: TextStyle(
                  color: JosiColors.ink,
                  fontSize: 20,
                  fontWeight: FontWeight.w800)),
          SizedBox(height: 16),
          _DashedUploadBox(),
          SizedBox(height: 26),
          _AttachedFilePreview(
            title: 'Profile',
            meta: 'JPG',
            sizeLabel: '250 kb',
            icon: Icons.person_rounded,
          ),
        ],
      ),
    );
  }
}

class RiderBankAccountDetailsScreen extends StatelessWidget {
  const RiderBankAccountDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _RiderFlowScaffold(
      key: const ValueKey<String>('rider-bank-account-details-screen'),
      fallbackRoute: AppRoutes.riderProfilePicture,
      appBarTitle: 'Bank Account Details',
      bottomLabel: 'Done',
      onBottomPressed: () => context.go(AppRoutes.riderApplicationStatus),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _RiderFormField(
            label: 'Account Number',
            hintText: '0123456789',
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 14),
          _RiderFormField(
              label: 'Bank Name', hintText: 'Josi Microfinance Bank'),
          SizedBox(height: 14),
          _RiderFormField(label: 'Account Name', hintText: 'Jenny Wilson'),
        ],
      ),
    );
  }
}

class RiderVehicleSetupScreen extends StatelessWidget {
  const RiderVehicleSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Vehicle setup',
      subtitle: 'Vehicle and documents',
      child: AppScreenBody(
        children: <Widget>[
          const VehicleCard(vehicle: JosiMockData.vehicle),
          const SizedBox(height: 16),
          const AppTextField(
              label: 'Vehicle type',
              hintText: 'Car',
              icon: Icons.category_rounded),
          const SizedBox(height: 12),
          const AppTextField(
              label: 'Brand',
              hintText: 'Toyota',
              icon: Icons.directions_car_rounded),
          const SizedBox(height: 12),
          const AppTextField(
              label: 'Model',
              hintText: 'Corolla',
              icon: Icons.car_repair_rounded),
          const SizedBox(height: 12),
          const AppTextField(
              label: 'Color', hintText: 'White', icon: Icons.palette_outlined),
          const SizedBox(height: 12),
          const AppTextField(
              label: 'Plate number',
              hintText: 'ABC 482 JK',
              icon: Icons.pin_rounded),
          const SizedBox(height: 12),
          const AppTextField(
              label: 'Chassis number',
              hintText: 'JTDBR32E123456789',
              icon: Icons.confirmation_number_outlined),
          const SizedBox(height: 12),
          const AppTextField(
              label: 'Engine number',
              hintText: '2ZR-789432',
              icon: Icons.memory_rounded),
          const SizedBox(height: 16),
          const SectionHeader(title: 'Vehicle documents'),
          const DocumentUploadCard(
            document: DocumentRequirement(
              title: 'Vehicle registration',
              description: 'Upload valid registration document',
              status: DocumentStatus.notUploaded,
            ),
          ),
          const SizedBox(height: 18),
          AppButton(
              label: 'Save vehicle',
              icon: Icons.save_rounded,
              onPressed: () {}),
        ],
      ),
    );
  }
}

class AvailableTripsScreen extends ConsumerWidget {
  const AvailableTripsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Trip>> trips = ref.watch(tripsProvider);

    return AppScaffold(
      title: 'Available trips',
      subtitle: 'Requests near your zone',
      child: AppScreenBody(
        children: <Widget>[
          trips.when(
            data: (List<Trip> values) => values.isEmpty
                ? const EmptyState(
                    title: 'No requests nearby',
                    message: 'New requests will appear here.')
                : Column(
                    children: values.map((Trip trip) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: TripCard(
                          trip: trip,
                          trailing: AppButton(
                            label: 'Accept',
                            onPressed: () => context
                                .go(AppRoutes.riderTripRequestPath(trip.id)),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
            error: (Object error, StackTrace stackTrace) => const ErrorState(
                title: 'Requests unavailable',
                message: 'Available trips could not load.'),
            loading: () => const SizedBox(
                height: 220, child: LoadingState(label: 'Loading requests')),
          ),
        ],
      ),
    );
  }
}

class RiderTripRequestDetailScreen extends ConsumerWidget {
  const RiderTripRequestDetailScreen({
    required this.tripId,
    super.key,
  });

  final String tripId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Trip>> trips = ref.watch(tripsProvider);

    return AppScaffold(
      title: 'Trip request',
      subtitle: tripId,
      child: AppScreenBody(
        children: <Widget>[
          trips.when(
            data: (List<Trip> values) {
              final Trip trip = values.firstWhere(
                  (Trip value) => value.id == tripId,
                  orElse: () => values.first);
              return Column(
                children: <Widget>[
                  TripCard(trip: trip),
                  const SizedBox(height: 16),
                  AppCard(
                    child: Column(
                      children: <Widget>[
                        _SummaryRow(label: 'Estimated fare', value: trip.fare),
                        _SummaryRow(
                            label: 'Payment method',
                            value: _paymentLabel(trip.paymentMethod)),
                        _SummaryRow(
                            label: 'Customer', value: trip.customerName),
                        _SummaryRow(label: 'Distance', value: trip.distance),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  AppButton(
                    label: 'Accept trip',
                    icon: Icons.check_rounded,
                    onPressed: () =>
                        context.go(AppRoutes.riderActiveTripPath(trip.id)),
                  ),
                  const SizedBox(height: 10),
                  AppButton(
                    label: 'Decline',
                    icon: Icons.close_rounded,
                    variant: AppButtonVariant.secondary,
                    onPressed: () => context.go(AppRoutes.riderAvailableTrips),
                  ),
                ],
              );
            },
            error: (Object error, StackTrace stackTrace) => const ErrorState(
                title: 'Request unavailable',
                message: 'Trip request could not load.'),
            loading: () => const SizedBox(
                height: 220, child: LoadingState(label: 'Loading request')),
          ),
        ],
      ),
    );
  }
}

class RiderActiveTripScreen extends StatefulWidget {
  const RiderActiveTripScreen({
    required this.tripId,
    super.key,
  });

  final String tripId;

  @override
  State<RiderActiveTripScreen> createState() => _RiderActiveTripScreenState();
}

class _RiderActiveTripScreenState extends State<RiderActiveTripScreen> {
  int _stage = 0;

  @override
  Widget build(BuildContext context) {
    final Trip trip = JosiMockData.trips.firstWhere(
      (Trip value) => value.id == widget.tripId,
      orElse: () => JosiMockData.trips.first,
    );
    final List<String> titles = <String>[
      'Customer Location',
      'Destination',
      'Arrived At Destination',
    ];
    final int stageIndex = _stage.clamp(0, titles.length - 1).toInt();
    final String title = titles[stageIndex];

    return Scaffold(
      key: const ValueKey<String>('rider-active-trip-screen'),
      backgroundColor: JosiColors.white,
      body: Stack(
        children: <Widget>[
          const Positioned.fill(child: _RiderMapBackdrop()),
          Positioned(
            left: 26,
            top: MediaQuery.paddingOf(context).top + 26,
            child: const _RiderCircleBackButton(
              fallbackRoute: AppRoutes.riderHome,
            ),
          ),
          Positioned(
            left: 96,
            right: 96,
            top: MediaQuery.paddingOf(context).top + 48,
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: JosiColors.ink,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
          if (stageIndex > 0)
            Positioned(
              right: 28,
              bottom: stageIndex == 1 ? 192 : 300,
              child: const _RiderLocateButton(),
            ),
          Align(
            alignment: Alignment.bottomCenter,
            child: switch (stageIndex) {
              0 => _RiderCustomerLocationSheet(
                  title: title,
                  trip: trip,
                  onContinue: () => setState(() => _stage = 1),
                ),
              1 => _RiderDestinationPanel(
                  onNavigate: () => setState(() => _stage = 2),
                ),
              _ => _RiderArrivedDestinationSheet(
                  onCollectCash: () => context.go(AppRoutes.riderCollectCash),
                ),
            },
          ),
        ],
      ),
    );
  }
}

class RiderTripCompletedScreen extends StatelessWidget {
  const RiderTripCompletedScreen({
    required this.tripId,
    super.key,
  });

  final String tripId;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Trip completed',
      subtitle: tripId,
      child: AppScreenBody(
        children: <Widget>[
          const EmptyState(
            title: 'Trip closed',
            message: 'Your earning has been added to the rider wallet.',
            icon: Icons.check_circle_rounded,
          ),
          const SizedBox(height: 16),
          const AppCard(
            child: Column(
              children: <Widget>[
                _SummaryRow(label: 'Fare', value: 'NGN 3,500'),
                _SummaryRow(label: 'Rider earning', value: 'NGN 2,800'),
                _SummaryRow(label: 'Company share', value: 'NGN 700'),
                _SummaryRow(
                    label: 'Cash collected', value: 'Pending confirmation'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppButton(
            label: 'Mark cash collected',
            icon: Icons.price_check_rounded,
            onPressed: () {},
          ),
          const SizedBox(height: 10),
          AppButton(
            label: 'Back to home',
            icon: Icons.home_rounded,
            variant: AppButtonVariant.secondary,
            onPressed: () => context.go(AppRoutes.riderHome),
          ),
        ],
      ),
    );
  }
}

class RiderTripsScreen extends StatelessWidget {
  const RiderTripsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const ValueKey<String>('rider-bookings-screen'),
      backgroundColor: JosiColors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                  child: Row(
                    children: <Widget>[
                      const _RiderCircleBackButton(
                        fallbackRoute: AppRoutes.riderHome,
                      ),
                      Expanded(
                        child: Text(
                          'Bookings',
                          textAlign: TextAlign.center,
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: JosiColors.ink,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                  ),
                        ),
                      ),
                      const SizedBox(width: 54),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                const _RiderBookingTabs(),
                const SizedBox(height: 22),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: _RiderBookingCard(
                      onCancel: () => context.go(AppRoutes.riderCancelRide),
                      onTrack: () =>
                          context.go(AppRoutes.riderActiveTripPath('TRP-2408')),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar:
          const AppBottomNav(role: AppNavRole.rider, selectedTab: 'bookings'),
    );
  }
}

class RiderCancelRideScreen extends StatefulWidget {
  const RiderCancelRideScreen({super.key});

  @override
  State<RiderCancelRideScreen> createState() => _RiderCancelRideScreenState();
}

class _RiderCancelRideScreenState extends State<RiderCancelRideScreen> {
  static const List<String> _reasons = <String>[
    'Rider Not Available',
    'Rider want to book another cab',
    'Rider Misbehave',
    'Taxi Breakdown',
    'Punchture',
    'Other',
  ];

  String _selectedReason = _reasons.first;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const ValueKey<String>('rider-cancel-ride-screen'),
      backgroundColor: JosiColors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                  child: Row(
                    children: <Widget>[
                      const _RiderCircleBackButton(
                        fallbackRoute: AppRoutes.riderTrips,
                      ),
                      Expanded(
                        child: Text(
                          'Cancel Ride',
                          textAlign: TextAlign.center,
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: JosiColors.ink,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                  ),
                        ),
                      ),
                      const SizedBox(width: 54),
                    ],
                  ),
                ),
                const SizedBox(height: 52),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(30, 0, 30, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Please select the reason for cancelations:',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: JosiColors.ink,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                        const SizedBox(height: 24),
                        ..._reasons.map(
                          (String reason) => _RiderCancelReasonTile(
                            label: reason,
                            selected: _selectedReason == reason,
                            onTap: () =>
                                setState(() => _selectedReason = reason),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Other',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: JosiColors.ink,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          minLines: 5,
                          maxLines: 5,
                          decoration: InputDecoration(
                            hintText: 'Enter your Reason',
                            hintStyle:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: JosiColors.softMuted,
                                      fontSize: 17,
                                    ),
                            filled: true,
                            fillColor: JosiColors.white,
                            contentPadding: const EdgeInsets.all(18),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  const BorderSide(color: JosiColors.line),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                  color: JosiColors.red, width: 1.4),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _RiderFixedBottomAction(
        label: 'Cancel Ride',
        onPressed: () => _showCancellationSuccess(context),
      ),
    );
  }

  void _showCancellationSuccess(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext bottomSheetContext) {
        return _BookingCancelledSheet(
          onGotIt: () {
            Navigator.of(bottomSheetContext).pop();
            context.go(AppRoutes.riderTrips);
          },
        );
      },
    );
  }
}

class RiderCollectCashScreen extends StatelessWidget {
  const RiderCollectCashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const ValueKey<String>('rider-collect-cash-screen'),
      backgroundColor: JosiColors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                  child: Row(
                    children: <Widget>[
                      const _RiderCircleBackButton(
                        fallbackRoute: AppRoutes.riderHome,
                      ),
                      Expanded(
                        child: Text(
                          'Collect Cash',
                          textAlign: TextAlign.center,
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: JosiColors.ink,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                  ),
                        ),
                      ),
                      const SizedBox(width: 54),
                    ],
                  ),
                ),
                const SizedBox(height: 48),
                const Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(28, 0, 28, 24),
                    child: _RiderCollectCashCard(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _RiderFixedBottomAction(
        label: 'Cash Collected',
        onPressed: () =>
            context.go(AppRoutes.riderTripCompletedPath('TRP-2408')),
      ),
    );
  }
}

class RiderWalletScreen extends ConsumerWidget {
  const RiderWalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<WalletSummary> summary = ref.watch(riderWalletProvider);
    final AsyncValue<List<WalletTransaction>> transactions =
        ref.watch(walletTransactionsProvider);

    return AppScaffold(
      title: 'Wallet',
      subtitle: 'Earnings and settlement',
      navRole: AppNavRole.rider,
      selectedTab: 'wallet',
      child: AppScreenBody(
        children: <Widget>[
          summary.when(
            data: (WalletSummary wallet) => Column(
              children: <Widget>[
                WalletBalanceCard(
                  title: 'Available balance',
                  balance: wallet.availableBalance,
                  subtitle: 'Total earnings ${wallet.totalEarnings}',
                ),
                const SizedBox(height: 12),
                Row(
                  children: <Widget>[
                    Expanded(
                        child: MetricTile(
                            label: 'Today',
                            value: wallet.todayEarnings,
                            icon: Icons.today_rounded)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: MetricTile(
                        label: 'Remittance',
                        value: wallet.pendingRemittance,
                        icon: Icons.price_check_rounded,
                        color: JosiColors.warning,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            error: (Object error, StackTrace stackTrace) => const ErrorState(
                title: 'Wallet unavailable',
                message: 'Earnings could not load.'),
            loading: () => const SizedBox(
                height: 220, child: LoadingState(label: 'Loading wallet')),
          ),
          const SizedBox(height: 16),
          AppButton(
            label: 'Cash ledger',
            icon: Icons.receipt_long_rounded,
            variant: AppButtonVariant.secondary,
            onPressed: () => context.go(AppRoutes.riderCashLedger),
          ),
          const SizedBox(height: 16),
          const SectionHeader(title: 'Transactions'),
          transactions.when(
            data: (List<WalletTransaction> values) => Column(
              children: values
                  .map(
                    (WalletTransaction transaction) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _TransactionCard(transaction: transaction),
                    ),
                  )
                  .toList(),
            ),
            error: (Object error, StackTrace stackTrace) => const ErrorState(
                title: 'Transactions unavailable',
                message: 'Please try again later.'),
            loading: () => const SizedBox(
                height: 160,
                child: LoadingState(label: 'Loading transactions')),
          ),
        ],
      ),
    );
  }
}

class RiderCashLedgerScreen extends ConsumerWidget {
  const RiderCashLedgerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<CashLedgerEntry>> ledger =
        ref.watch(cashLedgerProvider);

    return AppScaffold(
      title: 'Cash ledger',
      subtitle: 'Cash collected and remittance',
      child: AppScreenBody(
        children: <Widget>[
          const AppCard(
            color: JosiColors.warningSoft,
            child: Text(
              'Cash trips create a company-share remittance entry. Reconcile pending cash before payout review.',
            ),
          ),
          const SizedBox(height: 16),
          ledger.when(
            data: (List<CashLedgerEntry> values) => Column(
              children: values
                  .map(
                    (CashLedgerEntry entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: AppCard(
                        child: Column(
                          children: <Widget>[
                            _SummaryRow(label: 'Trip', value: entry.tripId),
                            _SummaryRow(
                                label: 'Cash collected',
                                value: entry.cashCollected),
                            _SummaryRow(
                                label: 'Company share',
                                value: entry.companyShare),
                            _SummaryRow(
                                label: 'Amount to remit',
                                value: entry.amountToRemit),
                            Row(
                              children: <Widget>[
                                const Spacer(),
                                StatusBadge(
                                  label: entry.status,
                                  color: entry.status == 'remitted'
                                      ? JosiColors.success
                                      : JosiColors.warning,
                                  softColor: entry.status == 'remitted'
                                      ? JosiColors.successSoft
                                      : JosiColors.warningSoft,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            error: (Object error, StackTrace stackTrace) => const ErrorState(
                title: 'Ledger unavailable',
                message: 'Cash ledger could not load.'),
            loading: () => const SizedBox(
                height: 220, child: LoadingState(label: 'Loading ledger')),
          ),
        ],
      ),
    );
  }
}

class RiderProfileScreen extends ConsumerWidget {
  const RiderProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<RiderProfile> profile = ref.watch(riderProfileProvider);

    return AppScaffold(
      title: 'Profile',
      subtitle: 'Rider account',
      navRole: AppNavRole.rider,
      selectedTab: 'profile',
      child: AppScreenBody(
        children: <Widget>[
          profile.when(
            data: (RiderProfile value) => AppCard(
              child: Row(
                children: <Widget>[
                  ProfileAvatar(name: value.fullName, showEdit: true),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(value.fullName,
                            style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 4),
                        Text(
                            '${value.completedTrips} trips - ${value.rating} rating',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: JosiColors.muted)),
                        Text('${value.city}, ${value.state}',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: JosiColors.muted)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            error: (Object error, StackTrace stackTrace) => const ErrorState(
                title: 'Profile unavailable',
                message: 'Rider profile could not load.'),
            loading: () => const SizedBox(
                height: 120, child: LoadingState(label: 'Loading profile')),
          ),
          const SizedBox(height: 16),
          const _ProfileMenuItem(
              icon: Icons.edit_rounded,
              label: 'Profile setup',
              route: AppRoutes.riderProfileSetup),
          const _ProfileMenuItem(
              icon: Icons.photo_camera_rounded,
              label: 'Profile picture',
              route: AppRoutes.riderProfilePicture),
          const _ProfileMenuItem(
              icon: Icons.account_balance_rounded,
              label: 'Bank Account Details',
              route: AppRoutes.riderBankAccountDetails),
          const _ProfileMenuItem(
              icon: Icons.directions_car_rounded,
              label: 'Vehicle',
              route: AppRoutes.riderVehicleSetup),
          const _ProfileMenuItem(
              icon: Icons.support_agent_rounded,
              label: 'Support',
              route: AppRoutes.riderSupport),
          const _ProfileMenuItem(
              icon: Icons.settings_rounded,
              label: 'Settings',
              route: AppRoutes.riderSettings),
          const SizedBox(height: 10),
          AppButton(
            label: 'Logout',
            icon: Icons.logout_rounded,
            variant: AppButtonVariant.danger,
            onPressed: () async {
              await ref.read(authControllerProvider.notifier).signOut();
              if (context.mounted) {
                context.go(AppRoutes.login);
              }
            },
          ),
        ],
      ),
    );
  }
}

class _RiderStepTile extends StatelessWidget {
  const _RiderStepTile({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: JosiColors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          height: 58,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: JosiColors.line),
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: JosiColors.ink,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: JosiColors.red, size: 26),
            ],
          ),
        ),
      ),
    );
  }
}

class _RiderBookingTabs extends StatelessWidget {
  const _RiderBookingTabs();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: <Widget>[
          _RiderBookingTab(label: 'Active', selected: true),
          _RiderBookingTab(label: 'Completed', selected: false),
          _RiderBookingTab(label: 'Cancelled', selected: false),
        ],
      ),
    );
  }
}

class _RiderBookingTab extends StatelessWidget {
  const _RiderBookingTab({
    required this.label,
    required this.selected,
  });

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: <Widget>[
          Text(
            label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: selected ? JosiColors.red : JosiColors.softMuted,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 12),
          AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            height: 3,
            width: selected ? 88 : 0,
            decoration: BoxDecoration(
              color: JosiColors.red,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ],
      ),
    );
  }
}

class _RiderBookingCard extends StatelessWidget {
  const _RiderBookingCard({
    required this.onCancel,
    required this.onTrack,
  });

  final VoidCallback onCancel;
  final VoidCallback onTrack;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: JosiColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: JosiColors.line),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 22,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              const ProfileAvatar(name: 'Jenny Wilson', size: 58),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Jenny Wilson',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: JosiColors.ink,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'CRN : 4854HO23',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: JosiColors.softMuted,
                            fontSize: 15,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Row(
            children: <Widget>[
              Expanded(
                child: _RiderBookingStat(
                  icon: Icons.route_rounded,
                  value: '4.5 Mile',
                  label: 'Distance',
                ),
              ),
              Expanded(
                child: _RiderBookingStat(
                  icon: Icons.schedule_rounded,
                  value: '4 mins',
                  label: 'Time',
                ),
              ),
              Expanded(
                child: _RiderBookingStat(
                  icon: Icons.attach_money_rounded,
                  value: '\$1.25',
                  label: 'Rate',
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          const Divider(color: JosiColors.line),
          const SizedBox(height: 18),
          Text(
            'Date & Time',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: JosiColors.softMuted,
                  fontSize: 16,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            '12 Jan 2026, 10:15 PM',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: JosiColors.ink,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 20),
          const _RideRequestRouteSummary(),
          const SizedBox(height: 20),
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  'Booking Car Type',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: JosiColors.softMuted,
                        fontSize: 16,
                      ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Sedan',
                maxLines: 1,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: JosiColors.ink,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const _RiderBookingMiniMap(),
          const SizedBox(height: 20),
          Row(
            children: <Widget>[
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: OutlinedButton(
                    key: const ValueKey<String>('rider-booking-cancel-button'),
                    onPressed: onCancel,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: JosiColors.red,
                      side: const BorderSide(color: JosiColors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                      textStyle:
                          Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    key: const ValueKey<String>('rider-booking-track-button'),
                    onPressed: onTrack,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: JosiColors.red,
                      foregroundColor: JosiColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                      textStyle:
                          Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: JosiColors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                    ),
                    child: const Text('Track Rider'),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RiderBookingStat extends StatelessWidget {
  const _RiderBookingStat({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Icon(icon, color: JosiColors.red, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: JosiColors.ink,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: JosiColors.softMuted,
                fontSize: 12,
              ),
        ),
      ],
    );
  }
}

class _RiderBookingMiniMap extends StatelessWidget {
  const _RiderBookingMiniMap();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: 142,
        child: CustomPaint(
          painter: _RiderMapPainter(),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class _RiderCancelReasonTile extends StatelessWidget {
  const _RiderCancelReasonTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: <Widget>[
            AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? JosiColors.red : JosiColors.line,
                  width: 2,
                ),
              ),
              child: Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  width: selected ? 16 : 0,
                  height: selected ? 16 : 0,
                  decoration: const BoxDecoration(
                    color: JosiColors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: JosiColors.ink,
                      fontSize: 19,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookingCancelledSheet extends StatelessWidget {
  const _BookingCancelledSheet({required this.onGotIt});

  final VoidCallback onGotIt;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey<String>('rider-cancel-success-sheet'),
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(34, 18, 34, 20),
      decoration: const BoxDecoration(
        color: JosiColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 98,
              height: 4,
              decoration: BoxDecoration(
                color: JosiColors.line,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 52),
            Container(
              width: 106,
              height: 106,
              decoration: const BoxDecoration(
                color: JosiColors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close_rounded,
                color: JosiColors.white,
                size: 70,
              ),
            ),
            const SizedBox(height: 34),
            Text(
              'Booking Cancelled\nSuccessfully!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: JosiColors.ink,
                    fontSize: 22,
                    height: 1.18,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 22),
            Text(
              'Your booking with CRN : #854HG23 has been cancelled successfully.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: JosiColors.softMuted,
                    fontSize: 20,
                    height: 1.28,
                  ),
            ),
            const SizedBox(height: 44),
            SizedBox(
              width: double.infinity,
              height: 62,
              child: ElevatedButton(
                key: const ValueKey<String>('rider-cancel-success-got-it'),
                onPressed: onGotIt,
                style: ElevatedButton.styleFrom(
                  backgroundColor: JosiColors.red,
                  foregroundColor: JosiColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                  textStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: JosiColors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                child: const Text('Got it'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RiderCollectCashCard extends StatelessWidget {
  const _RiderCollectCashCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: JosiColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: JosiColors.line),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 22,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 44, 28, 0),
            child: Column(
              children: <Widget>[
                Container(
                  width: 112,
                  height: 112,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF7F7F7),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      AppAssets.card,
                      width: 60,
                      height: 60,
                      colorFilter: const ColorFilter.mode(
                        JosiColors.red,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 26),
                Text(
                  'Collect Cash',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: JosiColors.ink,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 34),
                const _RideRequestRouteSummary(),
                const SizedBox(height: 28),
                const Divider(color: JosiColors.line),
                const SizedBox(height: 24),
                Row(
                  children: <Widget>[
                    const ProfileAvatar(name: 'Esther Howard', size: 70),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Esther Howard',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  color: JosiColors.ink,
                                  fontSize: 23,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Cash Payment',
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: JosiColors.softMuted,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 34),
              ],
            ),
          ),
          Container(
            height: 74,
            padding: const EdgeInsets.symmetric(horizontal: 28),
            decoration: const BoxDecoration(
              color: JosiColors.red,
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(18),
              ),
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    'Total Amount',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: JosiColors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '\$12.5',
                  maxLines: 1,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: JosiColors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ApplicationSubmittedSheet extends StatelessWidget {
  const _ApplicationSubmittedSheet({required this.onGotIt});

  final VoidCallback onGotIt;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey<String>('rider-submission-sheet'),
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(28, 14, 28, 18),
      decoration: const BoxDecoration(
        color: JosiColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 98,
              height: 4,
              decoration: BoxDecoration(
                color: JosiColors.line,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 30),
            Container(
              width: 78,
              height: 78,
              decoration: const BoxDecoration(
                color: JosiColors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded,
                  color: JosiColors.white, size: 48),
            ),
            const SizedBox(height: 24),
            Text(
              'Application Submitted for\nVerification',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: JosiColors.ink,
                    fontSize: 20,
                    height: 1.18,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 14),
            Text(
              'We will get in touch in 48 Working\nhours. Be ready to for your ride!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: JosiColors.softMuted,
                    fontSize: 14,
                    height: 1.35,
                  ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                key: const ValueKey<String>('rider-submission-got-it'),
                onPressed: onGotIt,
                style: ElevatedButton.styleFrom(
                  backgroundColor: JosiColors.red,
                  foregroundColor: JosiColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                  textStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: JosiColors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                child: const Text('Got it'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RiderDashboardHeader extends StatelessWidget {
  const _RiderDashboardHeader({
    required this.isOnline,
    required this.onToggle,
  });

  final bool isOnline;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: JosiColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: JosiColors.line),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          const Icon(Icons.person_rounded, color: JosiColors.red, size: 28),
          const Spacer(),
          InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: onToggle,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              height: 40,
              padding: const EdgeInsets.fromLTRB(18, 4, 5, 4),
              decoration: BoxDecoration(
                color: isOnline ? JosiColors.red : JosiColors.softMuted,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    isOnline ? 'Online' : 'Offline',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: JosiColors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: JosiColors.ink,
                      shape: BoxShape.circle,
                      border: Border.all(color: JosiColors.white, width: 3),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RiderDashboardMetrics extends StatelessWidget {
  const _RiderDashboardMetrics();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: <Widget>[
        Expanded(
          child: _RiderDashboardMetricCard(
            key: ValueKey<String>('rider-metric-prebooked-card'),
            label: 'Pre - Booked',
            value: '10',
            icon: Icons.calendar_month_rounded,
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: _RiderDashboardMetricCard(
            key: ValueKey<String>('rider-metric-today-earned-card'),
            label: 'Today Earned',
            value: '\$754.00',
            icon: Icons.attach_money_rounded,
          ),
        ),
      ],
    );
  }
}

class _RiderDashboardMetricCard extends StatelessWidget {
  const _RiderDashboardMetricCard({
    required this.label,
    required this.value,
    required this.icon,
    super.key,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 82,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: JosiColors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: JosiColors.red,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: JosiColors.white, size: 21),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: JosiColors.ink,
                        fontSize: 13,
                      ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: JosiColors.ink,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FindingJobsPanel extends StatelessWidget {
  const _FindingJobsPanel({required this.onFindingJobs});

  final VoidCallback onFindingJobs;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      decoration: const BoxDecoration(
        color: JosiColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 22,
            offset: Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 58,
              height: 4,
              decoration: const BoxDecoration(
                color: JosiColors.red,
                borderRadius: BorderRadius.all(Radius.circular(999)),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                key: const ValueKey<String>('rider-finding-jobs-button'),
                onPressed: onFindingJobs,
                style: ElevatedButton.styleFrom(
                  backgroundColor: JosiColors.red,
                  foregroundColor: JosiColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                  textStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: JosiColors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                child: const Text('Finding Jobs'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RideRequestTimer extends StatelessWidget {
  const _RideRequestTimer();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          SizedBox.square(
            dimension: 150,
            child: CircularProgressIndicator(
              value: 0.78,
              strokeWidth: 6,
              strokeCap: StrokeCap.round,
              backgroundColor: JosiColors.white.withValues(alpha: 0.75),
              color: JosiColors.red,
            ),
          ),
          Container(
            width: 132,
            height: 132,
            decoration: const BoxDecoration(
              color: JosiColors.white,
              shape: BoxShape.circle,
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Color(0x12000000),
                  blurRadius: 22,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Icon(Icons.hourglass_bottom_rounded,
                    color: JosiColors.red, size: 32),
                Text(
                  '30',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: JosiColors.red,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                Text(
                  'Seconds',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: JosiColors.softMuted,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RideRequestSheet extends StatelessWidget {
  const _RideRequestSheet({
    required this.trip,
    required this.onDecline,
    required this.onAccept,
  });

  final Trip trip;
  final VoidCallback onDecline;
  final VoidCallback onAccept;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey<String>('rider-ride-request-sheet'),
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(28, 14, 28, 20),
      decoration: const BoxDecoration(
        color: JosiColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 24,
            offset: Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Align(
              child: Container(
                width: 100,
                height: 4,
                decoration: BoxDecoration(
                  color: JosiColors.line,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 26),
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    'Ride Request',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: JosiColors.ink,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
                Text(
                  '5 mins away',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: JosiColors.softMuted,
                        fontSize: 18,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const Divider(color: JosiColors.line),
            const SizedBox(height: 20),
            Row(
              children: <Widget>[
                const ProfileAvatar(name: 'Esther Howard', size: 64),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Esther Howard',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: JosiColors.ink,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_paymentLabel(trip.paymentMethod)} Payment',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: JosiColors.softMuted,
                              fontSize: 18,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            const _RideRequestRouteSummary(),
            const SizedBox(height: 24),
            Row(
              children: <Widget>[
                Expanded(
                  child: SizedBox(
                    height: 62,
                    child: ElevatedButton(
                      key: const ValueKey<String>('rider-ride-request-decline'),
                      onPressed: onDecline,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: JosiColors.surface,
                        foregroundColor: JosiColors.red,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                        textStyle:
                            Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: JosiColors.red,
                                  fontSize: 21,
                                  fontWeight: FontWeight.w800,
                                ),
                      ),
                      child: const Text('Decline'),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: SizedBox(
                    height: 62,
                    child: ElevatedButton(
                      key: const ValueKey<String>('rider-ride-request-accept'),
                      onPressed: onAccept,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: JosiColors.red,
                        foregroundColor: JosiColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                        textStyle:
                            Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: JosiColors.white,
                                  fontSize: 21,
                                  fontWeight: FontWeight.w800,
                                ),
                      ),
                      child: const Text('Accept'),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RideRequestRouteSummary extends StatelessWidget {
  const _RideRequestRouteSummary();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Column(
          children: <Widget>[
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: JosiColors.ink, width: 4),
              ),
              child: Center(
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: const BoxDecoration(
                    color: JosiColors.ink,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            CustomPaint(
              size: const Size(1, 42),
              painter: _VerticalDashedLinePainter(),
            ),
            const Icon(Icons.location_on_rounded,
                color: JosiColors.red, size: 38),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '6391 Elgin St. Celina, Dejawa...',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: JosiColors.ink,
                        fontSize: 19,
                      ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                    decoration: BoxDecoration(
                      color: JosiColors.surface,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '10 mins up',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: JosiColors.softMuted,
                            fontSize: 17,
                          ),
                    ),
                  ),
                ),
                Text(
                  '1901 Thorrridge Cir. Sh...',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: JosiColors.ink,
                        fontSize: 19,
                      ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _VerticalDashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = JosiColors.softMuted
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;
    double y = 4;
    while (y < size.height) {
      canvas.drawLine(Offset(0, y), Offset(0, y + 5), paint);
      y += 10;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RiderDashboardMapBackdrop extends StatelessWidget {
  const _RiderDashboardMapBackdrop();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _RiderDashboardMapPainter(),
      child: const SizedBox.expand(),
    );
  }
}

class _RiderDashboardMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
        Offset.zero & size, Paint()..color = const Color(0xFFF5F6F7));

    final Paint roadPaint = Paint()
      ..color = JosiColors.white
      ..strokeWidth = 13
      ..strokeCap = StrokeCap.round;
    final Paint minorRoadPaint = Paint()
      ..color = const Color(0xFFE7EAEE)
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    final Paint arrowPaint = Paint()
      ..color = const Color(0xFFBFC4CB)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    for (final double x in <double>[0.12, 0.36, 0.60, 0.86]) {
      canvas.drawLine(
        Offset(size.width * x, -size.height * 0.08),
        Offset(size.width * (x - 0.28), size.height * 1.08),
        roadPaint,
      );
    }
    for (final double y in <double>[0.10, 0.28, 0.48, 0.68, 0.88]) {
      canvas.drawLine(
        Offset(-size.width * 0.1, size.height * y),
        Offset(size.width * 1.1, size.height * (y + 0.18)),
        roadPaint,
      );
    }
    for (final double x in <double>[0.24, 0.48, 0.74]) {
      canvas.drawLine(
        Offset(size.width * x, 0),
        Offset(size.width * (x + 0.12), size.height),
        minorRoadPaint,
      );
    }
    for (final double y in <double>[0.20, 0.38, 0.58, 0.78]) {
      canvas.drawLine(
        Offset(0, size.height * y),
        Offset(size.width, size.height * (y - 0.09)),
        minorRoadPaint,
      );
    }

    _drawStreetLabel(canvas, size, 'Reade St', const Offset(0.38, 0.26), 0.34);
    _drawStreetLabel(canvas, size, 'Broadway', const Offset(0.70, 0.18), -1.04);
    _drawStreetLabel(canvas, size, 'Warren St', const Offset(0.22, 0.38), 0.38);
    _drawStreetLabel(canvas, size, 'Park Row', const Offset(0.30, 0.60), -0.2);
    _drawStreetLabel(canvas, size, 'Gold St', const Offset(0.66, 0.78), -0.78);

    for (final Offset point in <Offset>[
      const Offset(0.28, 0.32),
      const Offset(0.54, 0.22),
      const Offset(0.72, 0.40),
      const Offset(0.36, 0.62),
      const Offset(0.66, 0.70),
    ]) {
      final Offset center =
          Offset(size.width * point.dx, size.height * point.dy);
      canvas.drawLine(center.translate(-8, -8), center, arrowPaint);
      canvas.drawLine(center, center.translate(-4, 8), arrowPaint);
    }

    _drawNavigationPulse(canvas, size, const Offset(0.78, 0.58));

    final Rect fadeRect = Offset.zero & size;
    canvas.drawRect(
      fadeRect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Color(0x15FFFFFF),
            Color(0x00FFFFFF),
            Color(0xAAFFFFFF),
          ],
          stops: <double>[0, 0.55, 1],
        ).createShader(fadeRect),
    );
  }

  void _drawStreetLabel(
    Canvas canvas,
    Size size,
    String text,
    Offset offset,
    double rotation,
  ) {
    canvas.save();
    canvas.translate(size.width * offset.dx, size.height * offset.dy);
    canvas.rotate(rotation);
    final TextPainter painter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Color(0xFFB8BCC2),
          fontSize: 22,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, Offset.zero);
    canvas.restore();
  }

  void _drawNavigationPulse(Canvas canvas, Size size, Offset point) {
    final Offset center = Offset(size.width * point.dx, size.height * point.dy);
    canvas.drawCircle(
        center, 54, Paint()..color = JosiColors.red.withValues(alpha: 0.18));
    canvas.drawCircle(center, 31, Paint()..color = JosiColors.red);
    canvas.drawCircle(center, 25, Paint()..color = JosiColors.white);
    canvas.drawCircle(center, 21, Paint()..color = JosiColors.red);
    final Path arrow = Path()
      ..moveTo(center.dx - 8, center.dy - 12)
      ..lineTo(center.dx + 14, center.dy)
      ..lineTo(center.dx - 7, center.dy + 10)
      ..close();
    canvas.drawPath(arrow, Paint()..color = JosiColors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RiderFlowScaffold extends StatelessWidget {
  const _RiderFlowScaffold({
    required this.fallbackRoute,
    required this.child,
    super.key,
    this.appBarTitle,
    this.headline,
    this.subtitle,
    this.bottomLabel,
    this.onBottomPressed,
  });

  final String fallbackRoute;
  final String? appBarTitle;
  final String? headline;
  final String? subtitle;
  final String? bottomLabel;
  final VoidCallback? onBottomPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: JosiColors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 10, 24, 0),
                  child: Row(
                    children: <Widget>[
                      _RiderCircleBackButton(fallbackRoute: fallbackRoute),
                      Expanded(
                        child: Text(
                          appBarTitle ?? '',
                          textAlign: TextAlign.center,
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: JosiColors.ink,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                  ),
                        ),
                      ),
                      const SizedBox(width: 54),
                    ],
                  ),
                ),
                if (headline != null) ...<Widget>[
                  const SizedBox(height: 40),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Text(
                      headline!,
                      textAlign: TextAlign.center,
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: JosiColors.ink,
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                              ),
                    ),
                  ),
                  if (subtitle != null) ...<Widget>[
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 34),
                      child: Text(
                        subtitle!,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: JosiColors.softMuted,
                              fontSize: 17,
                              height: 1.25,
                            ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 42),
                ] else
                  const SizedBox(height: 34),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(30, 0, 30, 24),
                    child: child,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: bottomLabel == null
          ? null
          : _RiderFixedBottomAction(
              label: bottomLabel!,
              onPressed: onBottomPressed,
            ),
    );
  }
}

class _RiderCircleBackButton extends StatelessWidget {
  const _RiderCircleBackButton({
    required this.fallbackRoute,
  });

  final String fallbackRoute;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: JosiColors.white,
      shape: const CircleBorder(),
      elevation: 2.5,
      shadowColor: const Color(0x18000000),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () {
          final GoRouter router = GoRouter.of(context);
          if (router.canPop()) {
            context.pop();
          } else {
            context.go(fallbackRoute);
          }
        },
        child: SizedBox.square(
          dimension: 44,
          child: Center(
            child: SvgPicture.asset(
              AppAssets.arrowLeft,
              width: 19,
              height: 19,
              colorFilter:
                  const ColorFilter.mode(JosiColors.ink, BlendMode.srcIn),
            ),
          ),
        ),
      ),
    );
  }
}

class _RiderFixedBottomAction extends StatelessWidget {
  const _RiderFixedBottomAction({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final String keyLabel = label.toLowerCase().replaceAll(' ', '-');

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: JosiColors.white,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 18,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 14, 24, 14),
          child: SizedBox(
            height: 52,
            child: ElevatedButton(
              key: ValueKey<String>('rider-bottom-action-$keyLabel'),
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: JosiColors.red,
                foregroundColor: JosiColors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999)),
                textStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: JosiColors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              child: Text(label),
            ),
          ),
        ),
      ),
    );
  }
}

class _RiderFormField extends StatelessWidget {
  const _RiderFormField({
    required this.label,
    required this.hintText,
    this.keyboardType,
  });

  final String label;
  final String hintText;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: JosiColors.ink,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: hintText,
          keyboardType: keyboardType,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: JosiColors.softMuted,
                fontSize: 17,
              ),
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            filled: true,
            fillColor: JosiColors.white,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: JosiColors.line),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: JosiColors.red, width: 1.4),
            ),
          ),
        ),
      ],
    );
  }
}

class _RiderPhoneField extends StatelessWidget {
  const _RiderPhoneField();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Phone Number',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: JosiColors.ink,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 58,
          decoration: BoxDecoration(
            color: JosiColors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: JosiColors.line),
          ),
          child: Row(
            children: <Widget>[
              const SizedBox(width: 16),
              Text('+1',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: JosiColors.ink, fontWeight: FontWeight.w700)),
              const SizedBox(width: 4),
              const Icon(Icons.keyboard_arrow_down_rounded,
                  color: JosiColors.red, size: 22),
              Container(
                  width: 1,
                  height: 28,
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  color: JosiColors.line),
              Expanded(
                child: TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'Enter Phone Number',
                    border: InputBorder.none,
                    isCollapsed: true,
                  ),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: JosiColors.ink,
                        fontSize: 17,
                      ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RiderSelectField extends StatelessWidget {
  const _RiderSelectField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: JosiColors.ink,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: value,
          isExpanded: true,
          items: items
              .map((String item) =>
                  DropdownMenuItem<String>(value: item, child: Text(item)))
              .toList(),
          onChanged: onChanged,
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: JosiColors.red, size: 26),
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: JosiColors.softMuted,
                fontSize: 17,
              ),
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            filled: true,
            fillColor: JosiColors.white,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: JosiColors.line),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: JosiColors.red, width: 1.4),
            ),
          ),
        ),
      ],
    );
  }
}

class _UploadRequirement extends StatelessWidget {
  const _UploadRequirement(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
            color: JosiColors.red,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_rounded,
              color: JosiColors.white, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: JosiColors.softMuted,
                  fontSize: 18,
                  height: 1.45,
                ),
          ),
        ),
      ],
    );
  }
}

class _DashedUploadBox extends StatelessWidget {
  const _DashedUploadBox();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 146,
      child: CustomPaint(
        painter: _DashedBorderPainter(),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: const Color(0xFF6A6A6A),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.upload_file_rounded,
                    color: JosiColors.white, size: 34),
              ),
              const SizedBox(height: 14),
              Text(
                'Upload Documents',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: JosiColors.softMuted,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = const Color(0xFF8D8D8D)
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;
    const double dash = 10;
    const double gap = 10;

    double x = 0;
    while (x < size.width) {
      canvas.drawLine(
        Offset(x, 0),
        Offset((x + dash).clamp(0, size.width), 0),
        paint,
      );
      canvas.drawLine(
        Offset(x, size.height),
        Offset((x + dash).clamp(0, size.width), size.height),
        paint,
      );
      x += dash + gap;
    }

    double y = 0;
    while (y < size.height) {
      canvas.drawLine(
        Offset(0, y),
        Offset(0, (y + dash).clamp(0, size.height)),
        paint,
      );
      canvas.drawLine(
        Offset(size.width, y),
        Offset(size.width, (y + dash).clamp(0, size.height)),
        paint,
      );
      y += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _AttachedFilePreview extends StatelessWidget {
  const _AttachedFilePreview({
    required this.title,
    required this.meta,
    required this.sizeLabel,
    required this.icon,
  });

  final String title;
  final String meta;
  final String sizeLabel;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              Container(
                width: 136,
                height: 136,
                decoration: BoxDecoration(
                  color: JosiColors.surface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: JosiColors.red, size: 52),
              ),
              Positioned(
                right: -8,
                top: -8,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: JosiColors.red,
                    shape: BoxShape.circle,
                    border: Border.all(color: JosiColors.white, width: 3),
                  ),
                  child: const Icon(Icons.close_rounded,
                      color: JosiColors.white, size: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: JosiColors.ink,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 4),
          Text.rich(
            TextSpan(
              text: meta,
              children: <InlineSpan>[
                const TextSpan(
                  text: '  -  ',
                  style: TextStyle(color: JosiColors.red),
                ),
                TextSpan(text: sizeLabel),
              ],
            ),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: JosiColors.softMuted,
                  fontSize: 14,
                ),
          ),
        ],
      ),
    );
  }
}

class _RiderCustomerLocationSheet extends StatelessWidget {
  const _RiderCustomerLocationSheet({
    required this.title,
    required this.trip,
    required this.onContinue,
  });

  final String title;
  final Trip trip;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(28, 14, 28, 20),
      decoration: const BoxDecoration(
        color: JosiColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 24,
            offset: Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Align(
              child: Container(
                width: 100,
                height: 4,
                decoration: BoxDecoration(
                  color: JosiColors.line,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 28),
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: JosiColors.ink,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
                Text(
                  '5 mins Away',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: JosiColors.softMuted,
                        fontSize: 17,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(color: JosiColors.line),
            const SizedBox(height: 22),
            Row(
              children: <Widget>[
                const ProfileAvatar(name: 'Esther Howard', size: 62),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Esther Howard',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: JosiColors.ink,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${_paymentLabel(trip.paymentMethod)} Payment',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: JosiColors.softMuted,
                              fontSize: 17,
                            ),
                      ),
                    ],
                  ),
                ),
                _RiderContactButton(
                  icon: Icons.chat_bubble_rounded,
                  onTap: () {},
                ),
                const SizedBox(width: 12),
                _RiderContactButton(
                  icon: Icons.call_rounded,
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 28),
            SizedBox(
              height: 62,
              child: ElevatedButton(
                key: const ValueKey<String>('rider-active-trip-continue'),
                onPressed: onContinue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: JosiColors.red,
                  foregroundColor: JosiColors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999)),
                  textStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: JosiColors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                child: const Text('Continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RiderDestinationPanel extends StatelessWidget {
  const _RiderDestinationPanel({required this.onNavigate});

  final VoidCallback onNavigate;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(28, 14, 28, 20),
      decoration: const BoxDecoration(
        color: JosiColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 24,
            offset: Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Align(
              child: Container(
                width: 100,
                height: 4,
                decoration: BoxDecoration(
                  color: JosiColors.line,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 26),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
              decoration: BoxDecoration(
                color: JosiColors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: JosiColors.line),
              ),
              child: Row(
                children: <Widget>[
                  const Icon(Icons.location_on_rounded,
                      color: JosiColors.red, size: 30),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '1901 Thornridge Cir. Shiloh, Howoi 0802',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: JosiColors.ink,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            SizedBox(
              height: 62,
              child: ElevatedButton(
                key:
                    const ValueKey<String>('rider-navigate-destination-button'),
                onPressed: onNavigate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: JosiColors.red,
                  foregroundColor: JosiColors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999)),
                  textStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: JosiColors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                child: const Text('Navigate to Destination'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RiderArrivedDestinationSheet extends StatelessWidget {
  const _RiderArrivedDestinationSheet({required this.onCollectCash});

  final VoidCallback onCollectCash;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(28, 14, 28, 20),
      decoration: const BoxDecoration(
        color: JosiColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 24,
            offset: Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 100,
              height: 4,
              decoration: BoxDecoration(
                color: JosiColors.line,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 36),
            Container(
              width: 94,
              height: 94,
              decoration: const BoxDecoration(
                color: JosiColors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded,
                  color: JosiColors.white, size: 62),
            ),
            const SizedBox(height: 28),
            Text(
              'Arrived At Customer Location',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: JosiColors.ink,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              '6391 Elgin St. Celina, Delswa...',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: JosiColors.softMuted,
                    fontSize: 18,
                  ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 62,
              child: ElevatedButton(
                key: const ValueKey<String>('rider-collect-cash-button'),
                onPressed: onCollectCash,
                style: ElevatedButton.styleFrom(
                  backgroundColor: JosiColors.red,
                  foregroundColor: JosiColors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999)),
                  textStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: JosiColors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                child: const Text('Collect Cash'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RiderLocateButton extends StatelessWidget {
  const _RiderLocateButton();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: JosiColors.white,
      shape: const CircleBorder(),
      elevation: 8,
      shadowColor: const Color(0x1F000000),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () {},
        child: const SizedBox.square(
          dimension: 58,
          child: Icon(
            Icons.my_location_rounded,
            color: JosiColors.red,
            size: 30,
          ),
        ),
      ),
    );
  }
}

class _RiderContactButton extends StatelessWidget {
  const _RiderContactButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      customBorder: const CircleBorder(),
      onTap: onTap,
      child: Container(
        width: 54,
        height: 54,
        decoration: const BoxDecoration(
          color: JosiColors.redSoft,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: JosiColors.red, size: 26),
      ),
    );
  }
}

class _RiderMapBackdrop extends StatelessWidget {
  const _RiderMapBackdrop();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _RiderMapPainter(),
      child: const SizedBox.expand(),
    );
  }
}

class _RiderMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
        Offset.zero & size, Paint()..color = const Color(0xFFF5F6F7));

    final Paint roadPaint = Paint()
      ..color = JosiColors.white
      ..strokeWidth = 13
      ..strokeCap = StrokeCap.round;
    final Paint minorRoadPaint = Paint()
      ..color = const Color(0xFFE7EAEE)
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    final Paint arrowPaint = Paint()
      ..color = const Color(0xFFBFC4CB)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    for (final double x in <double>[0.10, 0.34, 0.58, 0.84]) {
      canvas.drawLine(
        Offset(size.width * x, -size.height * 0.05),
        Offset(size.width * (x - 0.26), size.height * 1.05),
        roadPaint,
      );
    }
    for (final double y in <double>[0.12, 0.30, 0.48, 0.68, 0.86]) {
      canvas.drawLine(
        Offset(-size.width * 0.1, size.height * y),
        Offset(size.width * 1.1, size.height * (y + 0.18)),
        roadPaint,
      );
    }
    for (final double x in <double>[0.21, 0.47, 0.70]) {
      canvas.drawLine(
        Offset(size.width * x, 0),
        Offset(size.width * (x + 0.10), size.height),
        minorRoadPaint,
      );
    }
    for (final double y in <double>[0.22, 0.38, 0.58, 0.76]) {
      canvas.drawLine(
        Offset(0, size.height * y),
        Offset(size.width, size.height * (y - 0.08)),
        minorRoadPaint,
      );
    }

    _drawStreetLabel(canvas, size, 'Reade St', const Offset(0.36, 0.27), 0.34);
    _drawStreetLabel(canvas, size, 'Broadway', const Offset(0.66, 0.18), -1.02);
    _drawStreetLabel(canvas, size, 'Warren St', const Offset(0.20, 0.39), 0.36);
    _drawStreetLabel(canvas, size, 'Park Row', const Offset(0.28, 0.58), -0.2);

    for (final Offset point in <Offset>[
      const Offset(0.26, 0.34),
      const Offset(0.52, 0.24),
      const Offset(0.70, 0.40),
      const Offset(0.32, 0.62),
    ]) {
      final Offset center =
          Offset(size.width * point.dx, size.height * point.dy);
      canvas.drawLine(center.translate(-8, -8), center, arrowPaint);
      canvas.drawLine(center, center.translate(-4, 8), arrowPaint);
    }

    final Paint routePaint = Paint()
      ..color = const Color(0xFF2D2D2D)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final Path route = Path()
      ..moveTo(size.width * 0.43, size.height * 0.45)
      ..lineTo(size.width * 0.58, size.height * 0.35)
      ..lineTo(size.width * 0.74, size.height * 0.42);
    canvas.drawPath(route, routePaint);
    _drawCar(canvas, size, const Offset(0.38, 0.48));
    _drawCustomerPin(canvas, size, const Offset(0.74, 0.42));

    final Rect fadeRect = Offset.zero & size;
    canvas.drawRect(
      fadeRect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Color(0x30FFFFFF),
            Color(0x00FFFFFF),
            Color(0x99FFFFFF),
          ],
          stops: <double>[0, 0.52, 1],
        ).createShader(fadeRect),
    );
  }

  void _drawStreetLabel(
    Canvas canvas,
    Size size,
    String text,
    Offset offset,
    double rotation,
  ) {
    canvas.save();
    canvas.translate(size.width * offset.dx, size.height * offset.dy);
    canvas.rotate(rotation);
    final TextPainter painter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Color(0xFFB8BCC2),
          fontSize: 22,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, Offset.zero);
    canvas.restore();
  }

  void _drawCustomerPin(Canvas canvas, Size size, Offset point) {
    final Offset center = Offset(size.width * point.dx, size.height * point.dy);
    final Paint redPaint = Paint()..color = JosiColors.red;
    canvas.drawCircle(center.translate(0, 22), 22,
        Paint()..color = JosiColors.red.withValues(alpha: 0.12));
    canvas.drawLine(center, center.translate(0, 46), redPaint..strokeWidth = 4);
    canvas.drawCircle(center, 24, Paint()..color = JosiColors.white);
    canvas.drawCircle(center, 18, redPaint);
    canvas.drawCircle(center, 8, Paint()..color = JosiColors.white);
  }

  void _drawCar(Canvas canvas, Size size, Offset point) {
    final Offset center = Offset(size.width * point.dx, size.height * point.dy);
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-0.70);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-20, 4, 44, 22),
        const Radius.circular(8),
      ),
      Paint()..color = const Color(0x24000000),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-18, -11, 36, 22),
        const Radius.circular(7),
      ),
      Paint()..color = const Color(0xFF222629),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-8, -9, 16, 18),
        const Radius.circular(5),
      ),
      Paint()..color = const Color(0xFF3E454A),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(label,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: JosiColors.muted)),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.titleSmall,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  const _TransactionCard({required this.transaction});

  final WalletTransaction transaction;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: <Widget>[
          Icon(
            transaction.isCredit
                ? Icons.arrow_downward_rounded
                : Icons.arrow_upward_rounded,
            color: transaction.isCredit ? JosiColors.success : JosiColors.red,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(transaction.title,
                    style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 3),
                Text(transaction.subtitle,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: JosiColors.muted)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(transaction.amount,
                  style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 3),
              Text(transaction.status,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: JosiColors.muted)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  const _ProfileMenuItem({
    required this.icon,
    required this.label,
    required this.route,
  });

  final IconData icon;
  final String label;
  final String route;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        onTap: () => context.go(route),
        child: Row(
          children: <Widget>[
            Icon(icon, color: JosiColors.muted),
            const SizedBox(width: 12),
            Expanded(
                child:
                    Text(label, style: Theme.of(context).textTheme.titleSmall)),
            const Icon(Icons.chevron_right_rounded, color: JosiColors.muted),
          ],
        ),
      ),
    );
  }
}

String _paymentLabel(PaymentMethod method) {
  switch (method) {
    case PaymentMethod.cash:
      return 'Cash';
    case PaymentMethod.online:
      return 'Online payment';
    case PaymentMethod.wallet:
      return 'Wallet';
  }
}
