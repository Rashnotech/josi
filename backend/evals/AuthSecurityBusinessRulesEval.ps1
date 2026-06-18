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

Assert-Contains 'app/Services/RegistrationService.php' 'UserRole::Driver' 'Driver registration sets driver role'
Assert-Contains 'app/Services/RegistrationService.php' 'UserRole::FleetOwner' 'Fleet registration sets fleet owner role'
Assert-Contains 'app/Services/RegistrationService.php' 'UserRole::Customer' 'Customer registration sets customer role'
Assert-Contains 'app/Services/RegistrationService.php' 'UserRole::Admin' 'Admin creation sets admin role internally'
Assert-Contains 'app/Services/RegistrationService.php' 'manage_admins' 'Admin creation requires manage_admins'
Assert-Contains 'app/Services/RegistrationService.php' 'Hash::make' 'Registration hashes passwords'
Assert-Contains 'app/Http/Controllers/Api/V1/AuthController.php' 'changePassword' 'Authenticated password change endpoint'
Assert-Contains 'app/Http/Controllers/Api/V1/AuthController.php' 'current_password' 'Password change requires current password'
Assert-Contains 'app/Http/Controllers/Api/V1/AuthController.php' 'Hash::check' 'Password change verifies current password'
Assert-Contains 'app/Http/Controllers/Api/V1/AuthController.php' 'Hash::make($data[''password''])' 'Password change hashes new password'

Assert-Contains 'app/Services/AuthService.php' 'findUserByIdentifier' 'Login identifier detection'
Assert-Contains 'app/Services/AuthService.php' "where('email', `$identifier)" 'Login checks email'
Assert-Contains 'app/Services/AuthService.php' "orWhere('phone', `$identifier)" 'Login checks phone'
Assert-Contains 'app/Services/AuthService.php' 'LoginLockedException' 'Login lockout exception path'
Assert-Contains 'app/Services/LoginAttemptService.php' 'MAX_ATTEMPTS = 5' 'Five failed login attempts'
Assert-Contains 'app/Services/LoginAttemptService.php' 'DECAY_SECONDS = 300' 'Five minute login lockout'
Assert-Contains 'app/Services/LoginAttemptService.php' 'RateLimiter' 'RateLimiter login protection'

Assert-Contains 'app/Services/PasswordResetService.php' 'Hash::make($code)' 'Reset code stored hashed'
Assert-Contains 'app/Services/PasswordResetService.php' 'CODE_EXPIRES_MINUTES = 10' 'Reset code expires after ten minutes'
Assert-Contains 'app/Services/PasswordResetService.php' 'MAX_CODE_ATTEMPTS = 5' 'Reset code attempt limit'
Assert-Contains 'app/Services/PasswordResetService.php' 'password_reset_token' 'Reset token storage'
Assert-Contains 'app/Services/PasswordResetService.php' 'hash_equals' 'Reset token hash comparison'
Assert-Contains 'app/Services/PasswordResetService.php' 'password_reset_code' 'Reset fields cleared after reset'

Assert-Contains 'app/Http/Controllers/Api/V1/ForgotPasswordController.php' 'If this account exists' 'Forgot password generic response'
Assert-Contains 'app/Notifications/AccountCreatedNotification.php' 'Account role:' 'Account created email includes role'
Assert-Contains 'app/Notifications/PasswordResetCodeNotification.php' 'This code expires in 10 minutes.' 'Reset email expiry notice'
Assert-Contains 'app/Notifications/PasswordResetSuccessfulNotification.php' 'password was changed' 'Password reset success email'
Assert-Contains 'app/Notifications/AccountCreatedNotification.php' "->view('emails.account-created'" 'Account created email uses plain Blade view'
Assert-Contains 'app/Notifications/PasswordResetCodeNotification.php' "->view('emails.password-reset-code'" 'Reset code email uses plain Blade view'
Assert-Contains 'app/Notifications/PasswordResetSuccessfulNotification.php' "->view('emails.password-reset-successful'" 'Reset success email uses plain Blade view'

Assert-Contains 'app/Http/Middleware/RoleMiddleware.php' 'Forbidden.' 'Role middleware returns 403'
Assert-Contains 'app/Http/Middleware/PermissionMiddleware.php' 'Forbidden.' 'Permission middleware returns 403'
Assert-Contains 'app/Http/Middleware/EnsureUserIsActive.php' 'Your account is not active.' 'Active user middleware'

$registrationController = Get-Content -LiteralPath (Resolve-RepoPath 'app/Http/Controllers/Api/V1/DriverRegistrationController.php') -Raw
if ($registrationController.Contains('Hash::make') -or $registrationController.Contains('User::create')) {
    $failures.Add('Driver registration controller contains business logic instead of using RegistrationService')
}

if ($failures.Count -gt 0) {
    Write-Host 'Auth security business rules eval failed:' -ForegroundColor Red
    foreach ($failure in $failures) {
        Write-Host " - $failure" -ForegroundColor Red
    }
    exit 1
}

Write-Host 'Auth security business rules eval passed.' -ForegroundColor Green
