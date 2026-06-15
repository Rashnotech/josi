$ErrorActionPreference = "Stop"

$appRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$failures = New-Object System.Collections.Generic.List[string]

function Resolve-AppPath([string] $relativePath) {
  return Join-Path $appRoot $relativePath
}

function Assert-FileExists([string] $relativePath) {
  if (-not (Test-Path -LiteralPath (Resolve-AppPath $relativePath))) {
    $failures.Add("Missing file: $relativePath")
  }
}

function Assert-Contains([string] $relativePath, [string] $needle, [string] $label) {
  $path = Resolve-AppPath $relativePath
  if (-not (Test-Path -LiteralPath $path)) {
    $failures.Add("Cannot inspect missing file: $relativePath")
    return
  }

  $content = Get-Content -LiteralPath $path -Raw
  if (-not $content.Contains($needle)) {
    $failures.Add("$label missing in $relativePath")
  }
}

@(
  "lib/core/config/api_config.dart",
  "lib/core/services/api_client.dart",
  "lib/core/auth/token_storage.dart",
  "lib/core/repositories/repositories.dart",
  "lib/core/providers/app_providers.dart",
  "lib/features/auth/auth_screens.dart",
  "pubspec.yaml"
) | ForEach-Object { Assert-FileExists $_ }

Assert-Contains "pubspec.yaml" "flutter_secure_storage: ^10.3.1" "Secure storage dependency"
Assert-Contains "lib/core/config/api_config.dart" "JOSI_API_BASE_URL" "Dart define API base URL"
Assert-Contains "lib/core/services/api_client.dart" "dataFromEnvelope" "Laravel response envelope parsing"
Assert-Contains "lib/core/auth/token_storage.dart" "FlutterSecureStorage" "Secure token storage"
Assert-Contains "lib/core/repositories/repositories.dart" "/auth/login" "Login API call"
Assert-Contains "lib/core/repositories/repositories.dart" "/auth/register" "Public register API call"
Assert-Contains "lib/core/repositories/repositories.dart" "/auth/register/customer" "Customer register API call"
Assert-Contains "lib/core/repositories/repositories.dart" "/auth/forgot-password" "Forgot password API call"
Assert-Contains "lib/core/repositories/repositories.dart" "/auth/verify-reset-code" "Verify reset code API call"
Assert-Contains "lib/core/repositories/repositories.dart" "/auth/reset-password" "Reset password API call"
Assert-Contains "lib/core/repositories/repositories.dart" "/auth/me" "Session restore API call"
Assert-Contains "lib/core/repositories/repositories.dart" "/auth/logout" "Logout API call"
Assert-Contains "lib/core/providers/app_providers.dart" "apiClientProvider" "API provider"
Assert-Contains "lib/core/providers/app_providers.dart" "tokenStorageProvider" "Token storage provider"
Assert-Contains "lib/features/auth/auth_screens.dart" "registerRider(" "Rider registration submits form values"
Assert-Contains "lib/features/auth/auth_screens.dart" "role: widget.role" "Courier role support"
Assert-Contains "lib/features/auth/auth_screens.dart" "requestPasswordReset" "Forgot password screen calls repository"
Assert-Contains "lib/features/auth/auth_screens.dart" "verifyResetCode" "Verify code screen calls repository"
Assert-Contains "lib/features/auth/auth_screens.dart" "resetPassword" "Reset password screen calls repository"

if ($failures.Count -gt 0) {
  Write-Host "Mobile auth integration check failed:" -ForegroundColor Red
  foreach ($failure in $failures) {
    Write-Host " - $failure" -ForegroundColor Red
  }
  exit 1
}

Write-Host "OK: Mobile auth integration is wired to Laravel endpoints with secure token storage." -ForegroundColor Green
