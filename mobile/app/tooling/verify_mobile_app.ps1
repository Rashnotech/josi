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
  "lib/core/constants/app_assets.dart",
  "lib/core/constants/app_routes.dart",
  "lib/core/router/app_router.dart",
  "lib/core/theme/josi_colors.dart",
  "lib/core/theme/josi_theme.dart",
  "lib/features/auth/auth_screens.dart",
  "lib/features/splash/splash_screen.dart",
  "assets/images/josi_log.png",
  "assets/images/josi-logo.jpeg",
  "assets/images/ep--arrow-left-bold.svg",
  "assets/images/flat-color-icons--google.svg",
  "assets/images/iconamoon--profile.svg",
  "assets/images/line-md--email.svg",
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

Assert-Contains "lib/core/constants/app_assets.dart" "josi_log\.png" "Splash logo asset must be registered."
Assert-Contains "lib/core/constants/app_assets.dart" "josi-logo\.jpeg" "Login logo asset must be registered."
Assert-Contains "lib/core/constants/app_assets.dart" "flat-color-icons--google\.svg" "Google SVG asset must be registered."
Assert-Contains "lib/core/constants/app_assets.dart" "line-md--email\.svg" "Email SVG asset must be registered."
Assert-Contains "lib/core/constants/app_assets.dart" "ep--arrow-left-bold\.svg" "Back SVG asset must be registered."
Assert-Contains "lib/core/constants/app_assets.dart" "uil--padlock\.svg" "Padlock SVG asset must be registered."
Assert-Contains "lib/core/constants/app_assets.dart" "material-symbols--bike-lane-rounded\.svg" "Rider SVG asset must be registered."

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
Assert-Contains "lib/features/auth/auth_screens.dart" "AppAssets\.loginLogo" "Login must use josi-logo.jpeg through AppAssets."
Assert-Contains "lib/features/auth/auth_screens.dart" "SvgPicture\.asset" "Auth screens must use flutter_svg assets."
Assert-Contains "lib/core/router/app_router.dart" "queryParameters\['role'\]" "Login route must read the selected role."
Assert-Contains "lib/core/constants/app_routes.dart" "loginFor" "Routes must expose role-aware login helper."

Assert-Contains "test/josi_ride_app_test.dart" "starts on red splash and advances to role selection" "Tests must cover splash-to-role flow."
Assert-Contains "test/josi_ride_app_test.dart" "customer role opens customer login" "Tests must cover customer login."
Assert-Contains "test/josi_ride_app_test.dart" "rider role opens rider login" "Tests must cover rider login."

Write-Host "OK: Josi first-run redline, SVG assets, design tokens, tests, and eval contract are present."
