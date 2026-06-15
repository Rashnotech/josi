$ErrorActionPreference = "Stop"

$webRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$failures = New-Object System.Collections.Generic.List[string]

function Resolve-WebPath([string] $relativePath) {
  return Join-Path $webRoot $relativePath
}

function Assert-FileExists([string] $relativePath) {
  if (-not (Test-Path -LiteralPath (Resolve-WebPath $relativePath))) {
    $failures.Add("Missing file: $relativePath")
  }
}

function Assert-Contains([string] $relativePath, [string] $needle, [string] $label) {
  $path = Resolve-WebPath $relativePath
  if (-not (Test-Path -LiteralPath $path)) {
    $failures.Add("Cannot inspect missing file: $relativePath")
    return
  }

  $content = Get-Content -LiteralPath $path -Raw
  if (-not $content.Contains($needle)) {
    $failures.Add("$label missing in $relativePath")
  }
}

function Assert-NotContains([string] $relativePath, [string] $needle, [string] $label) {
  $path = Resolve-WebPath $relativePath
  if (-not (Test-Path -LiteralPath $path)) {
    $failures.Add("Cannot inspect missing file: $relativePath")
    return
  }

  $content = Get-Content -LiteralPath $path -Raw
  if ($content.Contains($needle)) {
    $failures.Add("$label should not be present in $relativePath")
  }
}

@(
  "src/services/authApi.js",
  "src/auth/AuthContext.jsx",
  "src/components/AuthRegistrationForm.jsx",
  "src/pages/LoginPage.jsx",
  "src/pages/MobileAppContinuePage.jsx",
  "src/pages/ForgotPasswordPage.jsx",
  "src/pages/RiderPage.jsx",
  "src/pages/CourierPage.jsx",
  "src/pages/PackOwnerPage.jsx",
  "src/App.jsx",
  "public/favicon.png"
) | ForEach-Object { Assert-FileExists $_ }

Assert-Contains "src/services/authApi.js" "VITE_API_BASE_URL" "Web API base URL must come from Vite env"
Assert-Contains "src/services/authApi.js" "/auth/register" "Register endpoint client"
Assert-Contains "src/services/authApi.js" "/auth/login" "Login endpoint client"
Assert-Contains "src/services/authApi.js" "/auth/forgot-password" "Forgot password endpoint client"
Assert-Contains "src/services/authApi.js" "/auth/verify-reset-code" "Verify reset code endpoint client"
Assert-Contains "src/services/authApi.js" "/auth/reset-password" "Reset password endpoint client"
Assert-Contains "src/services/authApi.js" "/auth/me" "Session restore endpoint client"
Assert-Contains "src/services/authApi.js" "dashboardUrlFromResponse" "Web login must redirect dashboard users to Laravel."
Assert-Contains "src/services/authApi.js" "VITE_DASHBOARD_BASE_URL" "Dashboard redirect origin can be configured separately"
Assert-Contains "src/services/authApi.js" 'return "/admin";' "Admin users redirect to the Filament admin panel"
Assert-Contains "src/services/authApi.js" 'return "/dashboard";' "Fleet users redirect to the Filament fleet panel"
Assert-Contains "src/auth/AuthContext.jsx" "josi_auth_token" "Token persistence key"
Assert-Contains "src/auth/AuthContext.jsx" "writeDashboardCookie" "Auth provider must bridge the Laravel dashboard cookie."
Assert-Contains "src/auth/AuthContext.jsx" "fetchCurrentUser" "Auth provider restores session through /me"
Assert-Contains "src/components/AuthRegistrationForm.jsx" "role" "Registration form sends role"
Assert-Contains "src/components/AuthRegistrationForm.jsx" "password_confirmation" "Registration form sends password confirmation"
Assert-Contains "src/components/AuthRegistrationForm.jsx" "vehicle_count" "Pack owner registration must send vehicle count"
Assert-Contains "src/components/AuthRegistrationForm.jsx" "login_required" "Pack owner registration must redirect to login"
Assert-Contains "src/components/AuthRegistrationForm.jsx" 'navigate("/continue-in-mobile-app"' "Rider and courier registration must hand off to the mobile app"
Assert-NotContains "src/components/AuthRegistrationForm.jsx" 'name="city"' "Rider/courier registration city field"
Assert-NotContains "src/components/AuthRegistrationForm.jsx" 'name="state"' "Rider/courier registration state field"
Assert-NotContains "src/components/AuthRegistrationForm.jsx" 'name="address"' "Rider/courier registration address field"
Assert-Contains "src/auth/AuthContext.jsx" "email_or_phone" "Auth provider sends email_or_phone"
Assert-Contains "src/pages/ForgotPasswordPage.jsx" "verifyResetCode" "Forgot password page verifies code"
Assert-Contains "src/pages/ForgotPasswordPage.jsx" "resetPassword" "Forgot password page resets password"
Assert-Contains "src/App.jsx" "/continue-in-mobile-app" "Mobile app handoff route"
Assert-Contains "src/pages/MobileAppContinuePage.jsx" "Continue in the Josi mobile app" "Mobile app handoff page copy"
if (Test-Path -LiteralPath (Resolve-WebPath "src/pages/DashboardPage.jsx")) {
  $failures.Add("React dashboard page must not exist; dashboard belongs in Laravel.")
}
Assert-Contains "src/pages/RiderPage.jsx" 'role="rider"' "Rider page uses rider role"
Assert-Contains "src/pages/RiderPage.jsx" "driver_arrived.png" "Rider page app preview uses the driver arrived image"
Assert-NotContains "src/pages/RiderPage.jsx" "App image placeholder" "Rider page placeholder preview"
Assert-Contains "src/pages/CourierPage.jsx" 'role="courier"' "Courier page uses courier role"
Assert-Contains "src/pages/PackOwnerPage.jsx" 'role="pack_owner"' "Pack owner page uses pack_owner role"
Assert-Contains "index.html" 'href="/favicon.png"' "Web app favicon"
Assert-Contains "index.html" 'src="/favicon.png"' "Initial web loader logo uses public favicon"

if ($failures.Count -gt 0) {
  Write-Host "Web auth integration check failed:" -ForegroundColor Red
  foreach ($failure in $failures) {
    Write-Host " - $failure" -ForegroundColor Red
  }
  exit 1
}

Write-Host "OK: Web auth integration files, endpoints, dashboard redirects, mobile handoff, and role forms are present." -ForegroundColor Green
