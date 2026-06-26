import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_assets.dart';
import '../../core/constants/app_routes.dart';
import '../../core/constants/map_constants.dart';
import '../../core/location/location_providers.dart';
import '../../core/location/location_service.dart';
import '../../core/map/route_providers.dart';
import '../../core/map/route_service.dart';
import '../../core/mock/josi_models.dart';
import '../../core/providers/app_providers.dart';
import '../../core/services/api_client.dart';
import '../../core/services/profile_photo_picker.dart';
import '../../core/theme/josi_colors.dart';
import '../../core/widgets/app_components.dart';
import '../../core/widgets/josi_google_map.dart';

class RiderHomeScreen extends ConsumerStatefulWidget {
  const RiderHomeScreen({super.key});

  @override
  ConsumerState<RiderHomeScreen> createState() => _RiderHomeScreenState();
}

class _RiderHomeScreenState extends ConsumerState<RiderHomeScreen> {
  static const int _requestTimeoutSeconds = 30;
  static const Duration _jobSearchTick = Duration(milliseconds: 100);
  static const Duration _jobSearchDuration = Duration(milliseconds: 1800);
  static const Duration _notFoundDuration = Duration(milliseconds: 1600);

  bool _isOnline = true;
  _RiderJobSearchState _jobSearchState = _RiderJobSearchState.idle;
  double _jobSearchProgress = 0;
  int _requestSecondsRemaining = _requestTimeoutSeconds;
  Trip? _requestTrip;
  Timer? _jobSearchTimer;
  Timer? _requestTimer;
  Timer? _notFoundTimer;
  bool _isAcceptingRequest = false;
  bool _isDecliningRequest = false;

  @override
  void dispose() {
    _jobSearchTimer?.cancel();
    _requestTimer?.cancel();
    _notFoundTimer?.cancel();
    super.dispose();
  }

  void _prepareRiderLocationSync(LatLng location) {
    // TODO: send to POST /api/v1/rider/location when the API client is ready.
  }

  void _startJobSearch() {
    if (_jobSearchState == _RiderJobSearchState.searching ||
        _jobSearchState == _RiderJobSearchState.request) {
      return;
    }

    _jobSearchTimer?.cancel();
    _notFoundTimer?.cancel();
    ref.invalidate(tripsProvider);
    setState(() {
      _jobSearchState = _RiderJobSearchState.searching;
      _jobSearchProgress = 0;
      _requestTrip = null;
    });

    _jobSearchTimer = Timer.periodic(_jobSearchTick, (Timer timer) {
      final double progress = (_jobSearchProgress +
              (_jobSearchTick.inMilliseconds /
                  _jobSearchDuration.inMilliseconds))
          .clamp(0, 1);
      if (mounted) {
        setState(() => _jobSearchProgress = progress);
      }
      if (progress >= 1) {
        timer.cancel();
        _finishJobSearch();
      }
    });
  }

  void _finishJobSearch() {
    final AsyncValue<List<Trip>> trips = ref.read(tripsProvider);
    if (trips.isLoading && !trips.hasValue) {
      _jobSearchTimer?.cancel();
      _jobSearchTimer = Timer(
        const Duration(milliseconds: 350),
        _finishJobSearch,
      );
      return;
    }

    final Trip? requestTrip = _nextRideRequest(trips.value ?? const []);
    if (requestTrip != null) {
      _showRideRequest(requestTrip);
      return;
    }

    if (!mounted) {
      return;
    }
    setState(() {
      _jobSearchState = _RiderJobSearchState.notFound;
      _jobSearchProgress = 1;
      _requestTrip = null;
    });
    _notFoundTimer?.cancel();
    _notFoundTimer = Timer(_notFoundDuration, () {
      if (!mounted || _jobSearchState != _RiderJobSearchState.notFound) {
        return;
      }
      setState(() {
        _jobSearchState = _RiderJobSearchState.idle;
        _jobSearchProgress = 0;
      });
    });
  }

  void _showRideRequest(Trip trip) {
    _jobSearchTimer?.cancel();
    _notFoundTimer?.cancel();
    _requestTimer?.cancel();
    if (!mounted) {
      return;
    }
    setState(() {
      _jobSearchState = _RiderJobSearchState.request;
      _requestTrip = trip;
      _requestSecondsRemaining = _requestTimeoutSeconds;
      _isAcceptingRequest = false;
      _isDecliningRequest = false;
    });
    _requestTimer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (!mounted || _jobSearchState != _RiderJobSearchState.request) {
        timer.cancel();
        return;
      }
      if (_requestSecondsRemaining <= 1) {
        timer.cancel();
        _declineRideRequest(timedOut: true);
        return;
      }
      setState(() => _requestSecondsRemaining--);
    });
  }

  Future<void> _acceptRideRequest() async {
    final Trip? trip = _requestTrip;
    if (trip == null || _isAcceptingRequest || _isDecliningRequest) {
      return;
    }

    setState(() => _isAcceptingRequest = true);
    try {
      final Trip accepted =
          await ref.read(riderRepositoryProvider).acceptTrip(trip.id);
      ref.invalidate(tripsProvider);
      ref.invalidate(riderTripProvider(trip.id));
      if (!mounted) {
        return;
      }
      _requestTimer?.cancel();
      context.go(AppRoutes.riderActiveTripPath(
        accepted.id.isEmpty ? trip.id : accepted.id,
      ));
    } on ApiException catch (error) {
      if (mounted) {
        setState(() => _isAcceptingRequest = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message)),
        );
      }
    } on Object {
      if (mounted) {
        setState(() => _isAcceptingRequest = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Trip could not be accepted.')),
        );
      }
    }
  }

  Future<void> _declineRideRequest({bool timedOut = false}) async {
    final Trip? trip = _requestTrip;
    if (trip == null || _isDecliningRequest || _isAcceptingRequest) {
      return;
    }

    setState(() => _isDecliningRequest = true);
    try {
      await ref.read(riderRepositoryProvider).declineTrip(trip.id);
      ref.invalidate(tripsProvider);
      ref.invalidate(riderTripProvider(trip.id));
      if (!mounted) {
        return;
      }
      _requestTimer?.cancel();
      setState(() {
        _jobSearchState = _RiderJobSearchState.notFound;
        _jobSearchProgress = 1;
        _requestTrip = null;
        _isDecliningRequest = false;
      });
      if (!timedOut) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ride request declined.')),
        );
      }
      _notFoundTimer?.cancel();
      _notFoundTimer = Timer(_notFoundDuration, () {
        if (!mounted || _jobSearchState != _RiderJobSearchState.notFound) {
          return;
        }
        setState(() {
          _jobSearchState = _RiderJobSearchState.idle;
          _jobSearchProgress = 0;
        });
      });
    } on ApiException catch (error) {
      if (mounted) {
        setState(() => _isDecliningRequest = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message)),
        );
      }
    } on Object {
      if (mounted) {
        setState(() => _isDecliningRequest = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ride request could not be declined.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<Trip>> trips = ref.watch(tripsProvider);
    final List<Trip> tripValues = trips.value ?? const <Trip>[];
    final Trip? requestTrip = _requestTrip;

    return Scaffold(
      key: const ValueKey<String>('rider-home-screen'),
      backgroundColor: JosiColors.white,
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: _RiderDashboardMapBackdrop(
              activeTrip: _jobSearchState == _RiderJobSearchState.request
                  ? requestTrip
                  : null,
              onRiderLocationReady: _prepareRiderLocationSync,
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            top: MediaQuery.paddingOf(context).top + 48,
            child: _RiderDashboardHeader(
              isOnline: _isOnline,
              onToggle: () => setState(() => _isOnline = !_isOnline),
            ),
          ),
          if (_jobSearchState != _RiderJobSearchState.request)
            Positioned(
              left: 20,
              right: 20,
              top: MediaQuery.paddingOf(context).top + 122,
              child: _RiderDashboardMetrics(
                trips: tripValues,
                isLoading: trips.isLoading && !trips.hasValue,
              ),
            ),
          if (_jobSearchState == _RiderJobSearchState.request)
            Positioned(
              left: 0,
              right: 0,
              top: MediaQuery.paddingOf(context).top + 260,
              child: _RideRequestTimer(
                secondsRemaining: _requestSecondsRemaining,
              ),
            ),
          if (trips.hasError && _jobSearchState != _RiderJobSearchState.request)
            Positioned(
              left: 20,
              right: 20,
              top: MediaQuery.paddingOf(context).top + 218,
              child: _RiderInlineMessage(
                message: _riderErrorMessage(
                  trips.error!,
                  'Trips could not load.',
                ),
                icon: Icons.error_outline_rounded,
                color: JosiColors.redDark,
                backgroundColor: const Color(0xFFFFF1F2),
              ),
            ),
          Align(
            alignment: Alignment.bottomCenter,
            child: switch (_jobSearchState) {
              _RiderJobSearchState.searching => _FindingJobsPanel(
                  progress: _jobSearchProgress,
                  status: _RiderJobSearchStatus.searching,
                ),
              _RiderJobSearchState.notFound => const _FindingJobsPanel(
                  progress: 1,
                  status: _RiderJobSearchStatus.notFound,
                ),
              _RiderJobSearchState.request when requestTrip != null =>
                _RideRequestSheet(
                  trip: requestTrip,
                  isAccepting: _isAcceptingRequest,
                  isDeclining: _isDecliningRequest,
                  onDecline: () => _declineRideRequest(),
                  onAccept: _acceptRideRequest,
                ),
              _ => const SizedBox.shrink(),
            },
          ),
        ],
      ),
      floatingActionButton: _jobSearchState == _RiderJobSearchState.idle
          ? FloatingActionButton(
              key: const ValueKey<String>('rider-search-jobs-fab'),
              onPressed: _startJobSearch,
              backgroundColor: JosiColors.red,
              foregroundColor: JosiColors.white,
              child: const Icon(Icons.search_rounded),
            )
          : null,
      bottomNavigationBar:
          const AppBottomNav(role: AppNavRole.rider, selectedTab: 'home'),
    );
  }
}

