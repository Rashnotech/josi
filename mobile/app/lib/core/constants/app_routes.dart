class AppRoutes {
  const AppRoutes._();

  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String roleSelection = '/role-selection';
  static const String login = '/login';
  static const String customerRegister = '/register/customer';
  static const String riderRegister = '/register/rider';
  static const String forgotPassword = '/forgot-password';
  static const String verifyResetCode = '/verify-reset-code';
  static const String resetPassword = '/reset-password';
  static const String editProfile = '/edit-profile';
  static const String fleetDashboard = '/fleet/dashboard';

  static const String customerHome = '/customer/home';
  static const String customerSelectLocation = '/customer/select-location';
  static const String customerManageAddress = '/customer/manage-address';
  static const String customerAddAddress = '/customer/add-address';
  static const String customerConfirmTrip = '/customer/confirm-trip';
  static const String customerSearchingRider = '/customer/searching-rider';
  static const String customerRideNotFound =
      '/customer/searching-rider?empty=true';
  static const String customerDriverDetails = '/customer/driver-details';
  static const String customerTripActive = '/customer/trip-active';
  static const String customerTripCompleted = '/customer/trip-completed';
  static const String customerTrips = '/customer/trips';
  static const String customerWallet = '/customer/wallet';
  static const String customerPaymentMethods = '/customer/payment-methods';
  static const String customerNotifications = '/customer/notifications';
  static const String customerProfile = '/customer/profile';
  static const String customerSupport = '/customer/support';
  static const String customerSettings = '/customer/settings';

  static const String riderHome = '/rider/home';
  static const String riderLocationAccess = '/rider/location-access';
  static const String riderApplicationStatus = '/rider/application-status';
  static const String riderProfileSetup = '/rider/profile-setup';
  static const String riderProfilePicture = '/rider/profile-picture';
  static const String riderBankAccountDetails = '/rider/bank-account-details';
  static const String riderVehicleSetup = '/rider/vehicle-setup';
  static const String riderProfileSetupUpdate =
      '$riderProfileSetup?mode=update';
  static const String riderBankAccountDetailsUpdate =
      '$riderBankAccountDetails?mode=update';
  static const String riderVehicleSetupUpdate =
      '$riderVehicleSetup?mode=update';
  static const String riderAvailableTrips = '/rider/available-trips';
  static const String riderTripRequest = '/rider/trip-request/:id';
  static const String riderActiveTrip = '/rider/active-trip/:id';
  static const String riderCollectCash = '/rider/collect-cash';
  static const String riderCancelRide = '/rider/cancel-ride';
  static const String riderTripCompleted = '/rider/trip-completed/:id';
  static const String riderTrips = '/rider/trips';
  static const String riderWallet = '/rider/wallet';
  static const String riderCashLedger = '/rider/cash-ledger';
  static const String riderNotifications = '/rider/notifications';
  static const String riderProfile = '/rider/profile';
  static const String riderSupport = '/rider/support';
  static const String riderSettings = '/rider/settings';

  static String loginFor(String role) => '$login?role=$role';

  static String forgotPasswordFor(String role) => '$forgotPassword?role=$role';

  static String verifyResetCodeFor(String role) =>
      '$verifyResetCode?role=$role';

  static String resetPasswordFor(String role) => '$resetPassword?role=$role';

  static String riderTripRequestPath(String id) => '/rider/trip-request/$id';

  static String riderActiveTripPath(String id) => '/rider/active-trip/$id';

  static String riderTripCompletedPath(String id) =>
      '/rider/trip-completed/$id';
}
