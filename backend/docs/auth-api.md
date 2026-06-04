# Josi Auth And API Access Layer

## Auth Strategy

The mobile/API auth layer uses Laravel Sanctum personal access tokens. The service is named `JwtTokenService` and middleware alias is `jwt.auth` to match the product contract, but the issued tokens are Sanctum bearer tokens, not self-contained JWTs.

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

`identifier` accepts email or phone. The backend detects the user role and returns permissions and profile data. Five failed attempts lock the identifier plus IP for 5 minutes.

`POST /api/v1/auth/forgot-password`

Required JSON fields: `identifier`.

Always returns a generic success response. If the account exists, a hashed 6-digit reset code is stored and the plain code is emailed.

`POST /api/v1/auth/verify-reset-code`

Required JSON fields: `identifier`, `code`.

Returns a temporary `reset_token` when the code is valid.

`POST /api/v1/auth/reset-password`

Required JSON fields: `identifier`, `reset_token`, `password`, `password_confirmation`.

Updates the password, clears reset fields, and emails a password reset confirmation.

## Protected Auth Endpoints

All require `Authorization: Bearer <access_token>`.

- `POST /api/v1/auth/logout`
- `POST /api/v1/auth/refresh`
- `GET /api/v1/auth/me`

Refresh deletes the current Sanctum token and issues a new one.

## Driver Endpoints

All require role `driver`.

- `GET /api/v1/driver/profile`
- `PUT /api/v1/driver/profile`
- `GET /api/v1/driver/application-status`
- `POST /api/v1/driver/documents`
- `GET /api/v1/driver/documents`

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
    "token_type": "bearer",
    "expires_in": 3600,
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

## Future Improvements

- Add Pest/PHPUnit feature tests once PHP and Composer are available.
- Add Laravel policies for ownership checks.
- Add email and phone verification flows.
- Add queue-backed notifications.
- Add payment gateway verification adapters behind `PaymentService`.
- Add Filament resources after the API layer is stable.