enum _RiderJobSearchState {
  idle,
  searching,
  notFound,
  request,
}

enum _RiderJobSearchStatus {
  searching,
  notFound,
}

class RiderLocationAccessScreen extends ConsumerStatefulWidget {
  const RiderLocationAccessScreen({super.key});

  @override
  ConsumerState<RiderLocationAccessScreen> createState() =>
      _RiderLocationAccessScreenState();
}

class _RiderLocationAccessScreenState
    extends ConsumerState<RiderLocationAccessScreen> {
  bool _isLocating = false;

  Future<void> _allowLocationAccess() async {
    if (_isLocating) {
      return;
    }

    setState(() {
      _isLocating = true;
    });

    try {
      await ref.read(locationServiceProvider).currentPosition();
      if (!mounted) {
        return;
      }
      context.go(AppRoutes.riderHome);
    } on LocationFailure catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLocating = false;
        });
      }
    }
  }

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
                      onPressed: _isLocating ? null : _allowLocationAccess,
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
                      child: _isLocating
                          ? const SizedBox.square(
                              dimension: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.4,
                                color: JosiColors.white,
                              ),
                            )
                          : const Text('Allow Location Access'),
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

class RiderApplicationStatusScreen extends ConsumerStatefulWidget {
  const RiderApplicationStatusScreen({super.key});

  @override
  ConsumerState<RiderApplicationStatusScreen> createState() =>
      _RiderApplicationStatusScreenState();
}

class _RiderApplicationStatusScreenState
    extends ConsumerState<RiderApplicationStatusScreen> {
  bool _isSubmitting = false;
  String? _submitError;

  Future<void> _submit() async {
    if (_isSubmitting) {
      return;
    }

    setState(() {
      _isSubmitting = true;
      _submitError = null;
    });

    try {
      await ref.read(riderRepositoryProvider).submitOnboarding();
      ref.invalidate(riderOnboardingProvider);
      if (!mounted) {
        return;
      }
      _showSubmissionSheet(context);
    } on Object catch (error) {
      if (mounted) {
        setState(() => _submitError = _riderErrorMessage(
              error,
              'Unable to submit rider account information.',
            ));
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final AuthSession session = ref.watch(authControllerProvider);
    final AsyncValue<RiderOnboarding> onboarding =
        ref.watch(riderOnboardingProvider);
    final String greetingName = session.user?.greetingName ?? 'there';

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
                  'Welcome, $greetingName',
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
                    child: onboarding.when(
                      data: (RiderOnboarding value) =>
                          _RiderApplicationStatusBody(
                        onboarding: value,
                        submitError: _submitError,
                      ),
                      error: (Object error, StackTrace stackTrace) =>
                          ErrorState(
                        title: 'Account setup unavailable',
                        message: _riderErrorMessage(
                          error,
                          'Rider account setup could not load.',
                        ),
                      ),
                      loading: () => const SizedBox(
                        height: 220,
                        child: LoadingState(label: 'Loading account setup'),
                      ),
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
        isLoading: _isSubmitting,
        onPressed: onboarding.isLoading ? null : _submit,
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

class _RiderApplicationStatusBody extends StatelessWidget {
  const _RiderApplicationStatusBody({
    required this.onboarding,
    this.submitError,
  });

  final RiderOnboarding onboarding;
  final String? submitError;

  @override
  Widget build(BuildContext context) {
    final List<Widget> missingSteps = <Widget>[
      if (!onboarding.profilePictureComplete)
        _RiderStepTile(
          label: 'Profile Picture',
          onTap: () => context.go(AppRoutes.riderProfilePicture),
        ),
      if (!onboarding.bankAccountComplete)
        _RiderStepTile(
          label: 'Bank Account Details',
          onTap: () => context.go(AppRoutes.riderBankAccountDetails),
        ),
      if (!onboarding.ridingDetailsComplete)
        _RiderStepTile(
          label: 'Riding Details',
          onTap: () => context.go(AppRoutes.riderVehicleSetup),
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (submitError != null) ...<Widget>[
          _RiderInlineMessage(
            message: submitError!,
            icon: Icons.error_outline_rounded,
            color: JosiColors.redDark,
            backgroundColor: const Color(0xFFFFF1F2),
          ),
          const SizedBox(height: 16),
        ],
        if (missingSteps.isNotEmpty) ...<Widget>[
          Text(
            'Required Steps',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: JosiColors.ink,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 14),
          for (int index = 0; index < missingSteps.length; index++) ...<Widget>[
            missingSteps[index],
            if (index != missingSteps.length - 1) const SizedBox(height: 12),
          ],
        ] else ...<Widget>[
          _RiderInlineMessage(
            message: onboarding.isSubmitted
                ? 'Your rider account information has been submitted.'
                : 'All rider account sections are complete. Submit when ready.',
            icon: onboarding.isSubmitted
                ? Icons.check_circle_outline_rounded
                : Icons.info_outline_rounded,
            color: onboarding.isSubmitted
                ? JosiColors.success
                : JosiColors.warning,
            backgroundColor: onboarding.isSubmitted
                ? JosiColors.successSoft
                : JosiColors.warningSoft,
          ),
          const SizedBox(height: 18),
          _RiderOnboardingSummary(onboarding: onboarding),
        ],
      ],
    );
  }
}

class _RiderOnboardingSummary extends StatelessWidget {
  const _RiderOnboardingSummary({required this.onboarding});

  final RiderOnboarding onboarding;

  @override
  Widget build(BuildContext context) {
    final RiderProfile? profile = onboarding.profile;
    final RiderBankAccount? bank = onboarding.bankAccount;
    final Vehicle? vehicle = onboarding.ridingDetails;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            'Account Information',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: JosiColors.ink,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 12),
          _SummaryRow(
            label: 'Profile picture',
            value: profile?.profilePhoto ?? 'Added',
          ),
          _SummaryRow(
            label: 'Bank',
            value: bank?.bankName ?? profile?.bankName ?? 'Added',
          ),
          _SummaryRow(
            label: 'Account name',
            value: bank?.accountName ?? profile?.bankAccountName ?? 'Added',
          ),
          _SummaryRow(
            label: 'Riding details',
            value: vehicle == null
                ? 'Added'
                : <String>[vehicle.brand, vehicle.model]
                    .where((String value) => value.trim().isNotEmpty)
                    .join(' '),
          ),
          if (vehicle?.plateNumber.trim().isNotEmpty ?? false)
            _SummaryRow(label: 'Plate number', value: vehicle!.plateNumber),
        ],
      ),
    );
  }
}

class _RiderInlineMessage extends StatelessWidget {
  const _RiderInlineMessage({
    required this.message,
    required this.icon,
    required this.color,
    required this.backgroundColor,
  });

  final String message;
  final IconData icon;
  final Color color;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, color: color, size: 21),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: color,
                    fontSize: 14,
                    height: 1.35,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class RiderProfileSetupScreen extends ConsumerStatefulWidget {
  const RiderProfileSetupScreen({
    super.key,
    this.isUpdate = false,
  });

  final bool isUpdate;

  @override
  ConsumerState<RiderProfileSetupScreen> createState() =>
      _RiderProfileSetupScreenState();
}

class _RiderProfileSetupScreenState
    extends ConsumerState<RiderProfileSetupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _profilePhotoController = TextEditingController();
  String _gender = 'Select';
  String _city = 'Abuja, FCT';
  bool _hydrated = false;
  bool _saving = false;
  Map<String, String> _errors = const <String, String>{};
  String? _message;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _profilePhotoController.dispose();
    super.dispose();
  }

  void _hydrate(RiderOnboarding onboarding, JosiUser? user) {
    if (_hydrated) {
      return;
    }

    final RiderProfile? profile = onboarding.profile;
    final String? profileName = _cleanPendingValue(profile?.fullName);
    _nameController.text = profileName == null || profileName == 'Rider'
        ? user?.displayName ?? profileName ?? ''
        : profileName;
    _emailController.text = user?.email ?? '';
    _phoneController.text =
        _cleanPendingValue(profile?.phone) ?? user?.phone ?? '';
    _addressController.text = _cleanPendingValue(profile?.address) ?? '';
    _profilePhotoController.text = profile?.profilePhoto ?? '';
    _gender = _genderLabel(profile?.gender);
    _city = _cityLabel(profile?.city, profile?.state);
    _hydrated = true;
  }

  Future<void> _submit() async {
    if (_saving) {
      return;
    }

    final String fullName = _nameController.text.trim();
    final String phone = _phoneController.text.trim();
    final JosiUser? user = ref.read(authControllerProvider).user;
    final String submittedFullName =
        fullName.isNotEmpty ? fullName : user?.displayName ?? 'Rider';
    final String submittedPhone = phone.isNotEmpty ? phone : user?.phone ?? '';
    final Map<String, String> errors = <String, String>{};
    if (widget.isUpdate && fullName.isEmpty) {
      errors['name'] = 'Name is required.';
    }
    if (widget.isUpdate && phone.isEmpty) {
      errors['phone'] = 'Phone number is required.';
    }

    setState(() {
      _errors = errors;
      _message = null;
    });
    if (errors.isNotEmpty) {
      return;
    }

    setState(() => _saving = true);
    try {
      await ref.read(riderRepositoryProvider).updateProfile(
            fullName: submittedFullName,
            phone: submittedPhone,
            gender: _gender,
            address: _addressController.text.trim(),
            city: _cityNameFromLabel(_city),
            state: _stateFromLabel(_city),
            profilePhoto: _profilePhotoController.text.trim(),
          );
      ref
        ..invalidate(riderOnboardingProvider)
        ..invalidate(riderProfileProvider)
        ..invalidate(currentRiderProvider);
      if (mounted) {
        context.go(
          widget.isUpdate
              ? AppRoutes.riderProfile
              : AppRoutes.riderProfilePicture,
        );
      }
    } on Object catch (error) {
      if (mounted) {
        setState(() {
          _message = _riderErrorMessage(error, 'Unable to save profile.');
          _errors = _riderFieldErrors(error);
        });
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isUpdate = widget.isUpdate;
    final AsyncValue<RiderOnboarding> onboarding =
        ref.watch(riderOnboardingProvider);
    final JosiUser? user = ref.watch(authControllerProvider).user;

    return _RiderFlowScaffold(
      key: const ValueKey<String>('rider-profile-setup-screen'),
      fallbackRoute:
          isUpdate ? AppRoutes.riderProfile : AppRoutes.riderApplicationStatus,
      appBarTitle: isUpdate ? 'Your profile' : null,
      headline: isUpdate ? null : 'Complete Your Profile',
      subtitle: isUpdate
          ? null
          : "Don't worry, only you can see your personal data. No one else will be able to see it.",
      bottomLabel: isUpdate ? 'Save changes' : 'Continue',
      bottomLoading: _saving,
      onBottomPressed: _submit,
      child: onboarding.when(
        data: (RiderOnboarding value) {
          _hydrate(value, user);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              if (_message != null) ...<Widget>[
                _RiderInlineMessage(
                  message: _message!,
                  icon: Icons.error_outline_rounded,
                  color: JosiColors.redDark,
                  backgroundColor: const Color(0xFFFFF1F2),
                ),
                const SizedBox(height: 16),
              ],
              if (isUpdate) ...<Widget>[
                _RiderFormField(
                  label: 'Name',
                  hintText: 'Jenny Wilson',
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  errorText: _errors['name'] ?? _errors['first_name'],
                ),
                const SizedBox(height: 14),
                _RiderFormField(
                  label: 'Email',
                  hintText: 'example@gmail.com',
                  controller: _emailController,
                  readOnly: true,
                ),
                const SizedBox(height: 14),
                _RiderFormField(
                  label: 'Phone Number',
                  hintText: '+234 802 345 6789',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  errorText: _errors['phone'],
                ),
                const SizedBox(height: 14),
              ],
              _RiderFormField(
                label: 'Address',
                hintText: '22 Adetokunbo Ademola Crescent',
                controller: _addressController,
                textInputAction: TextInputAction.next,
                errorText: _errors['address'],
              ),
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
                  'Abuja, FCT',
                  'Lagos, Lagos',
                  'Port Harcourt, Rivers',
                  'Other',
                ],
                onChanged: (String? value) =>
                    setState(() => _city = value ?? _city),
              ),
              if (isUpdate) ...<Widget>[
                const SizedBox(height: 22),
                const Divider(color: JosiColors.line),
                const SizedBox(height: 22),
                _RiderProfilePictureFields(
                  controller: _profilePhotoController,
                  errorText: _errors['profile_photo'],
                ),
              ],
            ],
          );
        },
        error: (Object error, StackTrace stackTrace) => ErrorState(
          title: 'Profile unavailable',
          message: _riderErrorMessage(
            error,
            'Rider profile could not load.',
          ),
        ),
        loading: () => const SizedBox(
          height: 220,
          child: LoadingState(label: 'Loading profile'),
        ),
      ),
    );
  }
}

