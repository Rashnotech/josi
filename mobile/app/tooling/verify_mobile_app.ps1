$ErrorActionPreference = "Stop"

$appRoot = Resolve-Path (Join-Path $PSScriptRoot "..")

function Assert-FileExists {
  param([string] $RelativePath)

  $path = Join-Path $appRoot $RelativePath
  if (-not (Test-Path -LiteralPath $path)) {
    throw "Missing required file: $RelativePath"
  }
}

function Assert-FileMissing {
  param([string] $RelativePath)

  $path = Join-Path $appRoot $RelativePath
  if (Test-Path -LiteralPath $path) {
    throw "Unexpected obsolete file exists: $RelativePath"
  }
}

function Assert-Contains {
  param(
    [string] $RelativePath,
    [string] $Pattern,
    [string] $Message
  )

  $path = Join-Path $appRoot $RelativePath
  $content = Get-Content -LiteralPath $path -Raw
  if ($content -notmatch $Pattern) {
    throw $Message
  }
}

function Assert-MinBytes {
  param(
    [string] $RelativePath,
    [int] $MinimumBytes
  )

  $path = Join-Path $appRoot $RelativePath
  $item = Get-Item -LiteralPath $path
  if ($item.Length -lt $MinimumBytes) {
    throw "File is smaller than expected: $RelativePath"
  }
}

$requiredFiles = @(
  "pubspec.yaml",
  "lib/main.dart",
  "lib/core/constants/app_routes.dart",
  "lib/core/mock/josi_mock_data.dart",
  "lib/core/mock/josi_models.dart",
  "lib/core/providers/app_providers.dart",
  "lib/core/repositories/repositories.dart",
  "lib/core/router/app_router.dart",
  "lib/core/theme/josi_colors.dart",
  "lib/core/theme/josi_theme.dart",
  "lib/core/widgets/app_components.dart",
  "lib/features/auth/auth_screens.dart",
  "lib/features/customer/customer_screens.dart",
  "lib/features/onboarding/onboarding_screen.dart",
  "lib/features/rider/rider_screens.dart",
  "lib/features/shared/shared_screens.dart",
  "lib/features/splash/splash_screen.dart",
  "assets/images/josi-logo.png",
  "assets/fonts/Inter-Regular.ttf",
  "assets/fonts/Inter-Medium.ttf",
  "assets/fonts/Inter-SemiBold.ttf",
  "assets/fonts/Inter-Bold.ttf",
  "assets/fonts/Inter-ExtraBold.ttf",
  "test/josi_ride_app_test.dart",
  "evals/design_contract.md"
)

foreach ($file in $requiredFiles) {
  Assert-FileExists $file
}

@(
  "lib/src/app.dart",
  "lib/src/screens/sign_in_screen.dart",
  "lib/src/screens/home_screen.dart",
  "lib/src/theme/josi_theme.dart"
) | ForEach-Object {
  Assert-FileMissing $_
}

Assert-MinBytes "assets/images/josi-logo.png" 100000
Assert-MinBytes "assets/fonts/Inter-Regular.ttf" 10000

Assert-Contains "pubspec.yaml" "go_router:\s+\^14\.8\.1" "pubspec.yaml must include GoRouter."
Assert-Contains "pubspec.yaml" "flutter_riverpod:\s+\^2\.6\.1" "pubspec.yaml must include Riverpod."
Assert-Contains "pubspec.yaml" "family:\s+Inter" "pubspec.yaml must register the Inter font family."

Assert-Contains "lib/main.dart" "ProviderScope" "main.dart must wrap the app in ProviderScope."
Assert-Contains "lib/main.dart" "MaterialApp\.router" "The app must use router-based navigation."
Assert-Contains "lib/core/theme/josi_theme.dart" "useMaterial3:\s+true" "The theme must use Material 3."
Assert-Contains "lib/core/theme/josi_colors.dart" "0xFFE50914" "Josi red must remain in the brand palette."

@(
  "splash",
  "onboarding",
  "role-selection",
  "login",
  "register/customer",
  "register/rider",
  "forgot-password",
  "verify-reset-code",
  "reset-password",
  "customer/home",
  "customer/book-trip",
  "customer/select-location",
  "customer/confirm-trip",
  "customer/searching-rider",
  "customer/trip-active",
  "customer/trip-completed",
  "customer/trips",
  "customer/trip-detail/:id",
  "customer/wallet",
  "customer/notifications",
  "customer/profile",
  "customer/support",
  "customer/settings",
  "rider/home",
  "rider/application-status",
  "rider/profile-setup",
  "rider/document-upload",
  "rider/vehicle-setup",
  "rider/available-trips",
  "rider/trip-request/:id",
  "rider/active-trip/:id",
  "rider/trip-completed/:id",
  "rider/trips",
  "rider/wallet",
  "rider/cash-ledger",
  "rider/notifications",
  "rider/profile",
  "rider/support",
  "rider/settings"
) | ForEach-Object {
  $escapedRoute = [regex]::Escape($_)
  Assert-Contains "lib/core/constants/app_routes.dart" $escapedRoute "Missing route path: $_"
}

