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

$requiredFiles = @(
    'routes/api.php',
    'app/Http/Controllers/Api/V1/AuthController.php',
    'app/Http/Controllers/Api/V1/DriverRegistrationController.php',
    'app/Http/Controllers/Api/V1/FleetRegistrationController.php',
    'app/Http/Controllers/Api/V1/CustomerRegistrationController.php',
    'app/Http/Controllers/Api/V1/ForgotPasswordController.php',
    'app/Http/Controllers/Api/V1/DriverProfileController.php',
    'app/Http/Controllers/Api/V1/FleetProfileController.php',
    'app/Http/Controllers/Api/V1/CustomerProfileController.php',
    'app/Http/Controllers/Api/V1/CustomerAddressController.php',
    'app/Http/Controllers/Api/V1/CustomerTripController.php',
    'app/Http/Controllers/Api/V1/AdminUserController.php',
    'app/Http/Requests/Api/V1/Auth/RegisterDriverRequest.php',
    'app/Http/Requests/Api/V1/Auth/RegisterFleetRequest.php',
    'app/Http/Requests/Api/V1/Auth/RegisterCustomerRequest.php',
    'app/Http/Requests/Api/V1/Auth/LoginRequest.php',
    'app/Http/Requests/Api/V1/Auth/ForgotPasswordRequest.php',
    'app/Http/Requests/Api/V1/Auth/VerifyResetCodeRequest.php',
    'app/Http/Requests/Api/V1/Auth/ResetPasswordRequest.php',
    'app/Http/Requests/Api/V1/Admin/CreateAdminRequest.php',
    'app/Services/AuthService.php',
    'app/Services/RegistrationService.php',
    'app/Services/JwtTokenService.php',
    'app/Services/PasswordResetService.php',
    'app/Services/LoginAttemptService.php',
    'app/Services/RbacService.php',
    'app/Services/NotificationService.php',
    'app/Models/CustomerSavedAddress.php',
    'app/Http/Middleware/JwtAuthMiddleware.php',
    'app/Http/Middleware/RoleMiddleware.php',
    'app/Http/Middleware/PermissionMiddleware.php',
    'app/Http/Middleware/EnsureUserIsActive.php',
    'app/Http/Middleware/EnsureDriverIsApproved.php',
    'app/Http/Middleware/EnsureFleetIsApproved.php',
    'app/Notifications/AccountCreatedNotification.php',
    'app/Notifications/PasswordResetCodeNotification.php',
    'app/Notifications/PasswordResetSuccessfulNotification.php',
    'resources/views/emails/account-created.blade.php',
    'resources/views/emails/password-reset-code.blade.php',
    'resources/views/emails/password-reset-successful.blade.php',
    'database/seeders/RbacSeeder.php',
    'docs/auth-api.md'
)

foreach ($file in $requiredFiles) {
    Assert-FileExists $file
}

$routes = @{
    'POST /api/v1/auth/register/driver' = "Route::post('/register/driver'"
    'POST /api/v1/auth/register/fleet' = "Route::post('/register/fleet'"
    'POST /api/v1/auth/register/customer' = "Route::post('/register/customer'"
    'POST /api/v1/auth/login' = "Route::post('/login'"
    'POST /api/v1/auth/logout' = "Route::post('/logout'"
    'POST /api/v1/auth/refresh' = "Route::post('/refresh'"
    'GET /api/v1/auth/me' = "Route::get('/me'"
    'POST /api/v1/auth/change-password' = "Route::post('/change-password'"
    'POST /api/v1/auth/forgot-password' = "Route::post('/forgot-password'"
    'POST /api/v1/auth/verify-reset-code' = "Route::post('/verify-reset-code'"
    'POST /api/v1/auth/reset-password' = "Route::post('/reset-password'"
    'PUT /api/v1/customer/profile' = "Route::put('/profile', [CustomerProfileController::class, 'update']"
    'GET /api/v1/customer/addresses' = "Route::get('/addresses', [CustomerAddressController::class, 'index']"
    'POST /api/v1/customer/addresses' = "Route::post('/addresses', [CustomerAddressController::class, 'store']"
    'GET /api/v1/customer/trips' = "Route::get('/trips', [CustomerTripController::class, 'index']"
    'POST /api/v1/customer/trips' = "Route::post('/trips', [CustomerTripController::class, 'store']"
    'POST /api/v1/admin/users/create-admin' = "Route::post('/users/create-admin'"
}

foreach ($entry in $routes.GetEnumerator()) {
    Assert-Contains 'routes/api.php' $entry.Value $entry.Key
}