class RiderProfilePictureScreen extends ConsumerStatefulWidget {
  const RiderProfilePictureScreen({super.key});

  @override
  ConsumerState<RiderProfilePictureScreen> createState() =>
      _RiderProfilePictureScreenState();
}

class _RiderProfilePictureScreenState
    extends ConsumerState<RiderProfilePictureScreen> {
  final TextEditingController _profilePhotoController = TextEditingController();
  bool _hydrated = false;
  bool _saving = false;
  String? _errorText;
  String? _message;

  @override
  void dispose() {
    _profilePhotoController.dispose();
    super.dispose();
  }

  void _hydrate(RiderOnboarding onboarding) {
    if (_hydrated) {
      return;
    }

    _profilePhotoController.text = onboarding.profile?.profilePhoto ?? '';
    _hydrated = true;
  }

  void _showPhotoSourceSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: JosiColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      ),
      builder: (BuildContext sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: JosiColors.line,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Profile Photo',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: JosiColors.ink,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 10),
                _PhotoSourceTile(
                  key: const ValueKey<String>('rider-profile-photo-camera'),
                  icon: Icons.photo_camera_outlined,
                  label: 'Take a selfie',
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _pickProfilePhoto(ProfilePhotoSource.camera);
                  },
                ),
                const SizedBox(height: 8),
                _PhotoSourceTile(
                  key: const ValueKey<String>('rider-profile-photo-gallery'),
                  icon: Icons.photo_library_outlined,
                  label: 'Choose from gallery',
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _pickProfilePhoto(ProfilePhotoSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickProfilePhoto(ProfilePhotoSource source) async {
    if (_saving) {
      return;
    }

    setState(() {
      _errorText = null;
      _message = null;
    });

    try {
      final String? profilePhoto =
          await ref.read(profilePhotoPickerProvider).pick(source);
      if (!mounted || profilePhoto == null || profilePhoto.trim().isEmpty) {
        return;
      }

      setState(() => _profilePhotoController.text = profilePhoto.trim());
    } on Object {
      if (!mounted) {
        return;
      }
      setState(() {
        _message = source == ProfilePhotoSource.camera
            ? 'Unable to open the camera. Please try again.'
            : 'Unable to open the photo gallery. Please try again.';
      });
    }
  }

  Future<void> _submit() async {
    if (_saving) {
      return;
    }

    final String profilePhoto = _profilePhotoController.text.trim();
    if (profilePhoto.isEmpty) {
      setState(() => _errorText = 'Take a selfie or choose a photo.');
      return;
    }

    setState(() {
      _saving = true;
      _errorText = null;
      _message = null;
    });

    try {
      await ref
          .read(riderRepositoryProvider)
          .saveProfilePicture(profilePhoto: profilePhoto);
      ref.invalidate(riderOnboardingProvider);
      if (mounted) {
        context.go(AppRoutes.riderBankAccountDetails);
      }
    } on Object catch (error) {
      if (mounted) {
        setState(() => _message = _riderErrorMessage(
              error,
              'Unable to save profile picture.',
            ));
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<RiderOnboarding> onboarding =
        ref.watch(riderOnboardingProvider);

    return _RiderFlowScaffold(
      key: const ValueKey<String>('rider-profile-picture-screen'),
      fallbackRoute: AppRoutes.riderApplicationStatus,
      backUsesFallback: true,
      appBarTitle: 'Profile Picture',
      bottomLabel: 'Continue',
      bottomLoading: _saving,
      onBottomPressed: _submit,
      child: onboarding.when(
        data: (RiderOnboarding value) {
          _hydrate(value);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              if (_message != null) ...<Widget>[
                _RiderInlineMessage(
                  message: _message!,
                  icon: Icons.error_outline_rounded,
                  color: JosiColors.redDark,
                  backgroundColor: const Color(0xFFFFF1F2),
                ),
                const SizedBox(height: 16),
              ],
              _RiderProfilePictureFields(
                controller: _profilePhotoController,
                selectedPhoto: _profilePhotoController.text.trim(),
                onOpenPicker: _showPhotoSourceSheet,
                errorText: _errorText,
              ),
            ],
          );
        },
        error: (Object error, StackTrace stackTrace) => ErrorState(
          title: 'Profile picture unavailable',
          message: _riderErrorMessage(
            error,
            'Profile picture setup could not load.',
          ),
        ),
        loading: () => const SizedBox(
          height: 220,
          child: LoadingState(label: 'Loading profile picture'),
        ),
      ),
    );
  }
}

class _RiderProfilePictureFields extends StatelessWidget {
  const _RiderProfilePictureFields({
    this.controller,
    this.selectedPhoto,
    this.onOpenPicker,
    this.errorText,
  });

  final TextEditingController? controller;
  final String? selectedPhoto;
  final VoidCallback? onOpenPicker;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const _UploadRequirement('Please Upload a Clear Selfie'),
        const SizedBox(height: 16),
        const _UploadRequirement(
            'The selfie should have the applicant face alone'),
        const SizedBox(height: 16),
        const _UploadRequirement('Use a JPEG or PNG photo'),
        const SizedBox(height: 26),
        const Divider(color: JosiColors.line),
        const SizedBox(height: 28),
        const Text(
          'Profile Picture',
          style: TextStyle(
            color: JosiColors.ink,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 16),
        if (onOpenPicker != null)
          _ProfilePhotoUploadBox(
            selectedPhoto: selectedPhoto ?? controller?.text.trim() ?? '',
            errorText: errorText,
            onTap: onOpenPicker!,
          )
        else
          const _DashedUploadBox(),
        const SizedBox(height: 18),
        if (onOpenPicker != null)
          const SizedBox.shrink()
        else if (controller == null)
          const _AttachedFilePreview(
            title: 'Profile',
            meta: 'JPG',
            sizeLabel: '250 kb',
            icon: Icons.person_rounded,
          )
        else
          _RiderFormField(
            label: 'Profile Photo URL or File Path',
            hintText: 'uploads/riders/selfie.jpg',
            controller: controller,
            textInputAction: TextInputAction.done,
            errorText: errorText,
          ),
      ],
    );
  }
}

