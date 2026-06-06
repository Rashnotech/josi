import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_routes.dart';
import '../../core/mock/josi_mock_data.dart';
import '../../core/mock/josi_models.dart';
import '../../core/providers/app_providers.dart';
import '../../core/theme/josi_colors.dart';
import '../../core/widgets/app_components.dart';

class CustomerHomeScreen extends ConsumerWidget {
  const CustomerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<JosiUser> user = ref.watch(currentCustomerProvider);
    final AsyncValue<List<Trip>> trips = ref.watch(tripsProvider);

    return AppScaffold(
      title: user.maybeWhen(
          data: (JosiUser value) => 'Hi, ${value.name.split(' ').first}',
          orElse: () => 'Hi'),
      subtitle: 'Ready for your next city move?',
      navRole: AppNavRole.customer,
      selectedTab: 'home',
      showBackButton: false,
      actions: <Widget>[
        IconButton(
          onPressed: () => context.go(AppRoutes.customerNotifications),
          icon: const Icon(Icons.notifications_none_rounded),
        ),
      ],
      child: AppScreenBody(
        children: <Widget>[
          AppCard(
            child: Row(
              children: <Widget>[
                const Icon(Icons.my_location_rounded, color: JosiColors.red),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Current location',
                          style: Theme.of(context).textTheme.labelMedium),
                      const SizedBox(height: 3),
                      Text(
                        'Wuse 2, Abuja',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: JosiColors.muted),
                      ),
                    ],
                  ),
                ),
                TextButton(
                    onPressed: () =>
                        context.go(AppRoutes.customerSelectLocation),
                    child: const Text('Change')),
              ],
            ),
          ),
          const SizedBox(height: 14),
          AppSearchField(
            hintText: 'Where are you going?',
            onTap: () => context.go(AppRoutes.customerSelectLocation),
          ),
          const SizedBox(height: 18),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.35,
            physics: const NeverScrollableScrollPhysics(),
            children: <Widget>[
              for (final QuickAction action in JosiMockData.customerActions)
                _QuickActionTile(action: action),
            ],
          ),
          const SizedBox(height: 18),
          AppCard(
            color: JosiColors.charcoal,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Cash rides are live',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(color: JosiColors.white),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Pay riders directly while keeping every receipt in Josi.',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: JosiColors.softMuted),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                const Icon(Icons.payments_rounded,
                    color: JosiColors.white, size: 42),
              ],
            ),
          ),
          const SizedBox(height: 18),
          SectionHeader(
            title: 'Recent trips',
            actionLabel: 'View all',
            onAction: () => context.go(AppRoutes.customerTrips),
          ),
          trips.when(
            data: (List<Trip> values) => Column(
              children: values.take(2).map((Trip trip) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TripCard(
                    trip: trip,
                    onTap: () =>
                        context.go(AppRoutes.customerTripDetailPath(trip.id)),
                  ),
                );
              }).toList(),
            ),
            error: (Object error, StackTrace stackTrace) => const ErrorState(
              title: 'Trips unavailable',
              message: 'Trip history could not be loaded.',
            ),
            loading: () => const SizedBox(
                height: 120, child: LoadingState(label: 'Loading trips')),
          ),
        ],
      ),
    );
  }
}

class CustomerBookTripScreen extends StatelessWidget {
  const CustomerBookTripScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Book a trip',
      subtitle: 'Ride or package delivery',
      child: AppScreenBody(
        children: <Widget>[
          const AppMapPlaceholder(height: 220),
          const SizedBox(height: 16),
          const AppTextField(
              label: 'Pickup',
              hintText: 'Wuse 2, Abuja',
              icon: Icons.radio_button_checked_rounded),
          const SizedBox(height: 12),
          const AppTextField(
              label: 'Destination',
              hintText: 'Jabi Lake Mall',
              icon: Icons.location_on_rounded),
          const SizedBox(height: 16),
          AppCard(
            child: Row(
              children: <Widget>[
                const Icon(Icons.inventory_2_rounded, color: JosiColors.red),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Package delivery uses the same confirmation flow with pickup and recipient destination.',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: JosiColors.muted),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          AppButton(
            label: 'Continue',
            icon: Icons.arrow_forward_rounded,
            onPressed: () => context.go(AppRoutes.customerConfirmTrip),
          ),
        ],
      ),
    );
  }
}