Assert-Contains 'routes/api.php' "'jwt.auth'" 'Protected auth route middleware'
Assert-Contains 'routes/api.php' "'role:rider,courier,driver'" 'Driver role route protection'
Assert-Contains 'routes/api.php' "'role:pack_owner,fleet_owner'" 'Fleet owner role route protection'
Assert-Contains 'routes/api.php' "'role:customer'" 'Customer route protection'
Assert-Contains 'routes/api.php' "'permission:create_trip'" 'Customer trip create permission route protection'
Assert-Contains 'routes/api.php' "'permission:update_profile'" 'Customer profile/address update permission route protection'
Assert-Contains 'routes/api.php' "'role:super_admin'" 'Super admin create-admin route protection'
Assert-Contains 'routes/api.php' "'permission:manage_admins'" 'Create admin permission route protection'

Assert-Contains 'app/Models/User.php' 'use HasApiTokens' 'Sanctum HasApiTokens on User model'
Assert-Contains 'app/Models/User.php' 'password_reset_code' 'User reset code fillable/hidden'
Assert-Contains 'app/Models/User.php' 'last_login_at' 'User last login cast/fillable'
Assert-Contains 'app/Models/User.php' 'function savedAddresses' 'User saved addresses relationship'
Assert-Contains 'app/Models/User.php' "'gender'" 'User gender fillable'
Assert-Contains 'app/Models/Trip.php' "'service_type'" 'Trip service type fillable'

Assert-Contains 'database/migrations/2026_06_04_000001_create_users_table.php' "string('phone')->unique()" 'Phone unique in users migration'
Assert-Contains 'database/migrations/2026_06_04_000001_create_users_table.php' 'phone_verified_at' 'Phone verified timestamp'
Assert-Contains 'database/migrations/2026_06_04_000001_create_users_table.php' 'password_reset_code' 'Password reset code column'
Assert-Contains 'database/migrations/2026_06_04_000015_create_personal_access_tokens_table.php' 'personal_access_tokens' 'Sanctum token table'
Assert-Contains 'database/migrations/2026_06_04_000016_create_roles_table.php' "Schema::create('roles'" 'Roles table'
Assert-Contains 'database/migrations/2026_06_04_000017_create_permissions_table.php' "Schema::create('permissions'" 'Permissions table'
Assert-Contains 'database/migrations/2026_06_04_000018_create_permission_role_table.php' "Schema::create('role_has_permissions'" 'Spatie role permission pivot'
Assert-Contains 'database/migrations/2026_06_04_000019_create_role_user_table.php' "Schema::create('model_has_roles'" 'Spatie model roles pivot'
Assert-Contains 'database/migrations/2026_06_04_000020_create_model_has_permissions_table.php' "Schema::create('model_has_permissions'" 'Spatie model permissions pivot'
Assert-Contains 'database/migrations/2026_06_18_000001_create_customer_saved_addresses_table.php' "Schema::create('customer_saved_addresses'" 'Customer saved addresses table'
Assert-Contains 'database/migrations/2026_06_18_000002_add_gender_to_users_table.php' "string('gender'" 'Customer profile gender column'
Assert-Contains 'database/migrations/2026_06_18_000003_add_service_type_to_trips_table.php' "string('service_type'" 'Customer trip service type column'

Assert-Contains 'app/Services/RbacService.php' "'manage_admins'" 'Super admin permission matrix'
Assert-Contains 'app/Services/RbacService.php' "'upload_documents'" 'Driver permission matrix'
Assert-Contains 'app/Services/RbacService.php' "'make_payment'" 'Customer permission matrix'
Assert-Contains 'app/Services/RbacService.php' "'gender' =>" 'Auth/customer payload includes gender'
Assert-Contains 'app/Http/Controllers/Api/V1/CustomerAddressController.php' "'address' => ['required'" 'Customer address validates required address'
Assert-Contains 'app/Http/Controllers/Api/V1/CustomerTripController.php' "'service_type' =>" 'Customer trip validates service type'
Assert-Contains 'app/Services/TripService.php' "'service_type'" 'Trip service persists service type'
Assert-Contains 'app/Services/NotificationService.php' 'defer(function ()' 'Auth notifications run after API response'
Assert-Contains 'app/Services/NotificationService.php' 'Log::warning' 'Auth notification failures are logged without breaking auth'
Assert-Contains 'config/mail.php' "env('MAIL_TIMEOUT', 5)" 'SMTP mailer has finite timeout'

if ($failures.Count -gt 0) {
    Write-Host 'Auth API foundation test failed:' -ForegroundColor Red
    foreach ($failure in $failures) {
        Write-Host " - $failure" -ForegroundColor Red
    }
    exit 1
}

Write-Host 'Auth API foundation test passed.' -ForegroundColor Green