class RiderBankAccountDetailsScreen extends ConsumerStatefulWidget {
  const RiderBankAccountDetailsScreen({
    super.key,
    this.isUpdate = false,
  });

  final bool isUpdate;

  @override
  ConsumerState<RiderBankAccountDetailsScreen> createState() =>
      _RiderBankAccountDetailsScreenState();
}

class _RiderBankAccountDetailsScreenState
    extends ConsumerState<RiderBankAccountDetailsScreen> {
  final TextEditingController _accountNumberController =
      TextEditingController();
  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _accountNameController = TextEditingController();
  bool _hydrated = false;
  bool _saving = false;
  Map<String, String> _errors = const <String, String>{};
  String? _message;

  @override
  void dispose() {
    _accountNumberController.dispose();
    _bankNameController.dispose();
    _accountNameController.dispose();
    super.dispose();
  }

  void _hydrate(RiderOnboarding onboarding) {
    if (_hydrated) {
      return;
    }

    final RiderBankAccount? bank = onboarding.bankAccount;
    _accountNumberController.text = bank?.accountNumber ?? '';
    _bankNameController.text = bank?.bankName ?? '';
    _accountNameController.text = bank?.accountName ?? '';
    _hydrated = true;
  }

  Future<void> _submit() async {
    if (_saving) {
      return;
    }

    final String accountNumber = _accountNumberController.text.trim();
    final String bankName = _bankNameController.text.trim();
    final String accountName = _accountNameController.text.trim();
    final Map<String, String> errors = <String, String>{};

    if (accountNumber.isEmpty) {
      errors['account_number'] = 'Account number is required.';
    }
    if (bankName.isEmpty) {
      errors['bank_name'] = 'Bank name is required.';
    }
    if (accountName.isEmpty) {
      errors['account_name'] = 'Account name is required.';
    }

    setState(() {
      _errors = errors;
      _message = null;
    });
    if (errors.isNotEmpty) {
      return;
    }

    setState(() => _saving = true);
    try {
      await ref.read(riderRepositoryProvider).saveBankAccount(
            accountNumber: accountNumber,
            bankName: bankName,
            accountName: accountName,
          );
      ref.invalidate(riderOnboardingProvider);
      if (mounted) {
        context.go(widget.isUpdate
            ? AppRoutes.riderProfile
            : AppRoutes.riderVehicleSetup);
      }
    } on Object catch (error) {
      if (mounted) {
        setState(() {
          _message = _riderErrorMessage(
            error,
            'Unable to save bank account details.',
          );
          _errors = _riderFieldErrors(error);
        });
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isUpdate = widget.isUpdate;
    final AsyncValue<RiderOnboarding> onboarding =
        ref.watch(riderOnboardingProvider);

    return _RiderFlowScaffold(
      key: const ValueKey<String>('rider-bank-account-details-screen'),
      fallbackRoute:
          isUpdate ? AppRoutes.riderProfile : AppRoutes.riderProfilePicture,
      appBarTitle: 'Bank Account Details',
      bottomLabel: isUpdate ? 'Save changes' : 'Continue',
      bottomLoading: _saving,
      onBottomPressed: _submit,
      child: onboarding.when(
        data: (RiderOnboarding value) {
          _hydrate(value);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              if (_message != null) ...<Widget>[
                _RiderInlineMessage(
                  message: _message!,
                  icon: Icons.error_outline_rounded,
                  color: JosiColors.redDark,
                  backgroundColor: const Color(0xFFFFF1F2),
                ),
                const SizedBox(height: 16),
              ],
              _RiderFormField(
                label: 'Account Number',
                hintText: '0123456789',
                controller: _accountNumberController,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                errorText: _errors['account_number'],
              ),
              const SizedBox(height: 14),
              _RiderFormField(
                label: 'Bank Name',
                hintText: 'Josi Microfinance Bank',
                controller: _bankNameController,
                textInputAction: TextInputAction.next,
                errorText: _errors['bank_name'],
              ),
              const SizedBox(height: 14),
              _RiderFormField(
                label: 'Account Name',
                hintText: 'Jenny Wilson',
                controller: _accountNameController,
                textInputAction: TextInputAction.done,
                errorText: _errors['account_name'],
              ),
            ],
          );
        },
        error: (Object error, StackTrace stackTrace) => ErrorState(
          title: 'Bank account unavailable',
          message: _riderErrorMessage(
            error,
            'Bank account setup could not load.',
          ),
        ),
        loading: () => const SizedBox(
          height: 220,
          child: LoadingState(label: 'Loading bank details'),
        ),
      ),
    );
  }
}

class RiderVehicleSetupScreen extends ConsumerStatefulWidget {
  const RiderVehicleSetupScreen({
    super.key,
    this.isUpdate = false,
  });

  final bool isUpdate;

  @override
  ConsumerState<RiderVehicleSetupScreen> createState() =>
      _RiderVehicleSetupScreenState();
}

class _RiderVehicleSetupScreenState
    extends ConsumerState<RiderVehicleSetupScreen> {
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  final TextEditingController _plateNumberController = TextEditingController();
  final TextEditingController _registrationNumberController =
      TextEditingController();
  String _vehicleType = 'Bike';
  String _city = 'Abuja, FCT';
  bool _confirmed = true;
  bool _hydrated = false;
  bool _saving = false;
  Map<String, String> _errors = const <String, String>{};
  String? _message;

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _colorController.dispose();
    _plateNumberController.dispose();
    _registrationNumberController.dispose();
    super.dispose();
  }

  void _hydrate(RiderOnboarding onboarding) {
    if (_hydrated) {
      return;
    }

    final Vehicle? vehicle = onboarding.ridingDetails;
    if (vehicle != null) {
      _vehicleType = _vehicleTypeLabel(vehicle.type);
      _brandController.text = vehicle.brand;
      _modelController.text = vehicle.model;
      _colorController.text = vehicle.color;
      _plateNumberController.text = vehicle.plateNumber;
      _registrationNumberController.text = vehicle.registrationNumber;
    }

    final RiderProfile? profile = onboarding.profile;
    _city = _cityLabel(profile?.city, profile?.state);
    _hydrated = true;
  }

  Future<void> _submit() async {
    if (_saving) {
      return;
    }

    final String brand = _brandController.text.trim();
    final String model = _modelController.text.trim();
    final String color = _colorController.text.trim();
    final String plateNumber = _plateNumberController.text.trim();
    final String registrationNumber = _registrationNumberController.text.trim();
    final Map<String, String> errors = <String, String>{};

    if (brand.isEmpty) {
      errors['brand'] = 'Vehicle brand is required.';
    }
    if (model.isEmpty) {
      errors['model'] = 'Vehicle model is required.';
    }
    if (color.isEmpty) {
      errors['color'] = 'Vehicle color is required.';
    }
    if (plateNumber.isEmpty) {
      errors['plate_number'] = 'Plate number is required.';
    }
    if (registrationNumber.isEmpty) {
      errors['registration_number'] = 'Registration number is required.';
    }

    setState(() {
      _errors = errors;
      _message =
          _confirmed ? null : 'Confirm that these riding details are correct.';
    });
    if (errors.isNotEmpty || !_confirmed) {
      return;
    }

    setState(() => _saving = true);
    try {
      await ref.read(riderRepositoryProvider).saveRidingDetails(
            vehicleType: _vehicleTypeApiValue(_vehicleType),
            brand: brand,
            model: model,
            color: color,
            plateNumber: plateNumber,
            registrationNumber: registrationNumber,
            city: _cityNameFromLabel(_city),
            state: _stateFromLabel(_city),
          );
      ref.invalidate(riderOnboardingProvider);
      if (mounted) {
        context.go(widget.isUpdate
            ? AppRoutes.riderProfile
            : AppRoutes.riderApplicationStatus);
      }
    } on Object catch (error) {
      if (mounted) {
        setState(() {
          _message = _riderErrorMessage(
            error,
            'Unable to save riding details.',
          );
          _errors = _riderFieldErrors(error);
        });
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isUpdate = widget.isUpdate;
    final AsyncValue<RiderOnboarding> onboarding =
        ref.watch(riderOnboardingProvider);

    return _RiderFlowScaffold(
      key: const ValueKey<String>('rider-vehicle-setup-screen'),
      fallbackRoute:
          isUpdate ? AppRoutes.riderProfile : AppRoutes.riderApplicationStatus,
      backUsesFallback: !isUpdate,
      appBarTitle: isUpdate ? 'Riding Details' : null,
      headline: isUpdate ? null : 'Complete Your Riding Details',
      subtitle: isUpdate
          ? null
          : "Don't worry, only you can see your riding data. No one else will be able to see it.",
      bottomLabel: isUpdate ? 'Save changes' : 'Continue',
      bottomLoading: _saving,
      onBottomPressed: _submit,
      child: onboarding.when(
        data: (RiderOnboarding value) {
          _hydrate(value);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              if (_message != null) ...<Widget>[
                _RiderInlineMessage(
                  message: _message!,
                  icon: Icons.error_outline_rounded,
                  color: JosiColors.redDark,
                  backgroundColor: const Color(0xFFFFF1F2),
                ),
                const SizedBox(height: 16),
              ],
              _RiderSelectField(
                label: 'Vehicle Type',
                value: _vehicleType,
                items: const <String>[
                  'Bike',
                  'Motorcycle',
                  'Car',
                  'Tricycle',
                  'Van',
                ],
                onChanged: (String? value) =>
                    setState(() => _vehicleType = value ?? _vehicleType),
              ),
              const SizedBox(height: 14),
              _RiderFormField(
                label: 'Vehicle Brand',
                hintText: 'Toyota',
                controller: _brandController,
                textInputAction: TextInputAction.next,
                errorText: _errors['brand'],
              ),
              const SizedBox(height: 14),
              _RiderFormField(
                label: 'Vehicle Model',
                hintText: 'Corolla',
                controller: _modelController,
                textInputAction: TextInputAction.next,
                errorText: _errors['model'],
              ),
              const SizedBox(height: 14),
              _RiderFormField(
                label: 'Vehicle Color',
                hintText: 'White',
                controller: _colorController,
                textInputAction: TextInputAction.next,
                errorText: _errors['color'],
              ),
              const SizedBox(height: 14),
              _RiderFormField(
                label: 'Plate Number',
                hintText: 'ABC 482 JK',
                controller: _plateNumberController,
                textInputAction: TextInputAction.next,
                errorText: _errors['plate_number'],
              ),
              const SizedBox(height: 14),
              _RiderFormField(
                label: 'Registration Number',
                hintText: 'REG-2408-JR',
                controller: _registrationNumberController,
                textInputAction: TextInputAction.next,
                errorText: _errors['registration_number'],
              ),
              const SizedBox(height: 14),
              _RiderSelectField(
                label: 'City You Ride In',
                value: _city,
                items: const <String>[
                  'Abuja, FCT',
                  'Lagos, Lagos',
                  'Port Harcourt, Rivers',
                  'Other',
                ],
                onChanged: (String? value) =>
                    setState(() => _city = value ?? _city),
              ),
              if (!isUpdate) ...<Widget>[
                const SizedBox(height: 22),
                InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => setState(() => _confirmed = !_confirmed),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: _confirmed ? JosiColors.red : JosiColors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: _confirmed
                                  ? JosiColors.red
                                  : JosiColors.line),
                        ),
                        child: _confirmed
                            ? const Icon(Icons.check_rounded,
                                color: JosiColors.white, size: 24)
                            : null,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            text: 'By Accept, you confirm these ',
                            children: <InlineSpan>[
                              TextSpan(
                                text: 'Riding Details',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      color: JosiColors.red,
                                      decoration: TextDecoration.underline,
                                      decorationColor: JosiColors.red,
                                    ),
                              ),
                              const TextSpan(text: ' are correct.'),
                            ],
                          ),
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
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
            ],
          );
        },
        error: (Object error, StackTrace stackTrace) => ErrorState(
          title: 'Riding details unavailable',
          message: _riderErrorMessage(
            error,
            'Riding details setup could not load.',
          ),
        ),
        loading: () => const SizedBox(
          height: 220,
          child: LoadingState(label: 'Loading riding details'),
        ),
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

