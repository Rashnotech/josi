import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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

  @override
  Widget build(BuildContext context) {
    final AsyncValue<JosiUser> user = ref.watch(currentRiderProvider);
    final AsyncValue<WalletSummary> wallet = ref.watch(riderWalletProvider);
    final AsyncValue<List<Trip>> trips = ref.watch(tripsProvider);

    return AppScaffold(
      title: user.maybeWhen(
          data: (JosiUser value) => 'Hi, ${value.name.split(' ').first}',
          orElse: () => 'Rider home'),
      subtitle: _isOnline ? 'Online and receiving requests' : 'Offline',
      navRole: AppNavRole.rider,
      selectedTab: 'home',
      showBackButton: false,
      actions: <Widget>[
        Switch(
          value: _isOnline,
          activeThumbColor: JosiColors.success,
          onChanged: (bool value) => setState(() => _isOnline = value),
        ),
      ],
      child: AppScreenBody(
        children: <Widget>[
          AppCard(
            child: Row(
              children: <Widget>[
                const StatusBadge(
                  label: 'Under review',
                  color: JosiColors.warning,
                  softColor: JosiColors.warningSoft,
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => context.go(AppRoutes.riderApplicationStatus),
                  child: const Text('Status'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          wallet.when(
            data: (WalletSummary value) => GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.22,
              physics: const NeverScrollableScrollPhysics(),
              children: <Widget>[
                MetricTile(
                    label: 'Today earnings',
                    value: value.todayEarnings,
                    icon: Icons.payments_rounded),
                MetricTile(
                  label: 'Cash to remit',
                  value: value.pendingRemittance,
                  icon: Icons.price_check_rounded,
                  color: JosiColors.warning,
                ),
                const MetricTile(
                    label: 'Completed trips',
                    value: '8',
                    icon: Icons.route_rounded,
                    color: JosiColors.info),
                const MetricTile(
                    label: 'Rating',
                    value: '4.8',
                    icon: Icons.star_rate_rounded,
                    color: JosiColors.success),
              ],
            ),
            error: (Object error, StackTrace stackTrace) => const ErrorState(
                title: 'Earnings unavailable',
                message: 'Rider wallet could not be loaded.'),
            loading: () => const SizedBox(
                height: 180, child: LoadingState(label: 'Loading earnings')),
          ),
          const SizedBox(height: 18),
          AppCard(
            onTap: () => context.go(AppRoutes.riderAvailableTrips),
            child: Row(
              children: <Widget>[
                const Icon(Icons.local_taxi_rounded,
                    color: JosiColors.red, size: 34),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Available trips',
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 4),
                      Text('3 requests around Wuse and Jabi',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: JosiColors.muted)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded,
                    color: JosiColors.muted),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const SectionHeader(title: 'Active trip'),
          trips.when(
            data: (List<Trip> values) => TripCard(
              trip: values[1],
              onTap: () =>
                  context.go(AppRoutes.riderActiveTripPath(values[1].id)),
            ),
            error: (Object error, StackTrace stackTrace) => const EmptyState(
                title: 'No active trip',
                message: 'Accepted trips will appear here.'),
            loading: () => const SizedBox(
                height: 140, child: LoadingState(label: 'Loading active trip')),
          ),
        ],
      ),
    );
  }
}

class RiderApplicationStatusScreen extends StatelessWidget {
  const RiderApplicationStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Application status',
      subtitle: 'Approval checklist',
      child: AppScreenBody(
        children: <Widget>[
          AppCard(
            child: Column(
              children: <Widget>[
                const Icon(Icons.hourglass_top_rounded,
                    color: JosiColors.warning, size: 54),
                const SizedBox(height: 12),
                Text('Under review',
                    style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 6),
                Text(
                  'Josi is reviewing your profile, documents, and vehicle information.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: JosiColors.muted),
                ),
                const SizedBox(height: 14),
                const Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: <Widget>[
                    StatusBadge(
                        label: 'pending',
                        color: JosiColors.muted,
                        softColor: JosiColors.surfaceStrong),
                    StatusBadge(
                        label: 'under_review',
                        color: JosiColors.warning,
                        softColor: JosiColors.warningSoft),
                    StatusBadge(
                        label: 'approved',
                        color: JosiColors.success,
                        softColor: JosiColors.successSoft),
                    StatusBadge(
                        label: 'rejected',
                        color: JosiColors.red,
                        softColor: JosiColors.redSoft),
                    StatusBadge(
                        label: 'suspended',
                        color: JosiColors.redDark,
                        softColor: JosiColors.redSoft),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const AppCard(
            child: Column(
              children: <Widget>[
                _ChecklistRow(label: 'Profile completed', done: true),
                _ChecklistRow(label: 'Documents uploaded', done: false),
                _ChecklistRow(label: 'Vehicle added', done: true),
                _ChecklistRow(label: 'Admin approval', done: false),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppButton(
            label: 'Continue documents',
            icon: Icons.upload_file_rounded,
            onPressed: () => context.go(AppRoutes.riderDocumentUpload),
          ),
        ],
      ),
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
  String _gender = 'Female';

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Profile setup',
      subtitle: '60% complete',
      child: AppScreenBody(
        children: <Widget>[
          LinearProgressIndicator(
            value: 0.6,
            minHeight: 8,
            borderRadius: BorderRadius.circular(999),
            color: JosiColors.red,
            backgroundColor: JosiColors.line,
          ),
          const SizedBox(height: 18),
          const Center(
              child:
                  ProfileAvatar(name: 'Amina Yusuf', size: 86, showEdit: true)),
          const SizedBox(height: 18),
          const AppTextField(
              label: 'Full name',
              hintText: 'Amina Yusuf',
              icon: Icons.person_outline_rounded),
          const SizedBox(height: 12),
          const AppTextField(
              label: 'Phone',
              hintText: '+234 802 345 6789',
              icon: Icons.phone_outlined),
          const SizedBox(height: 12),
          AppDropdown(
            label: 'Gender',
            value: _gender,
            items: const <String>['Female', 'Male', 'Prefer not to say'],
            onChanged: (String? value) =>
                setState(() => _gender = value ?? _gender),
          ),
          const SizedBox(height: 12),
          const AppTextField(
              label: 'Date of birth',
              hintText: '12 Aug 1994',
              icon: Icons.calendar_month_rounded),
          const SizedBox(height: 12),
          const AppTextField(
              label: 'Address',
              hintText: '22 Adetokunbo Ademola Crescent',
              icon: Icons.home_outlined),
          const SizedBox(height: 12),
          const AppTextField(
              label: 'City',
              hintText: 'Abuja',
              icon: Icons.location_city_rounded),
          const SizedBox(height: 12),
          const AppTextField(
              label: 'State', hintText: 'FCT', icon: Icons.map_outlined),
          const SizedBox(height: 18),
          AppButton(
              label: 'Save profile',
              icon: Icons.save_rounded,
              onPressed: () {}),
        ],
      ),
    );
  }
}

class RiderDocumentUploadScreen extends ConsumerWidget {
  const RiderDocumentUploadScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<DocumentRequirement>> documents =
        ref.watch(riderDocumentsProvider);

    return AppScaffold(
      title: 'Documents',
      subtitle: 'KYC upload checklist',
      child: AppScreenBody(
        children: <Widget>[
          documents.when(
            data: (List<DocumentRequirement> values) => Column(
              children: values
                  .map(
                    (DocumentRequirement document) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: DocumentUploadCard(document: document),
                    ),
                  )
                  .toList(),
            ),
            error: (Object error, StackTrace stackTrace) => const ErrorState(
                title: 'Documents unavailable',
                message: 'Upload checklist could not load.'),
            loading: () => const SizedBox(
                height: 220, child: LoadingState(label: 'Loading documents')),
          ),
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
    final List<String> actions = <String>[
      'Arrived at pickup',
      'Start trip',
      'Complete trip'
    ];
    final bool isCashTrip =
        JosiMockData.trips.first.paymentMethod == PaymentMethod.cash;

    return AppScaffold(
      title: 'Active trip',
      subtitle: widget.tripId,
      child: AppScreenBody(
        children: <Widget>[
          const AppMapPlaceholder(
              height: 300, title: 'Route guidance placeholder'),
          const SizedBox(height: 16),
          AppCard(
            child: Row(
              children: <Widget>[
                const ProfileAvatar(name: 'Rik Space'),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Rik Space',
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text('Customer • 5.00 rating',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: JosiColors.muted)),
                    ],
                  ),
                ),
                IconButton(
                    onPressed: () {}, icon: const Icon(Icons.call_rounded)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                for (int index = 0; index < actions.length; index++)
                  _ActionStep(
                      label: actions[index],
                      active: index == _stage,
                      done: index < _stage),
                if (isCashTrip) ...<Widget>[
                  const SizedBox(height: 10),
                  const StatusBadge(
                      label: 'Collect Cash',
                      color: JosiColors.warning,
                      softColor: JosiColors.warningSoft),
                ],
                const SizedBox(height: 14),
                AppButton(
                  label: _stage == actions.length - 1
                      ? 'Complete trip'
                      : actions[_stage],
                  icon: Icons.arrow_forward_rounded,
                  onPressed: () {
                    if (_stage == actions.length - 1) {
                      context
                          .go(AppRoutes.riderTripCompletedPath(widget.tripId));
                      return;
                    }
                    setState(() => _stage += 1);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          AppButton(
            label: 'Emergency support',
            icon: Icons.emergency_rounded,
            variant: AppButtonVariant.danger,
            onPressed: () {},
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

class RiderTripsScreen extends ConsumerWidget {
  const RiderTripsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Trip>> trips = ref.watch(tripsProvider);

    return AppScaffold(
      title: 'Trips',
      subtitle: 'Completed and cancelled',
      navRole: AppNavRole.rider,
      selectedTab: 'trips',
      child: AppScreenBody(
        children: <Widget>[
          const _FilterRow(
              filters: <String>['All', 'Completed', 'Cancelled', 'Cash']),
          const SizedBox(height: 14),
          trips.when(
            data: (List<Trip> values) => Column(
              children: values.map((Trip trip) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TripCard(trip: trip),
                );
              }).toList(),
            ),
            error: (Object error, StackTrace stackTrace) => const ErrorState(
                title: 'Trips unavailable',
                message: 'Trip history could not load.'),
            loading: () => const SizedBox(
                height: 220, child: LoadingState(label: 'Loading trips')),
          ),
        ],
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
                            '${value.completedTrips} trips • ${value.rating} rating',
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
              icon: Icons.upload_file_rounded,
              label: 'Documents',
              route: AppRoutes.riderDocumentUpload),
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

class _ChecklistRow extends StatelessWidget {
  const _ChecklistRow({
    required this.label,
    required this.done,
  });

  final String label;
  final bool done;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: <Widget>[
          Icon(
              done
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: done ? JosiColors.success : JosiColors.muted),
          const SizedBox(width: 10),
          Expanded(
              child:
                  Text(label, style: Theme.of(context).textTheme.bodyMedium)),
        ],
      ),
    );
  }
}

class _ActionStep extends StatelessWidget {
  const _ActionStep({
    required this.label,
    required this.active,
    required this.done,
  });

  final String label;
  final bool active;
  final bool done;

  @override
  Widget build(BuildContext context) {
    final Color color = done
        ? JosiColors.success
        : active
            ? JosiColors.red
            : JosiColors.muted;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: <Widget>[
          Icon(
              done
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_checked_rounded,
              color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: active ? JosiColors.ink : JosiColors.muted),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  const _FilterRow({required this.filters});

  final List<String> filters;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters
            .map(
              (String label) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  selected: label == 'All',
                  onSelected: (bool value) {},
                  label: Text(label),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
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
