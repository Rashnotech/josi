$ErrorActionPreference = 'Stop'

$root = Resolve-Path (Join-Path $PSScriptRoot '..\..')
$failures = New-Object System.Collections.Generic.List[string]

function Resolve-RepoPath([string] $relativePath) {
    return Join-Path $root $relativePath
}

function Assert-FileExists([string] $relativePath) {
    if (-not (Test-Path -LiteralPath (Resolve-RepoPath $relativePath))) {
        $failures.Add("Missing file: $relativePath")
    }
}

function Assert-Contains([string] $relativePath, [string] $needle, [string] $label) {
    $path = Resolve-RepoPath $relativePath
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
    'app/Enums/UserRole.php',
    'app/Http/Controllers/Api/V1/AuthController.php',
    'app/Http/Requests/Api/V1/Auth/RegisterRequest.php',
    'app/Models/Fleet.php',
    'app/Models/User.php',
    'app/Providers/Filament/AdminPanelProvider.php',
    'app/Providers/Filament/FleetPanelProvider.php',
    'app/Support/Filament/DashboardAccess.php',
    'app/Services/RegistrationService.php',
    'app/Services/JwtTokenService.php',
    'app/Services/RbacService.php',
    'app/Services/PasswordResetService.php',
    'app/Notifications/AccountCreatedNotification.php',
    'routes/api.php',
    'routes/web.php',
    'docs/auth-api.md'
) | ForEach-Object { Assert-FileExists $_ }

Assert-Contains 'routes/api.php' "Route::post('/register', [AuthController::class, 'register'])" 'General public register route'
Assert-Contains 'app/Http/Controllers/Api/V1/AuthController.php' 'RegisterRequest' 'General register request usage'
Assert-Contains 'app/Http/Requests/Api/V1/Auth/RegisterRequest.php' 'UserRole::publicRegistrationValues()' 'Public role allow-list validation'
Assert-Contains 'app/Enums/UserRole.php' "case Rider = 'rider'" 'Rider role enum'
Assert-Contains 'app/Enums/UserRole.php' "case Courier = 'courier'" 'Courier role enum'
Assert-Contains 'app/Enums/UserRole.php' "case PackOwner = 'pack_owner'" 'Pack owner role enum'
Assert-Contains 'app/Enums/UserRole.php' 'publicRegistrationValues' 'Public registration role list'
Assert-Contains 'app/Services/RbacService.php' "'pack_owner'" 'Pack owner permissions'
Assert-Contains 'app/Services/RbacService.php' "'courier'" 'Courier permissions'
Assert-Contains 'app/Services/RbacService.php' "'rider'" 'Rider permissions'
Assert-Contains 'app/Services/RbacService.php' 'redirectPathForUser' 'Role redirect payload'
Assert-Contains 'app/Services/JwtTokenService.php' "'token' =>" 'Token alias for frontend clients'
Assert-Contains 'app/Services/RegistrationService.php' 'registerPublicAccount' 'General registration service method'
Assert-Contains 'app/Services/RegistrationService.php' 'createRiderOrCourierProfile' 'Rider and courier profile creation'
Assert-Contains 'app/Services/RegistrationService.php' 'createPackOwnerFleet' 'Pack owner fleet creation'
Assert-Contains 'app/Services/RegistrationService.php' "'vehicle_count' =>" 'Pack owner vehicle count storage'
Assert-Contains 'app/Services/RegistrationService.php' "'requires_dashboard'" 'Registration dashboard flag'
Assert-Contains 'app/Services/RegistrationService.php' "'login_required'" 'Pack owner registration login-required flag'
Assert-Contains 'app/Models/Fleet.php' "'vehicle_count'" 'Fleet model accepts vehicle count'
Assert-Contains 'app/Http/Requests/Api/V1/Auth/RegisterRequest.php' "'vehicle_count'" 'Register request validates vehicle count'
Assert-Contains 'app/Services/PasswordResetService.php' 'resetPasswordUsingCode' 'Code-based password reset'
Assert-Contains 'app/Http/Requests/Api/V1/Auth/ForgotPasswordRequest.php' 'email_or_phone' 'Forgot password accepts email_or_phone'
Assert-Contains 'app/Http/Requests/Api/V1/Auth/ResetPasswordRequest.php' 'required_without:reset_token' 'Reset accepts code without reset token'
Assert-Contains 'app/Notifications/AccountCreatedNotification.php' 'We will notify you when the next step is available.' 'Rider/courier account email copy'
Assert-Contains 'app/Notifications/AccountCreatedNotification.php' 'You can now access your dashboard.' 'Pack owner account email copy'
Assert-Contains 'app/Providers/Filament/AdminPanelProvider.php' "->path('admin')" 'Filament admin panel path'
Assert-Contains 'app/Providers/Filament/FleetPanelProvider.php' "->path('dashboard')" 'Filament fleet panel path'
Assert-Contains 'app/Models/User.php' 'implements FilamentUser' 'User can access Filament panels'
Assert-Contains 'app/Models/User.php' 'canAccessPanel' 'User panel access guard'
Assert-Contains 'app/Support/Filament/DashboardAccess.php' 'canAccessPanel' 'Dashboard role guard service'
Assert-Contains 'app/Support/Filament/DashboardAccess.php' 'isFleetOwner' 'Fleet owner dashboard guard'

if ($failures.Count -gt 0) {
    Write-Host 'Public auth contract test failed:' -ForegroundColor Red
    foreach ($failure in $failures) {
        Write-Host " - $failure" -ForegroundColor Red
    }
    exit 1
}

Write-Host 'Public auth contract test passed.' -ForegroundColor Green