class RiderTripRequestDetailScreen extends ConsumerStatefulWidget {
  const RiderTripRequestDetailScreen({
    required this.tripId,
    super.key,
  });

  final String tripId;

  @override
  ConsumerState<RiderTripRequestDetailScreen> createState() =>
      _RiderTripRequestDetailScreenState();
}

class _RiderTripRequestDetailScreenState
    extends ConsumerState<RiderTripRequestDetailScreen> {
  bool _isAccepting = false;

  Future<void> _acceptTrip(Trip trip) async {
    setState(() => _isAccepting = true);
    try {
      await ref.read(riderRepositoryProvider).acceptTrip(trip.id);
      if (!mounted) {
        return;
      }
      ref.invalidate(tripsProvider);
      ref.invalidate(riderTripProvider(trip.id));
      context.go(AppRoutes.riderActiveTripPath(trip.id));
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } on Object {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Trip could not be accepted.')),
      );
    } finally {
      if (mounted) {
        setState(() => _isAccepting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<Trip> trip = ref.watch(riderTripProvider(widget.tripId));

    return AppScaffold(
      title: 'Trip request',
      subtitle: widget.tripId,
      child: AppScreenBody(
        children: <Widget>[
          trip.when(
            data: (Trip trip) {
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
                    isLoading: _isAccepting,
                    onPressed: () => _acceptTrip(trip),
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

class RiderActiveTripScreen extends ConsumerStatefulWidget {
  const RiderActiveTripScreen({
    required this.tripId,
    super.key,
  });

  final String tripId;

  @override
  ConsumerState<RiderActiveTripScreen> createState() =>
      _RiderActiveTripScreenState();
}

class _RiderActiveTripScreenState extends ConsumerState<RiderActiveTripScreen> {
  int _stage = 0;
  bool _isMarkingArrived = false;

  Future<void> _markArrivedAtPickup(Trip trip) async {
    setState(() => _isMarkingArrived = true);
    try {
      await ref.read(riderRepositoryProvider).markArrivedAtPickup(trip.id);
      if (!mounted) {
        return;
      }
      ref.invalidate(tripsProvider);
      ref.invalidate(riderTripProvider(trip.id));
      setState(() => _stage = 1);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Customer has been notified.')),
      );
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } on Object {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Arrival could not be confirmed.')),
      );
    } finally {
      if (mounted) {
        setState(() => _isMarkingArrived = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<Trip> trip = ref.watch(riderTripProvider(widget.tripId));
    return trip.when(
      data: _buildTrip,
      error: (Object error, StackTrace stackTrace) => const Scaffold(
        backgroundColor: JosiColors.white,
        body: SafeArea(
          child: AppScreenBody(
            children: <Widget>[
              ErrorState(
                title: 'Trip unavailable',
                message: 'Trip details could not load.',
              ),
            ],
          ),
        ),
      ),
      loading: () => const Scaffold(
        backgroundColor: JosiColors.white,
        body: SafeArea(
          child: Center(child: LoadingState(label: 'Loading active trip')),
        ),
      ),
    );
  }

  Widget _buildTrip(Trip trip) {
    final List<String> titles = <String>[
      'Customer Location',
      'Destination',
      'Arrived At Destination',
    ];
    final int resolvedStage =
        trip.isArrivedAtPickup && _stage == 0 ? 1 : _stage;
    final int stageIndex = resolvedStage.clamp(0, titles.length - 1).toInt();
    final String title = titles[stageIndex];

    return Scaffold(
      key: const ValueKey<String>('rider-active-trip-screen'),
      backgroundColor: JosiColors.white,
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: _RiderMapBackdrop(
              trip: trip,
              stageIndex: stageIndex,
            ),
          ),
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
                    fontSize: 18,
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
                  isLoading: _isMarkingArrived,
                  onContinue: () => _markArrivedAtPickup(trip),
                ),
              1 => _RiderDestinationPanel(
                  destination: trip.destination,
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

enum _RiderBookingStatus {
  active('Active'),
  completed('Completed'),
  cancelled('Cancelled');

  const _RiderBookingStatus(this.label);

  final String label;

  String get key => switch (this) {
        _RiderBookingStatus.active => 'rider-bookings-tab-active',
        _RiderBookingStatus.completed => 'rider-bookings-tab-completed',
        _RiderBookingStatus.cancelled => 'rider-bookings-tab-cancelled',
      };
}

class _RiderBookingItem {
  const _RiderBookingItem({
    required this.tripId,
    required this.driverName,
    required this.crn,
    required this.distance,
    required this.duration,
    required this.rate,
    required this.dateTime,
    required this.pickup,
    required this.destination,
    required this.carType,
    this.statusLabel,
  });

  factory _RiderBookingItem.fromTrip(Trip trip) {
    return _RiderBookingItem(
      tripId: trip.id,
      driverName:
          trip.customerName.trim().isEmpty ? 'Customer' : trip.customerName,
      crn: '#${trip.id}',
      distance: trip.distance.trim().isEmpty ? 'Pending' : trip.distance,
      duration: trip.duration.trim().isEmpty ? 'Pending' : trip.duration,
      rate: trip.fare,
      dateTime: trip.dateLabel.trim().isEmpty ? 'Pending' : trip.dateLabel,
      pickup: trip.pickup,
      destination: trip.destination,
      carType: trip.vehicleLabel.trim().isEmpty
          ? 'Vehicle pending'
          : trip.vehicleLabel,
      statusLabel: trip.status == TripStatus.cancelled ? 'Cancelled' : null,
    );
  }

  final String tripId;
  final String driverName;
  final String crn;
  final String distance;
  final String duration;
  final String rate;
  final String dateTime;
  final String pickup;
  final String destination;
  final String carType;
  final String? statusLabel;
}

class RiderTripsScreen extends ConsumerStatefulWidget {
  const RiderTripsScreen({super.key});

  @override
  ConsumerState<RiderTripsScreen> createState() => _RiderTripsScreenState();
}

class _RiderTripsScreenState extends ConsumerState<RiderTripsScreen> {
  _RiderBookingStatus _selectedTab = _RiderBookingStatus.active;

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<Trip>> trips = ref.watch(tripsProvider);
    final List<_RiderBookingItem> bookings = trips.value
            ?.where((Trip trip) => _matchesRiderBookingTab(trip, _selectedTab))
            .map(_RiderBookingItem.fromTrip)
            .toList() ??
        <_RiderBookingItem>[];

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
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                  ),
                        ),
                      ),
                      const SizedBox(width: 54),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                _RiderBookingTabs(
                  selectedTab: _selectedTab,
                  onSelected: (_RiderBookingStatus tab) =>
                      setState(() => _selectedTab = tab),
                ),
                Expanded(
                  child: trips.when(
                    data: (_) {
                      if (bookings.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 30),
                            child: EmptyState(
                              title:
                                  'No ${_selectedTab.label.toLowerCase()} bookings',
                              message:
                                  'Trips from the backend will appear here.',
                            ),
                          ),
                        );
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                        itemBuilder: (BuildContext context, int index) {
                          final _RiderBookingItem item = bookings[index];
                          return _RiderBookingCard(
                            item: item,
                            tab: _selectedTab,
                            onCancel: () =>
                                context.go(AppRoutes.riderCancelRide),
                            onTrack: () => context
                                .go(AppRoutes.riderActiveTripPath(item.tripId)),
                          );
                        },
                        separatorBuilder: (BuildContext context, int index) =>
                            const SizedBox(height: 14),
                        itemCount: bookings.length,
                      );
                    },
                    error: (Object error, StackTrace stackTrace) => Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: ErrorState(
                          title: 'Bookings unavailable',
                          message: _riderErrorMessage(
                            error,
                            'Rider bookings could not load.',
                          ),
                        ),
                      ),
                    ),
                    loading: () => const SizedBox(
                      height: 220,
                      child: LoadingState(label: 'Loading bookings'),
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
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                  ),
                        ),
                      ),
                      const SizedBox(width: 54),
                    ],
                  ),
                ),
                const SizedBox(height: 34),
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
            data: (RiderProfile value) {
              final String location = _riderLocationLabel(value);
              return AppCard(
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
                          if (value.phone.trim().isNotEmpty) ...<Widget>[
                            const SizedBox(height: 4),
                            Text(
                              value.phone,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: JosiColors.muted),
                            ),
                          ],
                          const SizedBox(height: 4),
                          Text(
                            location,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: JosiColors.muted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
            error: (Object error, StackTrace stackTrace) => const ErrorState(
                title: 'Profile unavailable',
                message: 'Rider profile could not load.'),
            loading: () => const SizedBox(
                height: 120, child: LoadingState(label: 'Loading profile')),
          ),
          const SizedBox(height: 16),
          const _ProfileMenuItem(
              icon: Icons.edit_rounded,
              label: 'Your profile',
              route: AppRoutes.riderProfileSetupUpdate),
          const _ProfileMenuItem(
              icon: Icons.account_balance_rounded,
              label: 'Bank Account Details',
              route: AppRoutes.riderBankAccountDetailsUpdate),
          const _ProfileMenuItem(
              icon: Icons.directions_car_rounded,
              label: 'Riding Details',
              route: AppRoutes.riderVehicleSetupUpdate),
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
            key: const ValueKey<String>('rider-logout-button'),
            label: 'Logout',
            icon: Icons.logout_rounded,
            variant: AppButtonVariant.danger,
            onPressed: () {
              final GoRouter router = GoRouter.of(context);
              router.go(AppRoutes.loginFor('rider'));
              unawaited(ref.read(authControllerProvider.notifier).signOut());
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
  const _RiderBookingTabs({
    required this.selectedTab,
    required this.onSelected,
  });

  final _RiderBookingStatus selectedTab;
  final ValueChanged<_RiderBookingStatus> onSelected;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: JosiColors.line)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: <Widget>[
            for (final _RiderBookingStatus tab in _RiderBookingStatus.values)
              _RiderBookingTab(
                key: ValueKey<String>(tab.key),
                tab: tab,
                selected: tab == selectedTab,
                onTap: () => onSelected(tab),
              ),
          ],
        ),
      ),
    );
  }
}

