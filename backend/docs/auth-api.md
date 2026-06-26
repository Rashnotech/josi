# Josi Auth And API Access Layer

## Auth Strategy

The mobile/API auth layer uses Laravel Sanctum personal access tokens. The service is named `JwtTokenService` and middleware alias is `jwt.auth` to match the product contract, but the issued tokens are Sanctum bearer tokens, not self-contained JWTs.

## Mail Configuration

Account creation and password reset notifications use Laravel notifications over SMTP. Configure these in `.env`; do not hardcode mailbox credentials:

```dotenv
MAIL_MAILER=smtp
MAIL_HOST=jositransport.com
MAIL_PORT=465
MAIL_USERNAME=support@jositransport.com
MAIL_PASSWORD=
MAIL_ENCRYPTION=ssl
MAIL_FROM_ADDRESS=support@jositransport.com
MAIL_FROM_NAME="${APP_NAME}"
```

Install Sanctum in the full Laravel runtime before running this API:

```powershell
composer require laravel/sanctum
php artisan migrate
```

## Middleware Aliases

Register these aliases in Laravel 10 `app/Http/Kernel.php` or Laravel 11 `bootstrap/app.php`:

- `jwt.auth` => `App\Http\Middleware\JwtAuthMiddleware`
- `active` => `App\Http\Middleware\EnsureUserIsActive`
- `role` => `App\Http\Middleware\RoleMiddleware`
- `permission` => `App\Http\Middleware\PermissionMiddleware`
- `approved.driver` => `App\Http\Middleware\EnsureDriverIsApproved`
- `approved.fleet` => `App\Http\Middleware\EnsureFleetIsApproved`

## Public Endpoints

`POST /api/v1/auth/register`

Required JSON fields: `first_name`, `email`, `phone`, `password`, `password_confirmation`, `role`.

Accepted public roles: `rider`, `courier`, `pack_owner`.

Optional JSON fields: `last_name`, `address`, `city`, `state`, `business_name`, `business_email`, `business_phone`, `business_address`, `registration_number`.

Creates a public Josi account, sends an account creation email, and returns role-aware metadata:

- `rider` and `courier`: creates a pending application profile, returns a bearer token, and returns `login_required: false` so mobile clients can continue into rider account setup.
- `pack_owner`: creates the account and pack/fleet record, stores `vehicle_count` when supplied, sends the account email, and returns `redirect_to: "/login"` plus `login_required: true`. The user signs in from the web app before opening the Laravel dashboard.

Example rider/courier payload:

```json
{
  "first_name": "John",
  "last_name": "Doe",
  "email": "john@example.com",
  "phone": "08000000000",
  "password": "password123",
  "password_confirmation": "password123",
  "role": "rider"
}
```

Example rider/courier response:

```json
{
  "status": true,
  "message": "Account created successfully. Continue your rider account setup.",
  "data": {
    "access_token": "sanctum_token_here",
    "token": "sanctum_token_here",
    "token_type": "bearer",
    "role": "rider",
    "login_required": false,
    "approval_status": "pending",
    "redirect_to": "/rider/application-status"
  }
}
```

Example pack owner response:

```json
{
  "status": true,
  "message": "Account created successfully. Please sign in to access your dashboard.",
  "data": {
    "redirect_to": "/login",
    "requires_dashboard": true,
    "login_required": true,
    "user": {
      "id": 1,
      "name": "John Doe",
      "email": "owner@example.com",
      "phone": "08000000000",
      "role": "pack_owner",
      "status": "active"
    }
  }
}
```

`POST /api/v1/auth/register/driver`

Required JSON fields: `first_name`, `last_name`, `name`, `email`, `phone`, `password`, `password_confirmation`, `address`, `city`, `state`.

Creates a user with role `driver`, active status, and pending driver profile.

`POST /api/v1/auth/register/fleet`

Required JSON fields: `name`, `email`, `phone`, `password`, `password_confirmation`, `business_name`, `business_phone`, `business_address`, `city`, `state`.

Optional JSON fields: `business_email`, `registration_number`.

Creates a user with role `fleet_owner`, active status, and pending fleet profile.

`POST /api/v1/auth/register/customer`

Required JSON fields: `name`, `email`, `phone`, `password`, `password_confirmation`.

Creates a user with role `customer` and active status.

