import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/auth_screens.dart';
import '../../features/customer/customer_screens.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/rider/rider_screens.dart';
import '../../features/shared/shared_screens.dart';
import '../../features/splash/splash_screen.dart';
import '../constants/app_routes.dart';
import '../mock/josi_models.dart';
import '../providers/app_providers.dart';
import '../widgets/app_components.dart';

final Provider<GoRouter> appRouterProvider = Provider<GoRouter>((Ref ref) {
  final ValueNotifier<AuthSession> authState =
      ValueNotifier<AuthSession>(ref.read(authControllerProvider));
  ref
    ..listen<AuthSession>(authControllerProvider,
        (AuthSession? previous, AuthSession next) {
      authState.value = next;
    })
    ..onDispose(authState.dispose);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: authState,
    redirect: (BuildContext context, GoRouterState state) {
      final AuthSession session = authState.value;
      final String path = state.uri.path;
      final bool isCustomerRoute = path == AppRoutes.customerHome ||
          path == AppRoutes.editProfile ||
          path.startsWith('/customer/');
      final bool isRiderRoute = path.startsWith('/rider/');
      final bool isCustomerAuthRoute = (path == AppRoutes.login &&
              (state.uri.queryParameters['role'] ?? 'customer') ==
                  'customer') ||
          path == AppRoutes.customerRegister;

      if (session.isLoading) {
        return isCustomerRoute ? AppRoutes.splash : null;
      }

      final JosiUser? user = session.user;
      if (isCustomerRoute) {
        if (user == null) {
          return AppRoutes.loginFor('customer');
        }

        if (user.role != AppRole.customer) {
          return _homeForRole(user);
        }
      }

      if (isRiderRoute) {
        if (user == null) {
          return AppRoutes.loginFor('rider');
        }

        if (user.role != AppRole.rider) {
          return _homeForRole(user);
        }
      }

      if (isCustomerAuthRoute && user?.role == AppRole.customer) {
        return AppRoutes.customerHome;
      }

      return null;
    },
    routes: <RouteBase>[
      GoRoute(
          path: AppRoutes.splash,
          builder: (BuildContext context, GoRouterState state) =>
              const SplashScreen()),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (BuildContext context, GoRouterState state) =>
            const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.roleSelection,
        builder: (BuildContext context, GoRouterState state) =>
            const RoleSelectionScreen(),
      ),
      GoRoute(
          path: AppRoutes.login,
          builder: (BuildContext context, GoRouterState state) => LoginScreen(
              role: state.uri.queryParameters['role'] ?? 'customer')),
      GoRoute(
        path: AppRoutes.customerRegister,
        builder: (BuildContext context, GoRouterState state) =>
            const CustomerRegistrationScreen(),
      ),
      GoRoute(
        path: AppRoutes.riderRegister,
        builder: (BuildContext context, GoRouterState state) =>
            const RiderRegistrationScreen(),
      ),
      GoRoute(
        path: AppRoutes.courierRegister,
        builder: (BuildContext context, GoRouterState state) =>
            const RiderRegistrationScreen(role: 'courier'),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (BuildContext context, GoRouterState state) =>
            ForgotPasswordScreen(
                role: state.uri.queryParameters['role'] ?? 'customer'),
      ),
      GoRoute(
        path: AppRoutes.verifyResetCode,
        builder: (BuildContext context, GoRouterState state) =>
            VerifyResetCodeScreen(
          role: state.uri.queryParameters['role'] ?? 'customer',
          emailOrPhone: state.uri.queryParameters['identity'] ?? '',
        ),
      ),
      GoRoute(
        path: AppRoutes.resetPassword,
        builder: (BuildContext context, GoRouterState state) =>
            ResetPasswordScreen(
          role: state.uri.queryParameters['role'] ?? 'customer',
          emailOrPhone: state.uri.queryParameters['identity'] ?? '',
          code: state.uri.queryParameters['code'] ?? '',
        ),
      ),
      GoRoute(
        path: AppRoutes.editProfile,
        builder: (BuildContext context, GoRouterState state) =>
            const EditProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.fleetDashboard,
        builder: (BuildContext context, GoRouterState state) =>
            const FleetDashboardPlaceholderScreen(),
      ),
      GoRoute(
        path: AppRoutes.customerHome,
        builder: (BuildContext context, GoRouterState state) =>
            const CustomerHomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.customerSelectLocation,
        builder: (BuildContext context, GoRouterState state) =>
            const CustomerSelectLocationScreen(),
      ),
      GoRoute(
        path: AppRoutes.customerManageAddress,
        builder: (BuildContext context, GoRouterState state) =>
            const CustomerManageAddressScreen(),
      ),
      GoRoute(
        path: AppRoutes.customerAddAddress,
        builder: (BuildContext context, GoRouterState state) =>
            const CustomerAddAddressScreen(),
      ),
      GoRoute(
        path: AppRoutes.customerConfirmTrip,
        builder: (BuildContext context, GoRouterState state) =>
            const CustomerPaymentMethodsScreen(
          confirmRoute: AppRoutes.customerSearchingRider,
          backRoute: AppRoutes.customerSelectLocation,
          showTripSummary: true,
        ),
      ),
      GoRoute(
        path: AppRoutes.customerSearchingRider,
        builder: (BuildContext context, GoRouterState state) =>
            CustomerSearchingRiderScreen(
                showNotFound: state.uri.queryParameters['empty'] == 'true'),
      ),
      GoRoute(
        path: AppRoutes.customerDriverDetails,
        builder: (BuildContext context, GoRouterState state) =>
            const CustomerDriverDetailsScreen(),
      ),
      GoRoute(
        path: AppRoutes.customerTripActive,
        builder: (BuildContext context, GoRouterState state) =>
            const CustomerActiveTripScreen(),
      ),
      GoRoute(
        path: AppRoutes.customerTripCompleted,
        builder: (BuildContext context, GoRouterState state) =>
            const CustomerTripCompletedScreen(),
      ),
      GoRoute(
        path: AppRoutes.customerTrips,
        builder: (BuildContext context, GoRouterState state) =>
            const CustomerTripsScreen(),
      ),
      GoRoute(
        path: AppRoutes.customerWallet,
        builder: (BuildContext context, GoRouterState state) =>
            const CustomerWalletScreen(),
      ),
      GoRoute(
        path: AppRoutes.customerPaymentMethods,
        builder: (BuildContext context, GoRouterState state) =>
            const CustomerPaymentMethodsScreen(
                confirmRoute: AppRoutes.customerProfile),
      ),
      GoRoute(
        path: AppRoutes.customerNotifications,
        builder: (BuildContext context, GoRouterState state) {
          return const NotificationsScreen(role: AppNavRole.customer);
        },
      ),
      GoRoute(
        path: AppRoutes.customerProfile,
        builder: (BuildContext context, GoRouterState state) =>
            const CustomerProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.customerSupport,
        builder: (BuildContext context, GoRouterState state) =>
            const SupportScreen(role: AppNavRole.customer),
      ),
      GoRoute(
        path: AppRoutes.customerSettings,
        builder: (BuildContext context, GoRouterState state) =>
            const SettingsScreen(role: AppNavRole.customer),
      ),
      GoRoute(
        path: AppRoutes.riderHome,
        builder: (BuildContext context, GoRouterState state) =>
            const RiderHomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.riderLocationAccess,
        builder: (BuildContext context, GoRouterState state) =>
            const RiderLocationAccessScreen(),
      ),
      GoRoute(
        path: AppRoutes.riderApplicationStatus,
        builder: (BuildContext context, GoRouterState state) =>
            const RiderApplicationStatusScreen(),
      ),
      GoRoute(
        path: AppRoutes.riderProfileSetup,
        builder: (BuildContext context, GoRouterState state) =>
            RiderProfileSetupScreen(
                isUpdate: state.uri.queryParameters['mode'] == 'update'),
      ),
      GoRoute(
        path: AppRoutes.riderProfilePicture,
        builder: (BuildContext context, GoRouterState state) =>
            const RiderProfilePictureScreen(),
      ),
      GoRoute(
        path: AppRoutes.riderBankAccountDetails,
        builder: (BuildContext context, GoRouterState state) =>
            RiderBankAccountDetailsScreen(
                isUpdate: state.uri.queryParameters['mode'] == 'update'),
      ),
      GoRoute(
        path: AppRoutes.riderVehicleSetup,
        builder: (BuildContext context, GoRouterState state) =>
            RiderVehicleSetupScreen(
                isUpdate: state.uri.queryParameters['mode'] == 'update'),
      ),
      GoRoute(
        path: AppRoutes.riderAvailableTrips,
        builder: (BuildContext context, GoRouterState state) =>
            const AvailableTripsScreen(),
      ),
      GoRoute(
        path: AppRoutes.riderTripRequest,
        builder: (BuildContext context, GoRouterState state) {
          return RiderTripRequestDetailScreen(
              tripId: state.pathParameters['id'] ?? 'TRP-2408');
        },
      ),
      GoRoute(
        path: AppRoutes.riderActiveTrip,
        builder: (BuildContext context, GoRouterState state) {
          return RiderActiveTripScreen(
              tripId: state.pathParameters['id'] ?? 'TRP-2408');
        },
      ),
      GoRoute(
        path: AppRoutes.riderCollectCash,
        builder: (BuildContext context, GoRouterState state) =>
            const RiderCollectCashScreen(),
      ),
      GoRoute(
        path: AppRoutes.riderCancelRide,
        builder: (BuildContext context, GoRouterState state) =>
            const RiderCancelRideScreen(),
      ),
      GoRoute(
        path: AppRoutes.riderTripCompleted,
        builder: (BuildContext context, GoRouterState state) {
          return RiderTripCompletedScreen(
              tripId: state.pathParameters['id'] ?? 'TRP-2408');
        },
      ),
      GoRoute(
        path: AppRoutes.riderTrips,
        builder: (BuildContext context, GoRouterState state) =>
            const RiderTripsScreen(),
      ),
      GoRoute(
        path: AppRoutes.riderWallet,
        builder: (BuildContext context, GoRouterState state) =>
            const RiderWalletScreen(),
      ),
      GoRoute(
        path: AppRoutes.riderCashLedger,
        builder: (BuildContext context, GoRouterState state) =>
            const RiderCashLedgerScreen(),
      ),
      GoRoute(
        path: AppRoutes.riderNotifications,
        builder: (BuildContext context, GoRouterState state) {
          return const NotificationsScreen(role: AppNavRole.rider);
        },
      ),
      GoRoute(
        path: AppRoutes.riderProfile,
        builder: (BuildContext context, GoRouterState state) =>
            const RiderProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.riderSupport,
        builder: (BuildContext context, GoRouterState state) =>
            const SupportScreen(role: AppNavRole.rider),
      ),
      GoRoute(
        path: AppRoutes.riderSettings,
        builder: (BuildContext context, GoRouterState state) =>
            const SettingsScreen(role: AppNavRole.rider),
      ),
    ],
  );
});

String _homeForRole(JosiUser user) {
  return switch (user.role) {
    AppRole.customer => AppRoutes.customerHome,
    AppRole.rider => user.applicationStatus == RiderApplicationStatus.approved
        ? AppRoutes.riderHome
        : AppRoutes.riderApplicationStatus,
    AppRole.fleetOwner => AppRoutes.fleetDashboard,
  };
}
