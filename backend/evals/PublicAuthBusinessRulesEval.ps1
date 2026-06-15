$ErrorActionPreference = 'Stop'

$root = Resolve-Path (Join-Path $PSScriptRoot '..')
$failures = New-Object System.Collections.Generic.List[string]

function Resolve-RepoPath([string] $relativePath) {
    return Join-Path $root $relativePath
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

Assert-Contains 'app/Http/Requests/Api/V1/Auth/RegisterRequest.php' "'email' => ['required', 'email', 'max:255', 'unique:users,email']" 'Registration enforces unique email'
Assert-Contains 'app/Http/Requests/Api/V1/Auth/RegisterRequest.php' "'phone' => ['required', 'string', 'max:30', 'unique:users,phone']" 'Registration enforces unique phone'
Assert-Contains 'app/Http/Requests/Api/V1/Auth/RegisterRequest.php' "Rule::in(UserRole::publicRegistrationValues())" 'Registration blocks admin roles'
Assert-Contains 'app/Http/Requests/Api/V1/Auth/RegisterRequest.php' "'vehicle_count' => ['required_if:role,'.UserRole::PackOwner->value, 'integer', 'min:1', 'max:10000']" 'Pack owner vehicle count validation'
Assert-Contains 'app/Services/RegistrationService.php' "'password' => Hash::make" 'Registration hashes passwords'
Assert-Contains 'app/Services/RegistrationService.php' 'sendAccountCreated' 'Registration sends account created notification'
Assert-Contains 'app/Services/RegistrationService.php' "'Account created successfully. Please check your email.'" 'Rider/courier response keeps user off dashboard'
Assert-Contains 'app/Services/RegistrationService.php' "'Account created successfully. Please sign in to access your dashboard.'" 'Pack owner response sends user to login'
Assert-Contains 'app/Services/RegistrationService.php' '$role->requiresDashboard()' 'Pack owner dashboard branch'
Assert-Contains 'app/Services/RegistrationService.php' "'login_required'" 'Pack owner registration requires login before dashboard'
Assert-Contains 'app/Services/AuthService.php' 'orWhere(''phone'', $identifier)' 'Login supports phone'
Assert-Contains 'app/Services/AuthService.php' 'where(''email'', $identifier)' 'Login supports email'
Assert-Contains 'app/Http/Requests/Api/V1/Auth/LoginRequest.php' 'email_or_phone' 'Login accepts frontend email_or_phone'
Assert-Contains 'app/Services/PasswordResetService.php' 'Hash::make($code)' 'Reset code stored hashed'
Assert-Contains 'app/Services/PasswordResetService.php' 'resetPasswordUsingCode' 'Reset password can consume code directly'
Assert-Contains 'app/Http/Controllers/Api/V1/ForgotPasswordController.php' 'If this account exists, a reset code has been sent.' 'Forgot password safe response'
Assert-Contains 'app/Http/Controllers/Api/V1/ForgotPasswordController.php' 'Invalid or expired reset code.' 'Invalid reset code error'
Assert-Contains 'app/Services/RbacService.php' "'redirect_to' =>" 'Auth payload has redirect path'
Assert-Contains 'app/Services/RbacService.php' "'dashboard_url' =>" 'Auth payload has Laravel dashboard URL'
Assert-Contains 'app/Services/RbacService.php' "'requires_dashboard' =>" 'Auth payload has dashboard flag'
Assert-Contains 'app/Providers/Filament/FleetPanelProvider.php' "->path('dashboard')" 'Filament fleet dashboard route exists'
Assert-Contains 'app/Providers/Filament/AdminPanelProvider.php' "->path('admin')" 'Filament admin dashboard route exists'
Assert-Contains 'app/Models/User.php' 'canAccessPanel' 'Filament dashboard role guard exists'
Assert-Contains 'app/Support/Filament/DashboardAccess.php' 'isStaff' 'Admin panel role guard'
Assert-Contains 'app/Support/Filament/DashboardAccess.php' 'isFleetOwner' 'Fleet panel role guard'

if ($failures.Count -gt 0) {
    Write-Host 'Public auth business rules eval failed:' -ForegroundColor Red
    foreach ($failure in $failures) {
        Write-Host " - $failure" -ForegroundColor Red
    }
    exit 1
}

Write-Host 'Public auth business rules eval passed.' -ForegroundColor Green