`POST /api/v1/auth/login`

Required JSON fields: `identifier`, `password`.

`identifier` accepts email or phone. Frontend and mobile clients may also send `email_or_phone`; the request layer normalizes it to `identifier`. The backend detects the user role and returns permissions, profile data, `redirect_to`, `dashboard_url`, and `requires_dashboard`. Pack owner/admin web login should redirect to `dashboard_url`. Five failed attempts lock the identifier plus IP for 5 minutes.

Mobile API login must not boot Filament panel discovery. `AdminPanelProvider` registers only for `/admin` HTTP requests and explicit Filament console commands, while `FleetPanelProvider` registers only for `/dashboard` HTTP requests and explicit Filament console commands. Do not manually register Composer-discovered package providers in `config/app.php`. `filament/filament`, `livewire/livewire`, and `spatie/laravel-permission` are loaded by package discovery. Duplicate provider registration can make `php artisan serve` and `/api/v1/auth/login` hang during Laravel boot. `tests/Architecture/ApiLoginBootContractTest.ps1` verifies an empty login request reaches validation quickly instead of timing out during app boot.

If `/api/v1/auth/login` times out with `Maximum execution time of 30 seconds exceeded` while a fresh probe passes, the local `php artisan serve` process is stale. On Windows, find the process bound to port `8000` with `Get-NetTCPConnection -LocalPort 8000`, stop that PHP process, then restart Laravel with `php artisan optimize:clear` and `php artisan serve --host=127.0.0.1 --port=8000`. A healthy empty login request returns `422` validation quickly; it should not hang for 30 seconds.

`POST /api/v1/auth/forgot-password`

Required JSON fields: `email_or_phone`.

Always returns a generic success response. If the account exists, a hashed 6-digit reset code is stored and the plain code is emailed.

`POST /api/v1/auth/verify-reset-code`

Required JSON fields: `email_or_phone`, `code`.

Returns `verified: true` and a temporary `reset_token` when the code is valid. New clients can reset with the 6-digit `code`; older clients may still use `reset_token`.

`POST /api/v1/auth/reset-password`

Required JSON fields: `email_or_phone`, `code`, `password`, `password_confirmation`.

Updates the password, clears reset fields, and emails a password reset confirmation. `reset_token` is still accepted for backwards compatibility.

## Protected Auth Endpoints

All require `Authorization: Bearer <access_token>`.

- `POST /api/v1/auth/logout`
- `POST /api/v1/auth/refresh`
- `GET /api/v1/auth/me`
- `POST /api/v1/auth/change-password`

Refresh deletes the current Sanctum token and issues a new one.

Change password required JSON fields: `current_password`, `password`, `password_confirmation`.

## Customer Trip Matching Endpoints

All require role `customer`.

- `POST /api/v1/customer/trips`
- `GET /api/v1/customer/trips`
- `GET /api/v1/customer/trips/{trip}`
- `GET /api/v1/customer/trips/{trip}/available-riders`
- `POST /api/v1/customer/trips/{trip}/request-rider`
- `POST /api/v1/customer/trips/{trip}/cancel`
- `POST /api/v1/customer/trips/{trip}/review`

Trip requests create a zone-priced trip using the configured `ZonePrice.base_price`; the mobile app displays the returned `amount` as the payable fare.

Available riders returns approved rider profiles with active, verified bikes only. Busy, unavailable, and already assigned riders are excluded.

`POST /customer/trips/{trip}/request-rider` required JSON:

```json
{
  "rider_profile_id": 44
}
```

The endpoint assigns the selected rider, marks them busy, and returns:

```json
{
  "rider_notified": true,
  "trip": {
    "id": 99,
    "trip_status": "assigned",
    "rider_name": "Ayo Balogun",
    "rider_phone": "+2348000000004",
    "vehicle_label": "Red Bajaj Boxer",
    "plate_number": "JOS-123AB",
    "is_arrived_at_pickup": false
  }
}
```

The customer app should show the waiting state until `is_arrived_at_pickup` is `true`. That flag becomes true after the rider calls the driver arrival endpoint.

`POST /customer/trips/{trip}/cancel` optional JSON:

```json
{
  "reason": "Cancelled by customer"
}
```

The endpoint can cancel requested, assigned, accepted, or ongoing trips owned by the authenticated customer. It returns the updated trip payload with `trip_status: "cancelled"`. Completed or already cancelled trips return a validation error.