@(
  "AppButton",
  "AppTextField",
  "AppPasswordField",
  "AppDropdown",
  "AppSearchField",
  "AppCard",
  "StatusBadge",
  "EmptyState",
  "LoadingState",
  "ErrorState",
  "SectionHeader",
  "TripCard",
  "VehicleCard",
  "WalletBalanceCard",
  "ProfileAvatar",
  "AppBottomNav",
  "AppScaffold",
  "AppMapPlaceholder",
  "DocumentUploadCard"
) | ForEach-Object {
  Assert-Contains "lib/core/widgets/app_components.dart" "class\s+$_\b" "Missing reusable component: $_"
}

@(
  "AuthRepository",
  "CustomerRepository",
  "RiderRepository",
  "TripRepository",
  "WalletRepository",
  "NotificationRepository"
) | ForEach-Object {
  Assert-Contains "lib/core/repositories/repositories.dart" "class\s+$_\b" "Missing placeholder repository: $_"
}

@(
  "authControllerProvider",
  "currentCustomerProvider",
  "currentRiderProvider",
  "riderProfileProvider",
  "tripsProvider",
  "customerWalletProvider",
  "riderWalletProvider",
  "notificationsProvider"
) | ForEach-Object {
  Assert-Contains "lib/core/providers/app_providers.dart" "$_" "Missing Riverpod provider: $_"
}

@(
  "CustomerHomeScreen",
  "CustomerBookTripScreen",
  "CustomerSelectLocationScreen",
  "CustomerConfirmTripScreen",
  "CustomerSearchingRiderScreen",
  "CustomerActiveTripScreen",
  "CustomerTripCompletedScreen",
  "CustomerTripsScreen",
  "CustomerTripDetailScreen",
  "CustomerWalletScreen",
  "CustomerProfileScreen"
) | ForEach-Object {
  Assert-Contains "lib/features/customer/customer_screens.dart" "class\s+$_\b" "Missing customer screen: $_"
}

@(
  "RiderHomeScreen",
  "RiderApplicationStatusScreen",
  "RiderProfileSetupScreen",
  "RiderDocumentUploadScreen",
  "RiderVehicleSetupScreen",
  "AvailableTripsScreen",
  "RiderTripRequestDetailScreen",
  "RiderActiveTripScreen",
  "RiderTripCompletedScreen",
  "RiderTripsScreen",
  "RiderWalletScreen",
  "RiderCashLedgerScreen",
  "RiderProfileScreen"
) | ForEach-Object {
  Assert-Contains "lib/features/rider/rider_screens.dart" "class\s+$_\b" "Missing rider screen: $_"
}

Assert-Contains "lib/features/shared/shared_screens.dart" "class\s+NotificationsScreen\b" "Missing shared notifications screen."
Assert-Contains "lib/features/shared/shared_screens.dart" "class\s+SupportScreen\b" "Missing shared support screen."
Assert-Contains "lib/features/shared/shared_screens.dart" "class\s+SettingsScreen\b" "Missing shared settings screen."
Assert-Contains "lib/features/shared/shared_screens.dart" "class\s+EditProfileScreen\b" "Missing edit profile screen."
Assert-Contains "lib/features/splash/splash_screen.dart" "assets/images/josi-logo\.png" "Splash screen must render the Josi logo asset."
Assert-Contains "lib/features/auth/auth_screens.dart" "Backend role detection is automatic" "Login must not ask for a role."
Assert-Contains "lib/core/router/app_router.dart" "GoRouter" "GoRouter must be configured."
Assert-Contains "lib/core/router/app_router.dart" "NotificationsScreen\(role:\s+AppNavRole\.customer\)" "Customer notifications route must use customer nav."
Assert-Contains "lib/core/router/app_router.dart" "NotificationsScreen\(role:\s+AppNavRole\.rider\)" "Rider notifications route must use rider nav."
Assert-Contains "test/josi_ride_app_test.dart" "customer bottom navigation opens wallet" "Widget tests must cover role-aware bottom navigation."
Assert-Contains "test/josi_ride_app_test.dart" "rider registration ends at application status checklist" "Widget tests must cover rider onboarding."

Write-Host "OK: Josi mobile app source, routes, design system, mock layer, tests, and eval contract are present."
