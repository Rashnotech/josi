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

function Assert-NotContains {
  param(
    [string] $RelativePath,
    [string] $Pattern,
    [string] $Message
  )

  $path = Join-Path $appRoot $RelativePath
  $content = Get-Content -LiteralPath $path -Raw
  if ($content -match $Pattern) {
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
  "lib/core/constants/app_assets.dart",
  "lib/core/constants/app_routes.dart",
  "lib/core/router/app_router.dart",
  "lib/core/services/device_location_service.dart",
  "lib/core/theme/josi_colors.dart",
  "lib/core/theme/josi_theme.dart",
  "lib/features/auth/auth_screens.dart",
  "lib/features/splash/splash_screen.dart",
  "android/app/src/main/AndroidManifest.xml",
  "android/app/src/main/kotlin/com/example/josi_ride/MainActivity.kt",
  "assets/images/josi_log.png",
  "assets/images/josi-logo.jpeg",
  "assets/images/ep--arrow-left-bold.svg",
  "assets/images/flat-color-icons--google.svg",
  "assets/images/humbleicons--bike.svg",
  "assets/images/hugeicons--office.svg",
  "assets/images/iconamoon--profile.svg",
  "assets/images/line-md--email.svg",
  "assets/images/material-symbols--history-rounded.svg",
  "assets/images/material-symbols--bike-lane-rounded.svg",
  "assets/images/uil--padlock.svg",
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
  "assets/images/josi-logo.png",
  "lib/src/app.dart",
  "lib/src/screens/sign_in_screen.dart",
  "lib/src/screens/home_screen.dart",
  "lib/src/theme/josi_theme.dart"
) | ForEach-Object {
  Assert-FileMissing $_
}

Assert-MinBytes "assets/images/josi_log.png" 100000
Assert-MinBytes "assets/images/josi-logo.jpeg" 10000
Assert-MinBytes "assets/fonts/Inter-Regular.ttf" 10000

Assert-Contains "pubspec.yaml" "flutter_svg:\s+\^2\.3\.0" "pubspec.yaml must include flutter_svg."
Assert-Contains "pubspec.yaml" "go_router:\s+\^14\.8\.1" "pubspec.yaml must include GoRouter."
Assert-Contains "pubspec.yaml" "flutter_riverpod:\s+\^2\.6\.1" "pubspec.yaml must include Riverpod."
Assert-Contains "pubspec.yaml" "assets/images/" "pubspec.yaml must bundle the images folder."
Assert-Contains "pubspec.yaml" "family:\s+Inter" "pubspec.yaml must register the Inter font family."

Assert-Contains "lib/main.dart" "ProviderScope" "main.dart must wrap the app in ProviderScope."
Assert-Contains "lib/main.dart" "MaterialApp\.router" "The app must use router-based navigation."
Assert-Contains "lib/core/theme/josi_theme.dart" "useMaterial3:\s+true" "The theme must use Material 3."
Assert-Contains "lib/core/theme/josi_colors.dart" "0xFFE31837" "Josi red must match DESIGN.md primary."
Assert-Contains "lib/core/theme/josi_colors.dart" "0xFFF7F9FB" "Josi surface must match DESIGN.md background."
Assert-Contains "lib/core/theme/josi_colors.dart" "0xFF191C1E" "Josi text color must match DESIGN.md on-surface."
Assert-Contains "lib/core/theme/josi_theme.dart" "titleLarge:\s+TextStyle\(fontSize:\s+18" "Theme title text must use normal mobile sizing."
Assert-Contains "lib/core/theme/josi_theme.dart" "bodyMedium:\s+TextStyle\(fontSize:\s+14" "Theme body text must use normal mobile sizing."

Assert-Contains "lib/core/constants/app_assets.dart" "josi_log\.png" "Splash logo asset must be registered."
Assert-Contains "lib/core/constants/app_assets.dart" "josi-logo\.jpeg" "Login logo asset must be registered."
Assert-Contains "lib/core/constants/app_assets.dart" "flat-color-icons--google\.svg" "Google SVG asset must be registered."
Assert-Contains "lib/core/constants/app_assets.dart" "line-md--email\.svg" "Email SVG asset must be registered."
Assert-Contains "lib/core/constants/app_assets.dart" "ep--arrow-left-bold\.svg" "Back SVG asset must be registered."
Assert-Contains "lib/core/constants/app_assets.dart" "uil--padlock\.svg" "Padlock SVG asset must be registered."
Assert-Contains "lib/core/constants/app_assets.dart" "material-symbols--bike-lane-rounded\.svg" "Rider SVG asset must be registered."
Assert-Contains "lib/core/constants/app_assets.dart" "humbleicons--bike\.svg" "Ride search bike SVG asset must be registered."
Assert-Contains "lib/core/constants/app_assets.dart" "material-symbols--history-rounded\.svg" "Activity history SVG asset must be registered."
Assert-Contains "lib/core/constants/app_assets.dart" "hugeicons--office\.svg" "Office SVG asset must be registered."
Assert-Contains "lib/core/services/device_location_service.dart" "josi_ride/device_location" "Device location service must use the native GPS channel."
Assert-Contains "android/app/src/main/AndroidManifest.xml" "ACCESS_FINE_LOCATION" "Android manifest must request fine location permission."
Assert-Contains "android/app/src/main/AndroidManifest.xml" "ACCESS_COARSE_LOCATION" "Android manifest must request coarse location permission."
Assert-Contains "android/app/src/main/kotlin/com/example/josi_ride/MainActivity.kt" "LocationManager" "Android activity must resolve phone GPS location."

Assert-Contains "lib/features/splash/splash_screen.dart" "AppAssets\.splashLogo" "Splash must use josi_log.png through AppAssets."
Assert-Contains "lib/features/splash/splash_screen.dart" "backgroundColor:\s+JosiColors\.red" "Splash must have a red background."
Assert-Contains "lib/features/splash/splash_screen.dart" "AppRoutes\.roleSelection" "Unauthenticated splash must route to role selection."
Assert-Contains "lib/features/auth/auth_screens.dart" "Welcome to Josi Ride" "Role selection title must match the upload design."
Assert-Contains "lib/features/auth/auth_screens.dart" "Select your experience" "Role selection subtitle must match the upload design."
Assert-Contains "lib/features/auth/auth_screens.dart" "Continue as Customer" "Customer card must exist."
Assert-Contains "lib/features/auth/auth_screens.dart" "Continue as Rider" "Rider card must exist."
Assert-Contains "lib/features/auth/auth_screens.dart" "POWERED BY JOSI RIDE" "Role selection footer must exist."
Assert-Contains "lib/features/auth/auth_screens.dart" "Customer Login" "Customer login title must exist."
Assert-Contains "lib/features/auth/auth_screens.dart" "Rider Login" "Rider login title must exist."
Assert-Contains "lib/features/auth/auth_screens.dart" "Create Account" "Customer signup title must exist."
Assert-Contains "lib/features/auth/auth_screens.dart" "Join Josi Ride today" "Customer signup subtitle must exist."
Assert-Contains "lib/features/auth/auth_screens.dart" "Drive with Josi Ride" "Rider signup title must exist."
Assert-Contains "lib/features/auth/auth_screens.dart" "Start earning on your own schedule" "Rider signup subtitle must exist."
Assert-Contains "lib/features/auth/auth_screens.dart" "Vehicle Type" "Rider signup must include vehicle type."
Assert-Contains "lib/features/auth/auth_screens.dart" "Sign Up to Drive" "Rider signup submit button must exist."
Assert-Contains "lib/features/auth/auth_screens.dart" "AppAssets\.loginLogo" "Login must use josi-logo.jpeg through AppAssets."
Assert-Contains "lib/features/auth/auth_screens.dart" "SvgPicture\.asset" "Auth screens must use flutter_svg assets."
Assert-Contains "lib/features/auth/auth_screens.dart" "_SignupScaffold" "Signup screens must use the uploaded redline layout."
Assert-Contains "lib/features/auth/auth_screens.dart" "customer-register-screen" "Customer signup must expose a testable key."
Assert-Contains "lib/features/auth/auth_screens.dart" "rider-register-screen" "Rider signup must expose a testable key."
Assert-Contains "lib/core/router/app_router.dart" "queryParameters\['role'\]" "Login route must read the selected role."
Assert-Contains "lib/core/constants/app_routes.dart" "loginFor" "Routes must expose role-aware login helper."
Assert-Contains "lib/features/customer/customer_screens.dart" "customer-home-map" "Customer home must expose the full-screen map key."
Assert-Contains "lib/features/customer/customer_screens.dart" "DraggableScrollableSheet" "Customer home where-to panel must be draggable."
Assert-Contains "lib/features/customer/customer_screens.dart" "customer-where-to-sheet" "Customer home must expose the draggable where-to sheet key."
Assert-Contains "lib/features/customer/customer_screens.dart" "home-current-location-button" "Customer home current location must trigger GPS."
Assert-Contains "lib/features/customer/customer_screens.dart" "destination-location-field" "Destination field must be editable and testable."
Assert-Contains "lib/features/customer/customer_screens.dart" "destination-current-location-field" "Destination current location must trigger GPS."
Assert-Contains "lib/features/customer/customer_screens.dart" "EdgeInsets\.fromLTRB\(24,\s+5,\s+24,\s+28\)" "Destination screen top spacing must stay tightened."
Assert-Contains "lib/core/widgets/app_components.dart" "AppAssets\.history" "Customer Activity navigation must use the history SVG."
Assert-Contains "lib/features/customer/customer_screens.dart" "AppAssets\.office" "Customer Office tile must use the office SVG."
Assert-Contains "lib/features/customer/customer_screens.dart" "customer-activity-screen" "Customer Activity screen must expose the Bookings screen key."
Assert-Contains "lib/features/customer/customer_screens.dart" "Bookings" "Customer Activity screen must use the uploaded Bookings title."
Assert-Contains "lib/features/customer/customer_screens.dart" "activity-tab-active" "Bookings screen must expose the Active tab key."
Assert-Contains "lib/features/customer/customer_screens.dart" "activity-tab-completed" "Bookings screen must expose the Completed tab key."
Assert-Contains "lib/features/customer/customer_screens.dart" "activity-tab-cancelled" "Bookings screen must expose the Cancelled tab key."
Assert-Contains "lib/features/customer/customer_screens.dart" "Cancelled by Driver" "Cancelled bookings must show the uploaded driver-cancelled status."
Assert-Contains "lib/features/customer/customer_screens.dart" "Cancelled by You" "Cancelled bookings must show the uploaded user-cancelled status."
Assert-Contains "lib/features/customer/customer_screens.dart" "_BookingMiniMap" "Active bookings must include the uploaded map preview structure."
Assert-NotContains "lib/features/customer/customer_screens.dart" "History and active requests" "Old Activity trips subtitle must be removed."
Assert-Contains "lib/features/customer/customer_screens.dart" "customer-payment-methods-screen" "Destination must continue into the payment methods step."
Assert-Contains "lib/features/customer/customer_screens.dart" "Confirm Payment" "Payment methods screen must use the uploaded confirm payment action."
Assert-Contains "lib/features/customer/customer_screens.dart" "payment-wallet-option" "Payment methods screen must keep Wallet as a payment option."
Assert-NotContains "lib/features/customer/customer_screens.dart" "More Payment Options" "Payment methods screen must not include More Payment Options."
Assert-NotContains "lib/features/customer/customer_screens.dart" "Paypal" "Payment methods screen must not include Paypal."
Assert-NotContains "lib/features/customer/customer_screens.dart" "Apple Pay" "Payment methods screen must not include Apple Pay."
Assert-NotContains "lib/features/customer/customer_screens.dart" "Google Pay" "Payment methods screen must not include Google Pay."
Assert-Contains "lib/features/customer/customer_screens.dart" "destination-confirm-button" "Destination confirm action must remain testable."
Assert-Contains "lib/features/customer/customer_screens.dart" "height:\s+52" "Destination/payment/profile actions must use medium mobile button sizing."
Assert-Contains "lib/features/shared/shared_screens.dart" "profile-update-button" "Profile update action must remain testable."
Assert-Contains "lib/features/shared/shared_screens.dart" "height:\s+52" "Profile update button must use medium mobile sizing."
Assert-Contains "lib/features/customer/customer_screens.dart" "CustomerBottomNav\(selectedTab: 'rides'\)" "Destination screen must keep the Rides tab visibly selected."
Assert-Contains "lib/features/customer/customer_screens.dart" "searching-ride-bike-icon" "Searching ride state must use the bike SVG."
Assert-Contains "lib/features/customer/customer_screens.dart" "ride-map-bike-marker" "Ride search map must show bike markers."
Assert-Contains "lib/features/customer/customer_screens.dart" "request-ride-bottom-sheet" "Request ride details must be a draggable bottom sheet."
Assert-Contains "lib/features/customer/customer_screens.dart" "initialChildSize:\s+0\.31" "Ride found bottom sheet must be shorter and avoid empty bottom space."
Assert-Contains "lib/features/customer/customer_screens.dart" "DraggableScrollableSheet" "Ride request sheet must be draggable."
Assert-Contains "lib/features/customer/customer_screens.dart" "customer-active-trip-screen" "Customer active trip must expose a testable key."
Assert-Contains "lib/features/customer/customer_screens.dart" "Driver Arrived" "Customer active trip must match the uploaded Driver Arrived screen."
Assert-Contains "lib/features/customer/customer_screens.dart" "trip-preview-button" "Customer active trip must use Trip preview instead of Cancel Ride."
Assert-NotContains "lib/features/customer/customer_screens.dart" "Cancel Ride" "Customer screens must not show Cancel Ride."
Assert-Contains "lib/features/customer/customer_screens.dart" "customer-trip-completed-screen" "Customer completed trip must expose a testable key."
Assert-Contains "lib/features/customer/customer_screens.dart" "Rate Driver" "Customer completed trip must match the uploaded Rate Driver screen."
Assert-Contains "lib/features/customer/customer_screens.dart" "cash payment recorded for this trip" "Customer completed trip must keep the cash payment recorded message."
Assert-Contains "lib/features/customer/customer_screens.dart" "trip-rating-review-field" "Customer completed trip must include a detailed review field."
Assert-Contains "lib/features/customer/customer_screens.dart" "submit-trip-rating-button" "Customer completed trip must include the submitted rating action."
Assert-NotContains "lib/features/customer/customer_screens.dart" "You arrived safely" "Old completed trip empty state must be removed."
Assert-NotContains "lib/features/customer/customer_screens.dart" "Download receipt" "Old completed trip receipt action must be removed."
Assert-NotContains "lib/features/customer/customer_screens.dart" "CustomerWalletScreen" "Standalone customer wallet screen must be removed."
Assert-NotContains "lib/features/customer/customer_screens.dart" "CustomerBookTripScreen" "Redundant Book a trip screen must be removed."
Assert-NotContains "lib/features/customer/customer_screens.dart" "Book a trip" "Redundant Book a trip copy must be removed."
Assert-NotContains "lib/core/constants/app_routes.dart" "customerWallet" "Standalone customer wallet route must be removed."
Assert-NotContains "lib/core/constants/app_routes.dart" "customerBookTrip" "Redundant customer book-trip route must be removed."
Assert-NotContains "lib/core/router/app_router.dart" "customerBookTrip" "Router must not expose the redundant book-trip route."
Assert-NotContains "lib/core/mock/josi_mock_data.dart" "customerBookTrip" "Customer quick actions must route through destination instead of book-trip."

Assert-Contains "test/josi_ride_app_test.dart" "starts on red splash and advances to role selection" "Tests must cover splash-to-role flow."
Assert-Contains "test/josi_ride_app_test.dart" "customer role opens customer login" "Tests must cover customer login."
Assert-Contains "test/josi_ride_app_test.dart" "customer home map fills screen and where to sheet drags up" "Tests must cover the customer home full-screen map and draggable where-to sheet."
Assert-Contains "test/josi_ride_app_test.dart" "destination-location-field" "Tests must cover editable destination input."
Assert-Contains "test/josi_ride_app_test.dart" "josi_ride/device_location" "Tests must mock the native GPS channel."
Assert-Contains "test/josi_ride_app_test.dart" "customer fixed bottom navigation opens activity" "Tests must cover the customer Activity navigation."
Assert-Contains "test/josi_ride_app_test.dart" "Bookings" "Tests must cover the uploaded Bookings Activity screen."
Assert-Contains "test/josi_ride_app_test.dart" "activity-tab-completed" "Tests must cover the Completed booking tab."
Assert-Contains "test/josi_ride_app_test.dart" "Cancelled by Driver" "Tests must cover the Cancelled booking card state."
Assert-Contains "test/josi_ride_app_test.dart" "customer rides navigation opens destination instead of book trip" "Tests must cover removing the Book a trip screen from customer navigation."
Assert-Contains "test/josi_ride_app_test.dart" "customer-payment-methods-screen" "Tests must cover destination connecting to payment methods."
Assert-Contains "test/josi_ride_app_test.dart" "customer profile opens payment methods instead of wallet" "Tests must cover the removed customer wallet screen."
Assert-Contains "test/josi_ride_app_test.dart" "Confirm Payment" "Tests must cover the uploaded payment methods action."
Assert-Contains "test/josi_ride_app_test.dart" "find\.text\('More Payment Options'\), findsNothing" "Tests must cover removing more payment options."
Assert-Contains "test/josi_ride_app_test.dart" "searching-ride-bike-icon" "Tests must cover the bike icon on ride search."
Assert-Contains "test/josi_ride_app_test.dart" "request-ride-bottom-sheet" "Tests must cover the request ride bottom sheet."
Assert-Contains "test/josi_ride_app_test.dart" "customer-active-trip-screen" "Tests must cover the uploaded active trip screen."
Assert-Contains "test/josi_ride_app_test.dart" "Trip preview" "Tests must cover the renamed active trip action."
Assert-Contains "test/josi_ride_app_test.dart" "customer-trip-completed-screen" "Tests must cover the uploaded completed trip screen."
Assert-Contains "test/josi_ride_app_test.dart" "cash payment recorded for this trip" "Tests must cover the completed trip cash payment message."
Assert-Contains "test/josi_ride_app_test.dart" "rider role opens rider login" "Tests must cover rider login."
Assert-Contains "test/josi_ride_app_test.dart" "customer create account opens customer signup" "Tests must cover customer signup."
Assert-Contains "test/josi_ride_app_test.dart" "rider role opens rider login and create account reaches rider signup" "Tests must cover rider signup."
Assert-Contains "evals/design_contract.md" "draggable where-to bottom sheet" "Design eval must include the customer home map and draggable sheet contract."
Assert-Contains "evals/design_contract.md" "Bookings" "Design eval must include the uploaded Activity bookings tab menu."
Assert-Contains "evals/design_contract.md" "current location can fill from device GPS" "Design eval must include destination GPS behavior."
Assert-Contains "evals/design_contract.md" "obsolete Book a trip screen" "Design eval must require removing the redundant Book a trip screen."
Assert-Contains "evals/design_contract.md" "humbleicons bike SVG" "Design eval must require the bike search map and request sheet."
Assert-Contains "evals/design_contract.md" "normal mobile text sizing" "Design eval must require normal mobile text sizing."
Assert-Contains "evals/design_contract.md" "More Payment Options" "Design eval must require removing more payment options."
Assert-Contains "evals/design_contract.md" "Driver Arrived" "Design eval must require the uploaded active trip screen."
Assert-Contains "evals/design_contract.md" "Rate Driver" "Design eval must require the uploaded completed trip screen."

Write-Host "OK: Josi first-run redline, SVG assets, design tokens, tests, and eval contract are present."
