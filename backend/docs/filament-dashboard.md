# Josi Filament Dashboard

Josi uses two Filament panels:

- Admin panel: `/admin`
- Pack owner dashboard: `/dashboard`

The admin panel is for `super_admin` and `admin`. The pack owner dashboard is for fleet business users only. The canonical owner role is `pack_owner`; `fleet_owner` is still accepted as a legacy alias because existing data and redirects already reference it.

## Access Model

Panel entry is enforced through `App\Models\User::canAccessPanel()` and `App\Support\Filament\DashboardAccess`.

- `super_admin` can access every admin resource and manage roles, admins, audit logs, and settings.
- `admin` can manage operational records, applications, documents, vehicles, trips, payments, and remittance, but cannot create or edit `super_admin` users or open system settings.
- `pack_owner` and legacy `fleet_owner` can only access their own dashboard records.

Navigation hiding is never the only guard. Policies are registered in `App\Providers\AuthServiceProvider`, and fleet resources scope queries with `DashboardAccess::scopeToCurrentFleet()` or `DashboardAccess::fleetIdFor()`.

## Admin Resources

The admin panel includes resources for:

- Users and roles
- Riders and couriers
- Pack owners
- Vehicles and vehicle documents
- Rider, fleet, and vehicle KYC documents
- Zones and zone pricing
- Trips and orders
- Payments
- Rider cash ledger and remittance
- Audit logs

Forms are grouped into sections or tabs, tables include searchable and filtered columns, and operational states are shown with badges. Money is formatted as Nigerian Naira through `App\Support\Filament\Display`.

## Fleet Dashboard

The pack owner dashboard includes:

- Business profile
- Own vehicles
- Linked riders and couriers
- Own fleet documents
- Own trips
- Own revenue and cash summary
- Settings page

Fleet users cannot edit verification status, pricing, global users, payments, or system settings. Create and edit pages force `fleet_id` from the authenticated user instead of trusting submitted data.

## Workflows And Audit Logs

Sensitive actions call service classes and write audit records:

- Rider and courier approve, reject, under review, suspend, reactivate
- Pack owner approve, reject, under review, suspend, reactivate
- Document verify and reject
- Vehicle verify, reject, suspend, mark active
- Payment verify and mark failed
- Cash ledger partial remittance, full remittance, dispute, admin note
- Admin user creation

Audit logs are read-only in Filament and limited to `super_admin`.

## Security Notes

- Filament is installed through `filament/filament`.
- Spatie Permission is installed and the `User` model uses `HasRoles`.
- The database `role` column remains the source used by panel guards, while Spatie roles provide permission tooling.
- KYC uploads use the `private` disk and are exposed only through authenticated Filament actions.
- Raw payment gateway response data is visible only to `super_admin`.
- Active zone pricing prevents duplicate active pickup and destination pairs.

## Local Runtime Note

This backend requires PHP `^8.3` and `ext-intl` for the installed Laravel and Filament stack. If the local CLI is older, run the PowerShell architecture tests first, then rerun Artisan and PHPUnit after upgrading PHP.

## Filament Assets

Filament CSS, JavaScript, and fonts must exist under `public/css/filament`, `public/js/filament`, and `public/fonts/filament`.

After installing dependencies, updating Filament, or deploying to a fresh server, run:

```powershell
php artisan filament:assets
php artisan optimize:clear
```

If the dashboard loads as plain HTML with no styling, the published assets are missing or the browser is still seeing cached URLs.