`POST /customer/trips/{trip}/review` required JSON:

```json
{
  "rating": 5,
  "review": "Fast pickup and careful riding."
}
```

`rating` must be from 1 to 5. `review` is optional and limited to 2000 characters.

## Laravel Dashboard Scaffold

`GET /dashboard` and `GET /admin` render the Laravel-side dashboard scaffold in `resources/views/dashboard/index.blade.php`.

The scaffold currently supports:

- `super_admin`
- `admin`
- `pack_owner`
- legacy `fleet_owner`

The web login stores the Sanctum token and writes a `josi_auth_token` browser cookie so the Laravel dashboard controller can resolve the user with `Laravel\Sanctum\PersonalAccessToken::findToken()`. This is a temporary bridge for the Filament dashboard. When Filament is installed, use the same role split for super admin, admin, and pack owner panels/resources.

## Driver Endpoints

All require role `rider`, `courier`, or `driver`.

- `GET /api/v1/driver/profile`
- `PUT /api/v1/driver/profile`
- `GET /api/v1/driver/application-status`
- `GET /api/v1/driver/onboarding`
- `POST /api/v1/driver/onboarding/profile-picture`
- `POST /api/v1/driver/onboarding/bank-account`
- `POST /api/v1/driver/onboarding/riding-details`
- `POST /api/v1/driver/onboarding/submit`
- `GET /api/v1/driver/trips`
- `GET /api/v1/driver/trips/{trip}`
- `POST /api/v1/driver/trips/{trip}/accept`
- `POST /api/v1/driver/trips/{trip}/decline`
- `POST /api/v1/driver/trips/{trip}/arrived`
- `GET /api/v1/driver/wallet`
- `POST /api/v1/driver/documents`
- `GET /api/v1/driver/documents`

Rider profile update accepts partial JSON fields: `first_name`, `last_name`, `phone`, `gender`, `date_of_birth`, `address`, `city`, `state`, `profile_photo`, and `license_number`. When `first_name`, `last_name`, or `phone` changes, the API also syncs the authenticated user summary returned by `/auth/me`.

Driver trip flow:

- `GET /driver/trips` returns assigned, accepted, ongoing, completed, and cancelled trips for the authenticated rider. Trip payloads include customer name/phone, fare amount, status, route addresses, requested/completed/cancelled timestamps, and vehicle labels.
- `POST /driver/trips/{trip}/accept` moves an assigned trip to `accepted`.
- `POST /driver/trips/{trip}/decline` releases an assigned trip back to `requested` and returns the rider to `online`.
- `POST /driver/trips/{trip}/arrived` records `started_at`, moves the trip to `ongoing`, and makes the customer payload return `is_arrived_at_pickup: true`.
- `GET /driver/wallet` returns summary totals and transaction rows from completed trips and rider cash-ledger remittance data.

Rider onboarding payloads:

```json
{
  "profile_photo": "uploads/riders/selfie.jpg"
}
```

```json
{
  "bank_name": "Josi Microfinance Bank",
  "account_name": "Amina Yusuf",
  "account_number": "0123456789"
}
```

```json
{
  "vehicle_type": "car",
  "brand": "Toyota",
  "model": "Corolla",
  "color": "White",
  "plate_number": "ABC 482 JK",
  "registration_number": "REG-2408-JR",
  "city": "Abuja",
  "state": "FCT"
}
```

## Fleet Endpoints

All require role `fleet_owner`.

- `GET /api/v1/fleet/profile`
- `PUT /api/v1/fleet/profile`
- `GET /api/v1/fleet/application-status`
- `POST /api/v1/fleet/vehicles`
- `GET /api/v1/fleet/vehicles`
- `POST /api/v1/fleet/documents`
- `GET /api/v1/fleet/documents`

## Customer Endpoints

All require role `customer`.

- `GET /api/v1/customer/profile`
- `PUT /api/v1/customer/profile`
- `GET /api/v1/customer/addresses`
- `POST /api/v1/customer/addresses`
- `GET /api/v1/customer/trips`
- `POST /api/v1/customer/trips`

Customer profile update accepts partial JSON fields: `name`, `email`, `phone`, and `gender`.

Customer saved address create requires `label` and `address`. Optional JSON fields: `floor`, `landmark`, `latitude`, `longitude`, `is_default`.

