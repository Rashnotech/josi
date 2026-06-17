$ErrorActionPreference = 'Stop'

function Resolve-RepoPath([string] $Path) {
    return Join-Path (Join-Path $PSScriptRoot '..') $Path
}

function Assert-Contains([string] $Path, [string] $Needle, [string] $Label) {
    $fullPath = Resolve-RepoPath $Path
    if (-not (Test-Path -LiteralPath $fullPath)) {
        throw "$Label missing file: $Path"
    }

    $content = Get-Content -LiteralPath $fullPath -Raw
    if (-not $content.Contains($Needle)) {
        throw "$Label missing expected text: $Needle"
    }
}

Assert-Contains 'routes/api.php' "Route::get('/onboarding'" 'Rider onboarding fetch route'
Assert-Contains 'routes/api.php' "Route::post('/onboarding/profile-picture'" 'Profile picture onboarding route'
Assert-Contains 'routes/api.php' "Route::post('/onboarding/bank-account'" 'Bank account onboarding route'
Assert-Contains 'routes/api.php' "Route::post('/onboarding/riding-details'" 'Riding details onboarding route'
Assert-Contains 'routes/api.php' "Route::post('/onboarding/submit'" 'Rider onboarding submit route'
Assert-Contains 'routes/api.php' "'role:rider,courier,driver'" 'Rider route role protection'
Assert-Contains 'app/Services/RegistrationService.php' "'login_required' => false" 'Rider public registration returns mobile session'
Assert-Contains 'app/Http/Requests/Api/V1/Auth/RegisterRequest.php' "'last_name' => ['nullable'" 'Single-name rider registration'
Assert-Contains 'app/Services/DriverOnboardingService.php' "'profile_picture_complete'" 'Profile picture completion flag'
Assert-Contains 'app/Services/DriverOnboardingService.php' "'bank_account_complete'" 'Bank account completion flag'
Assert-Contains 'app/Services/DriverOnboardingService.php' "'riding_details_complete'" 'Riding details completion flag'
Assert-Contains 'app/Services/DriverOnboardingService.php' 'ApplicationStatus::UnderReview' 'Submit moves rider to review'
Assert-Contains 'database/migrations/2026_06_17_000001_add_rider_onboarding_fields.php' 'bank_account_number' 'Bank account storage'
Assert-Contains 'database/migrations/2026_06_17_000001_add_rider_onboarding_fields.php' 'registration_number' 'Vehicle registration storage'
Assert-Contains 'docs/auth-api.md' 'POST /api/v1/driver/onboarding/submit' 'Auth docs list rider onboarding submit endpoint'

Write-Host 'Rider onboarding business rules eval passed.' -ForegroundColor Green
