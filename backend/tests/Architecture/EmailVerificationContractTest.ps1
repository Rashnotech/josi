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
    'app/Models/User.php',
    'app/Services/EmailVerificationService.php',
    'app/Services/NotificationService.php',
    'app/Services/RegistrationService.php',
    'app/Services/RbacService.php',
    'app/Notifications/EmailVerificationCodeNotification.php',
    'app/Http/Controllers/Api/V1/EmailVerificationController.php',
    'app/Http/Requests/Api/V1/Auth/VerifyEmailCodeRequest.php',
    'app/Http/Kernel.php',
    'resources/views/emails/email-verification-code.blade.php',
    'routes/api.php',
    'tests/Feature/EmailVerificationTest.php'
) | ForEach-Object { Assert-FileExists $_ }

Assert-Contains 'app/Models/User.php' 'implements FilamentUser, MustVerifyEmail' 'User implements MustVerifyEmail'
Assert-Contains 'app/Models/User.php' 'function sendEmailVerificationNotification' 'User overrides the default link-based verification notification'
Assert-Contains 'app/Services/EmailVerificationService.php' 'function sendVerificationCode' 'Registration-time code send'
Assert-Contains 'app/Services/EmailVerificationService.php' 'function resendVerificationCode' 'User-triggered resend'
Assert-Contains 'app/Services/EmailVerificationService.php' 'function verifyCode' 'Code verification'
Assert-Contains 'app/Services/EmailVerificationService.php' 'MAX_CODE_ATTEMPTS' 'Attempt lockout'
Assert-Contains 'app/Services/NotificationService.php' 'sendEmailVerificationCode' 'Notification service dispatch method'
Assert-Contains 'app/Services/RegistrationService.php' 'emailVerificationService->sendVerificationCode' 'Registration hooks send the verification code'
Assert-Contains 'app/Services/RbacService.php' "'email_verified' =>" 'Auth payload exposes verification status'
Assert-Contains 'app/Http/Kernel.php' 'InvokeDeferredCallbacks::class' 'Deferred callbacks (defer()) are actually invoked after the response'
Assert-Contains 'routes/api.php' "'/email/verify'" 'Verify route registered'
Assert-Contains 'routes/api.php' "'/email/resend'" 'Resend route registered'
Assert-Contains 'routes/api.php' "'jwt.auth', 'active', 'verified', 'role:customer'" 'Customer routes gated behind email verification'
Assert-Contains 'routes/api.php' "'jwt.auth', 'active', 'verified', 'role:rider,courier,driver'" 'Driver routes gated behind email verification'
Assert-Contains 'routes/api.php' "'jwt.auth', 'active', 'verified', 'role:pack_owner,fleet_owner'" 'Fleet routes gated behind email verification'
Assert-Contains 'database/migrations/2026_07_23_000001_add_email_verification_fields_to_users_table.php' 'email_verification_code' 'Verification code columns migration'

if ($failures.Count -gt 0) {
    Write-Host 'Email verification contract test failed:' -ForegroundColor Red
    foreach ($failure in $failures) {
        Write-Host " - $failure" -ForegroundColor Red
    }
    exit 1
}

Write-Host 'Email verification contract test passed.' -ForegroundColor Green