class _RiderBookingTab extends StatelessWidget {
  const _RiderBookingTab({
    required this.tab,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final _RiderBookingStatus tab;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 58,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Text(
                tab.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: selected ? JosiColors.red : JosiColors.softMuted,
                      fontSize: 17,
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 15),
              AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                height: 4,
                width: selected ? 110 : 0,
                decoration: const BoxDecoration(
                  color: JosiColors.red,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RiderBookingCard extends StatelessWidget {
  const _RiderBookingCard({
    required this.item,
    required this.tab,
    required this.onCancel,
    required this.onTrack,
  });

  final _RiderBookingItem item;
  final _RiderBookingStatus tab;
  final VoidCallback onCancel;
  final VoidCallback onTrack;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        color: JosiColors.white,
        borderRadius: BorderRadius.circular(8),
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
          if (item.statusLabel != null) ...<Widget>[
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: JosiColors.redSoft,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  item.statusLabel!,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: JosiColors.red,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          Row(
            children: <Widget>[
              ProfileAvatar(name: item.driverName, size: 58),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      item.driverName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: JosiColors.ink,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'CRN : ${item.crn}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: JosiColors.softMuted,
                            fontSize: 14,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Icon(Icons.star_rounded,
                      color: JosiColors.red, size: 24),
                  const SizedBox(width: 5),
                  Text(
                    '5.0',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: JosiColors.ink,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Divider(color: JosiColors.line),
          const SizedBox(height: 14),
          Row(
            children: <Widget>[
              Expanded(
                child: _RiderBookingStat(
                  icon: Icons.location_on_outlined,
                  value: item.distance,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _RiderBookingStat(
                  icon: Icons.schedule_rounded,
                  value: item.duration,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _RiderBookingStat(
                  icon: Icons.work_outline_rounded,
                  value: item.rate,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  'Date & Time',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: JosiColors.softMuted,
                        fontSize: 14,
                      ),
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  item.dateTime,
                  maxLines: 1,
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: JosiColors.ink,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(color: JosiColors.line),
          const SizedBox(height: 14),
          _RiderBookingRouteSummary(
            pickup: item.pickup,
            destination: item.destination,
          ),
          const SizedBox(height: 14),
          const Divider(color: JosiColors.line),
          const SizedBox(height: 14),
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  'Booking Car Type',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: JosiColors.softMuted,
                        fontSize: 14,
                      ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                item.carType,
                maxLines: 1,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: JosiColors.ink,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ],
          ),
          if (tab == _RiderBookingStatus.active) ...<Widget>[
            const SizedBox(height: 18),
            Row(
              children: <Widget>[
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: OutlinedButton(
                      key:
                          const ValueKey<String>('rider-booking-cancel-button'),
                      onPressed: onCancel,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: JosiColors.red,
                        side: const BorderSide(color: JosiColors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                        textStyle:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 52,
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
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                      ),
                      child: const Text('Track Rider'),
                    ),
                  ),
                ),
              ],
            ),
          ] else ...<Widget>[
            const SizedBox(height: 22),
            const Center(
              child: Icon(Icons.keyboard_arrow_up_rounded,
                  color: JosiColors.softMuted, size: 32),
            ),
          ],
        ],
      ),
    );
  }
}

class _RiderBookingStat extends StatelessWidget {
  const _RiderBookingStat({
    required this.icon,
    required this.value,
  });

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(icon, color: JosiColors.red, size: 22),
        const SizedBox(width: 7),
        Flexible(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: JosiColors.ink,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ),
      ],
    );
  }
}

class _RiderBookingRouteSummary extends StatelessWidget {
  const _RiderBookingRouteSummary({
    required this.pickup,
    required this.destination,
  });

  final String pickup;
  final String destination;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Column(
          children: <Widget>[
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: JosiColors.ink, width: 4),
              ),
              child: Center(
                child: Container(
                  width: 9,
                  height: 9,
                  decoration: const BoxDecoration(
                    color: JosiColors.ink,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 42,
              child: VerticalDivider(color: JosiColors.line, thickness: 1),
            ),
            const Icon(Icons.location_on_rounded,
                color: JosiColors.red, size: 30),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            children: <Widget>[
              _RiderBookingRouteText(label: pickup),
              const Divider(color: JosiColors.line, height: 28),
              _RiderBookingRouteText(label: destination),
            ],
          ),
        ),
      ],
    );
  }
}