class CustomerSelectLocationScreen extends StatelessWidget {
  const CustomerSelectLocationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Select location',
      subtitle: 'Pickup and destination',
      child: AppScreenBody(
        children: <Widget>[
          const AppTextField(
              label: 'Pickup',
              hintText: 'Use current location',
              icon: Icons.my_location_rounded),
          const SizedBox(height: 12),
          const AppTextField(
              label: 'Destination',
              hintText: 'Search destination',
              icon: Icons.location_on_rounded),
          const SizedBox(height: 14),
          const AppMapPlaceholder(height: 280),
          const SizedBox(height: 14),
          AppButton(
            label: 'Use current location',
            icon: Icons.near_me_rounded,
            variant: AppButtonVariant.secondary,
            onPressed: () {},
          ),
          const SizedBox(height: 18),
          const SectionHeader(title: 'Recent locations'),
          for (final String location in JosiMockData.recentLocations)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AppCard(
                onTap: () => context.go(AppRoutes.customerConfirmTrip),
                child: Row(
                  children: <Widget>[
                    const Icon(Icons.history_rounded, color: JosiColors.muted),
                    const SizedBox(width: 12),
                    Expanded(
                        child: Text(location,
                            style: Theme.of(context).textTheme.bodyLarge)),
                    const Icon(Icons.chevron_right_rounded,
                        color: JosiColors.muted),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class CustomerConfirmTripScreen extends StatefulWidget {
  const CustomerConfirmTripScreen({super.key});

  @override
  State<CustomerConfirmTripScreen> createState() =>
      _CustomerConfirmTripScreenState();
}

class _CustomerConfirmTripScreenState extends State<CustomerConfirmTripScreen> {
  PaymentMethod _paymentMethod = PaymentMethod.cash;
  String _tripType = 'Ride';

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Confirm trip',
      subtitle: 'Fare estimate and payment',
      child: AppScreenBody(
        children: <Widget>[
          TripCard(trip: JosiMockData.trips[0]),
          const SizedBox(height: 16),
          const SectionHeader(title: 'Zone pricing'),
          AppCard(
            child: Column(
              children: <Widget>[
                for (final MapEntry<String, String> entry
                    in JosiMockData.zonePricing.entries)
                  _SummaryRow(label: entry.key, value: entry.value),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const SectionHeader(title: 'Payment method'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              _PaymentChoiceChip(
                label: 'Cash',
                selected: _paymentMethod == PaymentMethod.cash,
                onSelected: () =>
                    setState(() => _paymentMethod = PaymentMethod.cash),
              ),
              _PaymentChoiceChip(
                label: 'Online payment',
                selected: _paymentMethod == PaymentMethod.online,
                onSelected: () =>
                    setState(() => _paymentMethod = PaymentMethod.online),
              ),
              _PaymentChoiceChip(
                label: 'Wallet',
                selected: _paymentMethod == PaymentMethod.wallet,
                onSelected: () =>
                    setState(() => _paymentMethod = PaymentMethod.wallet),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AppDropdown(
            label: 'Trip type',
            value: _tripType,
            items: const <String>['Ride', 'Package delivery'],
            onChanged: (String? value) =>
                setState(() => _tripType = value ?? _tripType),
          ),
          const SizedBox(height: 18),
          AppButton(
            label: 'Confirm request',
            icon: Icons.local_taxi_rounded,
            onPressed: () => context.go(AppRoutes.customerSearchingRider),
          ),
        ],
      ),
    );
  }
}

class CustomerSearchingRiderScreen extends StatelessWidget {
  const CustomerSearchingRiderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Finding rider',
      subtitle: 'Matching nearby verified riders',
      child: AppScreenBody(
        children: <Widget>[
          AppCard(
            child: Column(
              children: <Widget>[
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.78, end: 1),
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.easeInOut,
                  builder: (BuildContext context, double scale, Widget? child) {
                    return Transform.scale(scale: scale, child: child);
                  },
                  child: Container(
                    width: 108,
                    height: 108,
                    decoration: const BoxDecoration(
                        color: JosiColors.redSoft, shape: BoxShape.circle),
                    child: const Icon(Icons.radar_rounded,
                        color: JosiColors.red, size: 54),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Searching for the best rider',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 6),
                Text(
                  'This usually takes a few seconds.',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: JosiColors.muted),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TripCard(
              trip: JosiMockData.trips[0],
              trailing: const StatusBadge(label: 'Cash')),
          const SizedBox(height: 18),
          AppButton(
            label: 'Preview active trip',
            icon: Icons.arrow_forward_rounded,
            onPressed: () => context.go(AppRoutes.customerTripActive),
          ),
          const SizedBox(height: 10),
          AppButton(
            label: 'Cancel request',
            variant: AppButtonVariant.secondary,
            onPressed: () => context.go(AppRoutes.customerHome),
          ),
        ],
      ),
    );
  }
}

class CustomerActiveTripScreen extends StatelessWidget {
  const CustomerActiveTripScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Active trip',
      subtitle: 'Rider is en route',
      child: AppScreenBody(
        children: <Widget>[
          const AppMapPlaceholder(
              height: 300, title: 'Live tracking placeholder'),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    const ProfileAvatar(name: 'Amina Yusuf'),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('Amina Yusuf',
                              style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 4),
                          Text(
                            'Toyota Corolla • ABC 482 JK',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: JosiColors.muted),
                          ),
                        ],
                      ),
                    ),
                    const StatusBadge(
                        label: '4.8',
                        color: JosiColors.warning,
                        softColor: JosiColors.warningSoft),
                  ],
                ),
                const SizedBox(height: 16),
                const _Timeline(labels: <String>[
                  'Rider accepted',
                  'Arriving at pickup',
                  'Trip in progress'
                ]),
                const SizedBox(height: 16),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: AppButton(
                        label: 'Call',
                        icon: Icons.call_rounded,
                        variant: AppButtonVariant.secondary,
                        onPressed: () {},
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: AppButton(
                        label: 'Help',
                        icon: Icons.chat_bubble_rounded,
                        variant: AppButtonVariant.secondary,
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const AppCard(
            child: Column(
              children: <Widget>[
                _SummaryRow(label: 'Fare', value: 'NGN 3,500'),
                _SummaryRow(
                    label: 'Payment status', value: 'Cash due at drop-off'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppButton(
            label: 'Complete trip preview',
            icon: Icons.check_circle_rounded,
            onPressed: () => context.go(AppRoutes.customerTripCompleted),
          ),
        ],
      ),
    );
  }
}

class CustomerTripCompletedScreen extends StatelessWidget {
  const CustomerTripCompletedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Trip completed',
      subtitle: 'Receipt and rating',
      child: AppScreenBody(
        children: <Widget>[
          const EmptyState(
            title: 'You arrived safely',
            message: 'NGN 3,500 cash payment recorded for this trip.',
            icon: Icons.check_circle_rounded,
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Rate Amina',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 10),
                Row(
                  children: <Widget>[
                    for (int index = 0; index < 5; index++)
                      const Icon(Icons.star_rate_rounded,
                          color: JosiColors.warning, size: 34),
                  ],
                ),
                const SizedBox(height: 12),
                const AppTextField(
                    label: 'Leave review',
                    hintText: 'Smooth ride and polite rider',
                    maxLines: 3),
                const SizedBox(height: 12),
                AppButton(
                  label: 'Download receipt',
                  icon: Icons.receipt_long_rounded,
                  variant: AppButtonVariant.secondary,
                  onPressed: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          AppButton(
            label: 'Back to home',
            icon: Icons.home_rounded,
            onPressed: () => context.go(AppRoutes.customerHome),
          ),
        ],
      ),
    );
  }
}

class CustomerTripsScreen extends ConsumerWidget {
  const CustomerTripsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Trip>> trips = ref.watch(tripsProvider);

    return AppScaffold(
      title: 'Trips',
      subtitle: 'History and active requests',
      navRole: AppNavRole.customer,
      selectedTab: 'trips',
      child: AppScreenBody(
        children: <Widget>[
          const _FilterRow(
              filters: <String>['All', 'Active', 'Completed', 'Cancelled']),
          const SizedBox(height: 14),
          trips.when(
            data: (List<Trip> values) => values.isEmpty
                ? const EmptyState(
                    title: 'No trips yet',
                    message: 'Your completed rides will appear here.')
                : Column(
                    children: values.map((Trip trip) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: TripCard(
                          trip: trip,
                          onTap: () => context
                              .go(AppRoutes.customerTripDetailPath(trip.id)),
                        ),
                      );
                    }).toList(),
                  ),
            error: (Object error, StackTrace stackTrace) => const ErrorState(
                title: 'Trips unavailable', message: 'Please try again later.'),
            loading: () => const SizedBox(
                height: 220, child: LoadingState(label: 'Loading trips')),
          ),
        ],
      ),
    );
  }
}

class CustomerTripDetailScreen extends ConsumerWidget {
  const CustomerTripDetailScreen({
    required this.tripId,
    super.key,
  });

  final String tripId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Trip>> trips = ref.watch(tripsProvider);

    return AppScaffold(
      title: 'Trip detail',
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
                  const AppMapPlaceholder(height: 220),
                  const SizedBox(height: 16),
                  AppCard(
                    child: Column(
                      children: <Widget>[
                        _SummaryRow(label: 'Rider', value: trip.riderName),
                        _SummaryRow(
                            label: 'Payment',
                            value: _paymentLabel(trip.paymentMethod)),
                        _SummaryRow(label: 'Distance', value: trip.distance),
                        _SummaryRow(label: 'Duration', value: trip.duration),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const AppCard(
                    child: _Timeline(labels: <String>[
                      'Requested',
                      'Accepted',
                      'Picked up',
                      'Completed'
                    ]),
                  ),
                  const SizedBox(height: 16),
                  AppButton(
                    label: 'Receipt',
                    icon: Icons.receipt_long_rounded,
                    variant: AppButtonVariant.secondary,
                    onPressed: () {},
                  ),
                ],
              );
            },
            error: (Object error, StackTrace stackTrace) => const ErrorState(
                title: 'Trip unavailable',
                message: 'This trip could not be loaded.'),
            loading: () => const SizedBox(
                height: 220, child: LoadingState(label: 'Loading trip')),
          ),
        ],
      ),
    );
  }
}

class CustomerWalletScreen extends ConsumerWidget {
  const CustomerWalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<WalletSummary> summary = ref.watch(customerWalletProvider);
    final AsyncValue<List<WalletTransaction>> transactions =
        ref.watch(walletTransactionsProvider);