Customer trip request requires `pickup_address` and `destination_address`. Mobile clients should also send `pickup_latitude`, `pickup_longitude`, `destination_latitude`, `destination_longitude`, `payment_method`, and `service_type`. `service_type` accepts `ride` or `courier`. If zone IDs are not provided, the API resolves the closest active priced zone pair from backend zone data.

## Admin Endpoints

All require role `admin` or `super_admin`, plus the listed permission.

- `GET /api/v1/admin/users` requires `manage_all_users`
- `POST /api/v1/admin/users/create-admin` requires `super_admin` and `manage_admins`
- `GET /api/v1/admin/drivers` requires `manage_drivers`
- `GET /api/v1/admin/fleets` requires `manage_fleets`
- `GET /api/v1/admin/vehicles` requires `manage_vehicles`
- `GET /api/v1/admin/documents` requires `manage_documents`

Admin creation is never public.

## Example Responses

Success:

```json
{
  "status": true,
  "message": "Login successful",
  "data": {
    "access_token": "sanctum_token_here",
    "token": "sanctum_token_here",
    "token_type": "bearer",
    "expires_in": 3600,
    "redirect_to": "/rider/application-status",
    "dashboard_url": null,
    "requires_dashboard": false,
    "user": {
      "id": 1,
      "name": "John Doe",
      "email": "john@example.com",
      "phone": "08012345678",
      "role": "driver",
      "status": "active"
    },
    "role": "driver",
    "permissions": [
      "view_profile",
      "upload_documents",
      "view_application_status"
    ],
    "profile": {
      "application_status": "pending"
    }
  }
}
```

Validation error:

```json
{
  "status": false,
  "message": "Validation failed",
  "errors": {
    "email": [
      "The email has already been taken."
    ]
  }
}
```

Login lockout:

```json
{
  "status": false,
  "message": "Too many failed login attempts. Please try again in 5 minutes.",
  "errors": {}
}
```

Forgot password:

```json
{
  "status": true,
  "message": "If this account exists, a password reset code has been sent.",
  "data": {}
}
```

## RBAC Matrix

This skeleton uses Spatie-compatible `roles`, `permissions`, `model_has_roles`, `model_has_permissions`, and `role_has_permissions` tables. Once Composer is available, install `spatie/laravel-permission` and keep `RbacService` as the controller-facing boundary.

`super_admin`: `manage_all_users`, `manage_admins`, `manage_drivers`, `manage_fleets`, `manage_vehicles`, `manage_documents`, `manage_pricing`, `manage_trips`, `manage_payments`, `manage_cash_ledger`, `view_reports`, `manage_system_settings`.

`admin`: `manage_drivers`, `manage_fleets`, `manage_vehicles`, `manage_documents`, `manage_pricing`, `manage_trips`, `manage_payments`, `manage_cash_ledger`, `view_reports`.

`fleet_owner`: `view_own_fleet`, `update_own_fleet`, `manage_own_vehicles`, `view_own_drivers`, `upload_fleet_documents`, `view_fleet_application_status`.

`driver`: `view_profile`, `update_profile`, `upload_documents`, `view_application_status`, `view_assigned_trips`, `update_location`, `view_cash_ledger`.

`customer`: `view_profile`, `update_profile`, `create_trip`, `view_own_trips`, `make_payment`.

## Security Notes

- Passwords are hashed before storage.
- Password reset codes are hashed before storage.
- Reset codes expire after 10 minutes.
- Verification attempts are capped.
- Reset responses do not reveal whether an account exists.
- Email and phone are both unique in `users`.
- Tokens are invalidated on logout and refresh.
- Role and permission checks run on the backend.
- Document uploads store private storage paths, not raw file bytes.
- Sensitive auth/admin actions are written to `audit_logs`.
- Auth notification emails are deferred until after the API response, use plain Blade views instead of Markdown rendering, and SMTP uses `MAIL_TIMEOUT` with a 5 second default.

## Future Improvements

- Add Pest/PHPUnit feature tests once PHP and Composer are available.
- Add Laravel policies for ownership checks.
- Add email and phone verification flows.
- Add worker-backed notification queues for production email delivery.
- Add payment gateway verification adapters behind `PaymentService`.
- Add Filament resources after the API layer is stable.