class _RiderBookingRouteText extends StatelessWidget {
  const _RiderBookingRouteText({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: JosiColors.ink,
              fontSize: 16,
              fontWeight: FontWeight.w600,
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
        borderRadius: BorderRadius.circular(8),
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
            padding: const EdgeInsets.fromLTRB(22, 28, 22, 0),
            child: Column(
              children: <Widget>[
                Container(
                  width: 88,
                  height: 88,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF7F7F7),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      AppAssets.card,
                      width: 46,
                      height: 46,
                      colorFilter: const ColorFilter.mode(
                        JosiColors.red,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Collect Cash',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: JosiColors.ink,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 24),
                const _RiderBookingRouteSummary(
                  pickup: 'Wuse Market',
                  destination: 'Jabi Lake Mall',
                ),
                const SizedBox(height: 22),
                const Divider(color: JosiColors.line),
                const SizedBox(height: 18),
                Row(
                  children: <Widget>[
                    const ProfileAvatar(name: 'Esther Howard', size: 56),
                    const SizedBox(width: 14),
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
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Cash Payment',
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: JosiColors.softMuted,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
              ],
            ),
          ),
          Container(
            height: 62,
            padding: const EdgeInsets.symmetric(horizontal: 22),
            decoration: const BoxDecoration(
              color: JosiColors.red,
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(8),
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
                          fontSize: 17,
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
  const _RiderDashboardMetrics({
    required this.trips,
    required this.isLoading,
  });

  final List<Trip> trips;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final int prebookedCount = trips
        .where((Trip trip) =>
            trip.status == TripStatus.searching ||
            trip.status == TripStatus.active)
        .length;
    final double todayEarned = trips
        .where((Trip trip) =>
            trip.status == TripStatus.completed &&
            _isToday(trip.completedAt ?? trip.requestedAt))
        .fold<double>(
          0,
          (double total, Trip trip) => total + (trip.amount ?? 0),
        );

    return Row(
      children: <Widget>[
        Expanded(
          child: _RiderDashboardMetricCard(
            key: const ValueKey<String>('rider-metric-prebooked-card'),
            label: 'Pre - Booked',
            value: isLoading ? '...' : '$prebookedCount',
            icon: Icons.calendar_month_rounded,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _RiderDashboardMetricCard(
            key: const ValueKey<String>('rider-metric-today-earned-card'),
            label: 'Today Earned',
            value: isLoading ? '...' : _moneyLabel(todayEarned),
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
  const _FindingJobsPanel({
    required this.progress,
    required this.status,
  });

  final double progress;
  final _RiderJobSearchStatus status;

  @override
  Widget build(BuildContext context) {
    final bool notFound = status == _RiderJobSearchStatus.notFound;

    return Container(
      key: const ValueKey<String>('rider-finding-jobs-panel'),
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(
                  notFound ? Icons.search_off_rounded : Icons.radar_rounded,
                  color: JosiColors.red,
                  size: 24,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    notFound ? 'No ride found' : 'Finding jobs',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: JosiColors.ink,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                key: const ValueKey<String>('rider-finding-jobs-progress'),
                value: progress.clamp(0, 1),
                minHeight: 8,
                backgroundColor: JosiColors.redSoft,
                color: JosiColors.red,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              notFound
                  ? 'No assigned ride is waiting right now.'
                  : 'Checking assigned customer requests near you.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: JosiColors.softMuted,
                    fontSize: 14,
                    height: 1.35,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RideRequestTimer extends StatelessWidget {
  const _RideRequestTimer({required this.secondsRemaining});

  final int secondsRemaining;

  @override
  Widget build(BuildContext context) {
    final double progress = secondsRemaining / 30;

    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          SizedBox.square(
            dimension: 150,
            child: CircularProgressIndicator(
              value: progress.clamp(0, 1),
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
                  '$secondsRemaining',
                  key: const ValueKey<String>('rider-ride-request-countdown'),
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
    required this.isAccepting,
    required this.isDeclining,
  });

  final Trip trip;
  final VoidCallback onDecline;
  final VoidCallback onAccept;
  final bool isAccepting;
  final bool isDeclining;

  @override
  Widget build(BuildContext context) {
    final String customerName =
        trip.customerName.trim().isEmpty ? 'Customer' : trip.customerName;
    final String distanceLabel =
        trip.duration.trim().isNotEmpty ? trip.duration : trip.distance;

    return Container(
      key: const ValueKey<String>('rider-ride-request-sheet'),
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 12, 22, 18),
      decoration: const BoxDecoration(
        color: JosiColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
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
            const SizedBox(height: 18),
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    'Ride Request',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: JosiColors.ink,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
                Text(
                  distanceLabel.trim().isEmpty ? trip.fare : distanceLabel,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: JosiColors.softMuted,
                        fontSize: 14,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(color: JosiColors.line),
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                ProfileAvatar(name: customerName, size: 56),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        customerName,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: JosiColors.ink,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${_paymentLabel(trip.paymentMethod)} Payment',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: JosiColors.softMuted,
                              fontSize: 14,
                            ),
                      ),
                    ],
                  ),
                ),
                Text(
                  trip.fare,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: JosiColors.red,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _RideRequestRouteSummary(trip: trip),
            const SizedBox(height: 20),
            Row(
              children: <Widget>[
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      key: const ValueKey<String>('rider-ride-request-decline'),
                      onPressed: isAccepting || isDeclining ? null : onDecline,
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
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                      ),
                      child: isDeclining
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: JosiColors.red,
                              ),
                            )
                          : const Text('Decline'),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      key: const ValueKey<String>('rider-ride-request-accept'),
                      onPressed: isAccepting || isDeclining ? null : onAccept,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: JosiColors.red,
                        foregroundColor: JosiColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                        textStyle:
                            Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: JosiColors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                      ),
                      child: isAccepting
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: JosiColors.white,
                              ),
                            )
                          : const Text('Accept'),
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
  const _RideRequestRouteSummary({required this.trip});

  final Trip trip;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Column(
          children: <Widget>[
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: JosiColors.ink, width: 3),
              ),
              child: Center(
                child: Container(
                  width: 11,
                  height: 11,
                  decoration: const BoxDecoration(
                    color: JosiColors.ink,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            CustomPaint(
              size: const Size(1, 36),
              painter: _VerticalDashedLinePainter(),
            ),
            const Icon(Icons.location_on_rounded,
                color: JosiColors.red, size: 32),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  trip.pickup,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: JosiColors.ink,
                        fontSize: 16,
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
                      trip.duration.trim().isEmpty
                          ? (trip.distance.trim().isEmpty
                              ? trip.fare
                              : trip.distance)
                          : trip.duration,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: JosiColors.softMuted,
                            fontSize: 13,
                          ),
                    ),
                  ),
                ),
                Text(
                  trip.destination,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: JosiColors.ink,
                        fontSize: 16,
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

class _RiderDashboardMapBackdrop extends ConsumerWidget {
  const _RiderDashboardMapBackdrop({
    required this.onRiderLocationReady,
    this.activeTrip,
  });

  final Trip? activeTrip;
  final ValueChanged<LatLng> onRiderLocationReady;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocation = ref.watch(currentLocationProvider);
    final LatLng riderLocation =
        currentLocation.value?.latLng ?? MapConstants.mockRiderLocation;
    final Set<Marker> markers = <Marker>{
      MapConstants.riderMarker(riderLocation),
      if (activeTrip != null) ...<Marker>{
        MapConstants.customerMarker(MapConstants.defaultPickup),
        MapConstants.destinationMarker(MapConstants.defaultDestination),
      },
    };

    return JosiGoogleMap(
      key: const ValueKey<String>('rider-home-map'),
      initialCameraPosition: MapConstants.cameraFor(riderLocation),
      markers: markers,
      myLocationEnabled: currentLocation.hasValue,
      showCurrentLocationButton: true,
      isLoading: currentLocation.isLoading,
      onMapCreated: (_) => onRiderLocationReady(riderLocation),
    );
  }
}

// ignore: unused_element
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
    this.bottomLoading = false,
    this.backUsesFallback = false,
  });

  final String fallbackRoute;
  final String? appBarTitle;
  final String? headline;
  final String? subtitle;
  final String? bottomLabel;
  final VoidCallback? onBottomPressed;
  final bool bottomLoading;
  final bool backUsesFallback;
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
                      _RiderCircleBackButton(
                        fallbackRoute: fallbackRoute,
                        backUsesFallback: backUsesFallback,
                      ),
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
              isLoading: bottomLoading,
              onPressed: onBottomPressed,
            ),
    );
  }
}

class _RiderCircleBackButton extends StatelessWidget {
  const _RiderCircleBackButton({
    required this.fallbackRoute,
    this.backUsesFallback = false,
  });

  final String fallbackRoute;
  final bool backUsesFallback;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: JosiColors.white,
      shape: const CircleBorder(),
      elevation: 2.5,
      shadowColor: const Color(0x18000000),
      child: InkWell(
        key: const ValueKey<String>('rider-flow-back-button'),
        customBorder: const CircleBorder(),
        onTap: () {
          if (backUsesFallback) {
            context.go(fallbackRoute);
            return;
          }

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
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

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
              onPressed: isLoading ? null : onPressed,
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
              child: isLoading
                  ? const SizedBox.square(
                      dimension: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: JosiColors.white,
                      ),
                    )
                  : Text(label),
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
    this.controller,
    this.keyboardType,
    this.textInputAction,
    this.errorText,
    this.readOnly = false,
  });

  final String label;
  final String hintText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? errorText;
  final bool readOnly;

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
          controller: controller,
          initialValue: controller == null ? hintText : null,
          readOnly: readOnly,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: readOnly ? JosiColors.outline : JosiColors.softMuted,
                fontSize: 17,
              ),
          decoration: InputDecoration(
            hintText: controller == null ? null : hintText,
            hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: JosiColors.outline,
                  fontSize: 16,
                ),
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
        if (errorText != null) ...<Widget>[
          const SizedBox(height: 6),
          Text(
            errorText!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: JosiColors.redDark,
                  fontSize: 12,
                  height: 1.2,
                ),
          ),
        ],
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
    final String selectedValue = items.contains(value) ? value : items.first;

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
          initialValue: selectedValue,
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

class _ProfilePhotoUploadBox extends StatelessWidget {
  const _ProfilePhotoUploadBox({
    required this.selectedPhoto,
    required this.errorText,
    required this.onTap,
  });

  final String selectedPhoto;
  final String? errorText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool hasPhoto = selectedPhoto.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          height: 158,
          child: CustomPaint(
            painter: _DashedBorderPainter(),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                key: const ValueKey<String>('rider-profile-photo-picker'),
                onTap: onTap,
                borderRadius: BorderRadius.circular(8),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Container(
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                            color: hasPhoto
                                ? JosiColors.red
                                : const Color(0xFF6A6A6A),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            hasPhoto
                                ? Icons.check_rounded
                                : Icons.add_a_photo_outlined,
                            color: JosiColors.white,
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          hasPhoto
                              ? _fileNameFromPath(selectedPhoto)
                              : 'Add Profile Photo',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: JosiColors.ink,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          hasPhoto
                              ? 'Tap to change photo'
                              : 'Camera or gallery',
                          textAlign: TextAlign.center,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: JosiColors.softMuted,
                                    fontSize: 14,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        if (errorText != null) ...<Widget>[
          const SizedBox(height: 8),
          Text(
            errorText!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: JosiColors.redDark,
                  fontSize: 12,
                  height: 1.2,
                ),
          ),
        ],
      ],
    );
  }
}

class _PhotoSourceTile extends StatelessWidget {
  const _PhotoSourceTile({
    required this.icon,
    required this.label,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: JosiColors.surface,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: <Widget>[
              Icon(icon, color: JosiColors.red, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: JosiColors.ink,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: JosiColors.softMuted),
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
    required this.isLoading,
    required this.onContinue,
  });

  final String title;
  final Trip trip;
  final bool isLoading;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final String customerName =
        trip.customerName.trim().isEmpty ? 'Customer' : trip.customerName;
    final String etaLabel =
        trip.duration.trim().isEmpty ? 'ETA pending' : '${trip.duration} away';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 12, 22, 18),
      decoration: const BoxDecoration(
        color: JosiColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
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
            const SizedBox(height: 18),
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: JosiColors.ink,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
                Text(
                  etaLabel,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: JosiColors.softMuted,
                        fontSize: 14,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(color: JosiColors.line),
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                ProfileAvatar(name: customerName, size: 56),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        customerName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: JosiColors.ink,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${_paymentLabel(trip.paymentMethod)} Payment',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: JosiColors.softMuted,
                              fontSize: 14,
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
            const SizedBox(height: 20),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                key: const ValueKey<String>('rider-active-trip-continue'),
                onPressed: isLoading ? null : onContinue,
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
                child: isLoading
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: JosiColors.white,
                        ),
                      )
                    : const Text('Continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RiderDestinationPanel extends StatelessWidget {
  const _RiderDestinationPanel({
    required this.destination,
    required this.onNavigate,
  });

  final String destination;
  final VoidCallback onNavigate;

  @override
  Widget build(BuildContext context) {
    final String destinationLabel =
        destination.trim().isEmpty ? 'Destination unavailable' : destination;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 12, 22, 18),
      decoration: const BoxDecoration(
        color: JosiColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
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
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
                      destinationLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: JosiColors.ink,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 52,
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
                        fontSize: 16,
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
      padding: const EdgeInsets.fromLTRB(22, 12, 22, 18),
      decoration: const BoxDecoration(
        color: JosiColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
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
            const SizedBox(height: 24),
            Container(
              width: 78,
              height: 78,
              decoration: const BoxDecoration(
                color: JosiColors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded,
                  color: JosiColors.white, size: 50),
            ),
            const SizedBox(height: 20),
            Text(
              'Arrived At Customer Location',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: JosiColors.ink,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              '6391 Elgin St. Celina, Delswa...',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: JosiColors.softMuted,
                    fontSize: 14,
                  ),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 52,
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
                        fontSize: 16,
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

class _RiderMapBackdrop extends ConsumerStatefulWidget {
  const _RiderMapBackdrop({
    required this.trip,
    required this.stageIndex,
  });

  final Trip trip;
  final int stageIndex;

  @override
  ConsumerState<_RiderMapBackdrop> createState() => _RiderMapBackdropState();
}

class _RiderMapBackdropState extends ConsumerState<_RiderMapBackdrop> {
  GoogleMapController? _mapController;
  String? _lastCameraFitKey;

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  void _fitCameraAfterRoute(RouteDetails? routeDetails) {
    if (routeDetails == null || routeDetails.polylinePoints.length < 2) {
      return;
    }

    final String routeKey = '${widget.stageIndex}:'
        '${routeDetails.polylinePoints.first.latitude},'
        '${routeDetails.polylinePoints.first.longitude}:'
        '${routeDetails.polylinePoints.last.latitude},'
        '${routeDetails.polylinePoints.last.longitude}:'
        '${routeDetails.polylinePoints.length}';
    if (_lastCameraFitKey == routeKey) {
      return;
    }
    _lastCameraFitKey = routeKey;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _fitCameraToPoints(routeDetails.polylinePoints);
    });
  }

  Future<void> _fitCameraToPoints(List<LatLng> points) async {
    final GoogleMapController? controller = _mapController;
    if (controller == null || points.length < 2) {
      return;
    }

    try {
      await controller.animateCamera(
        CameraUpdate.newLatLngBounds(MapConstants.boundsFor(points), 112),
      );
    } on Object {
      // Bounds updates can race the platform map layout on first paint.
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentLocation = ref.watch(currentLocationProvider);
    final LatLng riderLocation =
        currentLocation.value?.latLng ?? MapConstants.mockRiderLocation;
    final ActiveTripMapState mapState = ref.watch(activeTripMapProvider);
    final bool headingToPickup = widget.stageIndex == 0;
    final MapRouteRequest routeRequest = MapRouteRequest(
      origin: headingToPickup ? riderLocation : mapState.pickup,
      destination: headingToPickup ? mapState.pickup : mapState.destination,
    );
    final AsyncValue<RouteDetails> route = ref.watch(
      mapRouteProvider(routeRequest),
    );
    _fitCameraAfterRoute(route.value);

    return JosiGoogleMap(
      key: const ValueKey<String>('rider-active-trip-map'),
      initialCameraPosition: MapConstants.cameraFor(
        riderLocation,
        zoom: MapConstants.tripZoom,
      ),
      markers: <Marker>{
        MapConstants.riderMarker(riderLocation),
        MapConstants.customerMarker(
          mapState.pickup,
          id: 'customer-${widget.trip.id}',
        ),
        MapConstants.destinationMarker(
          mapState.destination,
          id: 'destination-${widget.trip.id}',
        ),
      },
      polylines: _riderRoutePolylines(
        route.value,
        id: headingToPickup ? 'rider-to-pickup-route' : 'rider-trip-route',
      ),
      myLocationEnabled: currentLocation.hasValue,
      showCurrentLocationButton: true,
      onMapCreated: (GoogleMapController controller) {
        _mapController = controller;
        _fitCameraAfterRoute(route.value);
      },
    );
  }
}

Set<Polyline> _riderRoutePolylines(
  RouteDetails? routeDetails, {
  required String id,
}) {
  if (routeDetails == null || routeDetails.polylinePoints.length < 2) {
    return const <Polyline>{};
  }

  return <Polyline>{
    MapConstants.routePolyline(routeDetails.polylinePoints, id: id),
  };
}

// ignore: unused_element
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

String _riderErrorMessage(Object error, String fallback) {
  if (error is ApiException) {
    final Object? first =
        error.errors.values.isEmpty ? null : error.errors.values.first;
    if (first is List<Object?> && first.isNotEmpty) {
      return '${first.first}';
    }
    return error.message;
  }

  return fallback;
}

Map<String, String> _riderFieldErrors(Object error) {
  if (error is! ApiException || error.errors.isEmpty) {
    return const <String, String>{};
  }

  return error.errors.map((String key, Object? value) {
    if (value is List && value.isNotEmpty) {
      return MapEntry<String, String>(key, '${value.first}');
    }
    return MapEntry<String, String>(key, '$value');
  });
}

String _vehicleTypeApiValue(String label) {
  return switch (label.toLowerCase().trim()) {
    'motorcycle' => 'motorcycle',
    'tricycle' => 'tricycle',
    'car' => 'car',
    'van' => 'van',
    _ => 'bike',
  };
}

String _vehicleTypeLabel(String value) {
  return switch (value.toLowerCase().trim()) {
    'motorcycle' => 'Motorcycle',
    'tricycle' => 'Tricycle',
    'car' => 'Car',
    'van' => 'Van',
    _ => 'Bike',
  };
}

String? _cleanPendingValue(String? value) {
  final String trimmed = value?.trim() ?? '';
  if (trimmed.isEmpty || trimmed.toLowerCase() == 'pending onboarding') {
    return null;
  }

  return trimmed;
}

String _cityLabel(String? city, String? state) {
  final String? cleanCity = _cleanPendingValue(city);
  final String? cleanState = _cleanPendingValue(state);
  if (cleanCity == null) {
    return 'Abuja, FCT';
  }

  final String label =
      cleanState == null ? cleanCity : '$cleanCity, $cleanState';
  const List<String> supported = <String>[
    'Abuja, FCT',
    'Lagos, Lagos',
    'Port Harcourt, Rivers',
  ];
  return supported.contains(label) ? label : 'Other';
}

String _genderLabel(String? gender) {
  return switch (_cleanPendingValue(gender)?.toLowerCase()) {
    'female' => 'Female',
    'male' => 'Male',
    _ => 'Select',
  };
}

String _riderLocationLabel(RiderProfile profile) {
  final List<String> parts = <String>[
    if (_cleanPendingValue(profile.address) != null)
      _cleanPendingValue(profile.address)!,
    if (_cleanPendingValue(profile.city) != null)
      _cleanPendingValue(profile.city)!,
    if (_cleanPendingValue(profile.state) != null)
      _cleanPendingValue(profile.state)!,
  ];

  if (parts.isEmpty) {
    return 'Location not added yet';
  }

  return parts.join(', ');
}

String _cityNameFromLabel(String label) {
  if (label == 'Other') {
    return '';
  }

  return label.split(',').first.trim();
}

String? _stateFromLabel(String label) {
  final List<String> parts = label.split(',');
  if (parts.length < 2) {
    return null;
  }

  final String state = parts.skip(1).join(',').trim();
  return state.isEmpty ? null : state;
}

String _fileNameFromPath(String path) {
  final List<String> parts = path.split(RegExp(r'[\\/]'));
  final String fileName = parts.isEmpty ? path : parts.last;
  return fileName.trim().isEmpty ? 'Selected photo' : fileName.trim();
}

Trip? _nextRideRequest(List<Trip> trips) {
  for (final Trip trip in trips) {
    if (trip.status == TripStatus.searching) {
      return trip;
    }
  }
  return null;
}

bool _matchesRiderBookingTab(Trip trip, _RiderBookingStatus tab) {
  return switch (tab) {
    _RiderBookingStatus.active =>
      trip.status == TripStatus.searching || trip.status == TripStatus.active,
    _RiderBookingStatus.completed => trip.status == TripStatus.completed,
    _RiderBookingStatus.cancelled => trip.status == TripStatus.cancelled,
  };
}

bool _isToday(DateTime? value) {
  if (value == null) {
    return false;
  }

  final DateTime local = value.toLocal();
  final DateTime now = DateTime.now();
  return local.year == now.year &&
      local.month == now.month &&
      local.day == now.day;
}

String _moneyLabel(double amount) {
  return 'NGN ${amount.toStringAsFixed(0)}';
}