    return AppScaffold(
      title: 'Wallet',
      subtitle: 'Payments and transactions',
      navRole: AppNavRole.customer,
      selectedTab: 'wallet',
      child: AppScreenBody(
        children: <Widget>[
          summary.when(
            data: (WalletSummary wallet) => WalletBalanceCard(
              title: 'Available balance',
              balance: wallet.balance,
              subtitle: 'Cash payment stays available for every route.',
            ),
            error: (Object error, StackTrace stackTrace) => const ErrorState(
                title: 'Wallet unavailable',
                message: 'Balance could not be loaded.'),
            loading: () => const SizedBox(
                height: 190, child: LoadingState(label: 'Loading wallet')),
          ),
          const SizedBox(height: 16),
          AppButton(
            label: 'Add money',
            icon: Icons.add_card_rounded,
            onPressed: () {},
          ),
          const SizedBox(height: 16),
          const SectionHeader(title: 'Payment methods'),
          const AppCard(
            child: Column(
              children: <Widget>[
                _SummaryRow(label: 'Cash', value: 'Available'),
                _SummaryRow(label: 'Wallet', value: 'Active'),
                _SummaryRow(label: 'Online payment', value: 'Placeholder'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const SectionHeader(title: 'Transactions'),
          transactions.when(
            data: (List<WalletTransaction> values) => Column(
              children: values.map((WalletTransaction transaction) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _TransactionCard(transaction: transaction),
                );
              }).toList(),
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

class CustomerProfileScreen extends ConsumerWidget {
  const CustomerProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<JosiUser> user = ref.watch(currentCustomerProvider);

    return AppScaffold(
      title: 'Profile',
      subtitle: 'Customer account',
      navRole: AppNavRole.customer,
      selectedTab: 'profile',
      child: AppScreenBody(
        children: <Widget>[
          user.when(
            data: (JosiUser value) => AppCard(
              child: Row(
                children: <Widget>[
                  ProfileAvatar(name: value.name, showEdit: true),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(value.name,
                            style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 4),
                        Text(value.email,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: JosiColors.muted)),
                        Text(value.phone,
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
                message: 'Customer profile could not be loaded.'),
            loading: () => const SizedBox(
                height: 120, child: LoadingState(label: 'Loading profile')),
          ),
          const SizedBox(height: 16),
          const _ProfileMenuItem(
              icon: Icons.edit_rounded,
              label: 'Edit profile',
              route: AppRoutes.editProfile),
          const _ProfileMenuItem(
              icon: Icons.bookmark_rounded,
              label: 'Saved addresses',
              route: AppRoutes.customerSelectLocation),
          const _ProfileMenuItem(
              icon: Icons.security_rounded,
              label: 'Security',
              route: AppRoutes.customerSettings),
          const _ProfileMenuItem(
              icon: Icons.support_agent_rounded,
              label: 'Support',
              route: AppRoutes.customerSupport),
          const _ProfileMenuItem(
              icon: Icons.settings_rounded,
              label: 'Settings',
              route: AppRoutes.customerSettings),
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

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({required this.action});

  final QuickAction action;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () => context.go(action.route),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(action.icon, color: JosiColors.red, size: 30),
          const Spacer(),
          Text(action.label, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}

class _PaymentChoiceChip extends StatelessWidget {
  const _PaymentChoiceChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (bool value) => onSelected(),
      selectedColor: JosiColors.redSoft,
      checkmarkColor: JosiColors.red,
      labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: selected ? JosiColors.red : JosiColors.ink,
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

class _Timeline extends StatelessWidget {
  const _Timeline({required this.labels});

  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: labels.map((String label) {
        final int index = labels.indexOf(label);
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Column(
              children: <Widget>[
                Icon(
                  index == labels.length - 1
                      ? Icons.radio_button_checked_rounded
                      : Icons.check_circle_rounded,
                  color: index == labels.length - 1
                      ? JosiColors.red
                      : JosiColors.success,
                  size: 22,
                ),
                if (index != labels.length - 1)
                  const SizedBox(
                      height: 26,
                      child: VerticalDivider(
                          color: JosiColors.line, thickness: 1.2)),
              ],
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 1),
                child:
                    Text(label, style: Theme.of(context).textTheme.bodyMedium),
              ),
            ),
          ],
        );
      }).toList(),
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
