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
    throw "Unexpected file exists: $RelativePath"
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
  "lib/src/app.dart",
  "lib/src/screens/splash_screen.dart",
  "lib/src/screens/sign_in_screen.dart",
  "lib/src/screens/home_screen.dart",
  "lib/src/theme/josi_theme.dart",
  "lib/src/theme/josi_colors.dart",
  "assets/images/josi-logo.png",
  "assets/fonts/Inter-Regular.ttf",
  "assets/fonts/Inter-Medium.ttf",
  "assets/fonts/Inter-SemiBold.ttf",
  "assets/fonts/Inter-Bold.ttf",
  "assets/fonts/Inter-ExtraBold.ttf",
  "assets/fonts/Inter-OFL.txt",
  "test/josi_ride_app_test.dart",
  "evals/design_contract.md"
)

foreach ($file in $requiredFiles) {
  Assert-FileExists $file
}

@(
  "assets/fonts/Urbanist-Regular.ttf",
  "assets/fonts/Urbanist-Medium.ttf",
  "assets/fonts/Urbanist-SemiBold.ttf",
  "assets/fonts/Urbanist-Bold.ttf",
  "assets/fonts/Urbanist-ExtraBold.ttf",
  "assets/fonts/Urbanist-OFL.txt"
) | ForEach-Object {
  Assert-FileMissing $_
}

Assert-MinBytes "assets/images/josi-logo.png" 100000
Assert-MinBytes "assets/fonts/Inter-Regular.ttf" 10000
Assert-MinBytes "assets/fonts/Inter-Medium.ttf" 10000
Assert-MinBytes "assets/fonts/Inter-SemiBold.ttf" 10000
Assert-MinBytes "assets/fonts/Inter-Bold.ttf" 10000
Assert-MinBytes "assets/fonts/Inter-ExtraBold.ttf" 10000

Assert-Contains "pubspec.yaml" "family:\s+Inter" "pubspec.yaml must register the Inter font family."
Assert-NotContains "pubspec.yaml" "Urbanist" "pubspec.yaml must not reference Urbanist."
Assert-Contains "pubspec.yaml" "assets/images/josi-logo\.png" "pubspec.yaml must bundle the Josi logo."
Assert-Contains "lib/src/theme/josi_colors.dart" "0xFFE50914" "Josi red must remain in the brand palette."
Assert-Contains "lib/src/theme/josi_colors.dart" "0xFF080808" "Josi black must remain in the brand palette."
Assert-Contains "lib/src/screens/splash_screen.dart" "SignInScreen\.routeName" "Splash screen must route to sign in."
Assert-Contains "lib/src/screens/splash_screen.dart" "JosiLogo" "Splash screen must render the Josi logo."
Assert-Contains "lib/src/screens/sign_in_screen.dart" "RideHomeScreen\.routeName" "Sign in must route to the ride home shell."
Assert-Contains "lib/src/screens/sign_in_screen.dart" "class _HeaderBrand" "Sign in must use a non-logo brand treatment."
Assert-NotContains "lib/src/screens/sign_in_screen.dart" "JosiLogo|josi-logo\.png" "Sign in must not render the Josi logo."
Assert-Contains "lib/src/screens/sign_in_screen.dart" "FilteringTextInputFormatter" "Phone input must stay constrained to phone digits."
Assert-Contains "lib/src/screens/home_screen.dart" "class _TopBrand" "Home must use a non-logo brand treatment."
Assert-NotContains "lib/src/screens/home_screen.dart" "JosiLogo|josi-logo\.png" "Home must not render the Josi logo."
Assert-Contains "lib/src/screens/home_screen.dart" "Where to\?" "Ride home must expose destination search."
Assert-Contains "test/josi_ride_app_test.dart" "starts on splash and advances to sign in" "Widget tests must cover splash-to-auth flow."
Assert-Contains "test/josi_ride_app_test.dart" "theme uses Josi brand color and Inter typography" "Tests must cover the design contract."
Assert-NotContains "test/josi_ride_app_test.dart" "Urbanist" "Tests must not reference Urbanist."

Write-Host "OK: Josi Ride mobile app source, assets, tests, and eval contract are present."
