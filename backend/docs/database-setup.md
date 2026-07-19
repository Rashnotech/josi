# Josi Database Setup

Josi uses MySQL or MariaDB for the Laravel backend. Credentials must live in `.env`; do not hardcode database secrets in PHP code, config files, seeders, logs, or docs.

## Environment Variables

Copy `.env.example` to `.env` on the server or local machine and update these values:

```env
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=josi_db
DB_USERNAME=root
DB_PASSWORD=
SESSION_DRIVER=database
```

Production/cPanel example:

```env
DB_CONNECTION=mysql
DB_HOST=localhost
DB_PORT=3306
DB_DATABASE=cpanelusername_josi_db
DB_USERNAME=cpanelusername_josi_user
DB_PASSWORD=your_secure_password
```

cPanel database names often include the cPanel account username as a prefix. If your cPanel username is `rashnotech`, the database may become `rashnotech_josi_db` and the database user may become `rashnotech_josi_user`.

## Laravel Config

`config/database.php` reads these values from env:

- `DB_CONNECTION`
- `DB_HOST`
- `DB_PORT`
- `DB_DATABASE`
- `DB_USERNAME`
- `DB_PASSWORD`

The MySQL connection uses:

```php
'charset' => 'utf8mb4',
'collation' => 'utf8mb4_unicode_ci',
```

This supports names, addresses, symbols, and future multilingual data safely.

`config/app.php` sets:

```php
'timezone' => env('APP_TIMEZONE', 'Africa/Lagos'),
```

Use `APP_TIMEZONE=Africa/Lagos` in `.env`. Treat database timestamps consistently across API clients, admin screens, and background jobs.

## Laravel Runtime Setup

Install PHP 8.3 or newer with these extensions enabled:

- `curl`
- `fileinfo`
- `mbstring`
- `openssl`
- `pdo_mysql`
- `zip`

Install Composer dependencies:

```powershell
composer install
```

Create local environment config and app key:

```powershell
copy .env.example .env
php artisan key:generate
```

Create the public storage link for development:

```powershell
php artisan storage:link
```

This repository ignores generated local runtime folders such as `vendor/`, `.tools/`, and `public/storage`.

## MariaDB 10.1 compatibility

Some Namecheap/cPanel-style hosts and older XAMPP installations still run old MariaDB versions. Two compatibility choices are intentional:

- `AppServiceProvider` calls `Schema::defaultStringLength(191)` so unique/indexed strings work with `utf8mb4` on old 767-byte index limits.
- `payments.gateway_response`, `audit_logs.old_values`, and `audit_logs.new_values` use `longText` columns instead of native `json`. Eloquent model casts still expose these values as arrays in PHP.

Do not change those fields back to native `json` until the target database version is confirmed to support it.

## Local Development Setup

Create the database:

```sql
CREATE DATABASE josi_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

Create a local user if you do not want to use root:

```sql
CREATE USER 'josi_user'@'localhost' IDENTIFIED BY 'strong_local_password';
GRANT ALL PRIVILEGES ON josi_db.* TO 'josi_user'@'localhost';
FLUSH PRIVILEGES;
```

Update `.env`:

```env
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=josi_db
DB_USERNAME=josi_user
DB_PASSWORD=strong_local_password
```

Check the connection:

```powershell
php artisan josi:check-db
```

Expected output:

```text
Database connection successful.
Connection: mysql
Database: josi_db
```

Run migrations:

```powershell
php artisan migrate
```

Filament browser login uses Laravel sessions. With `SESSION_DRIVER=database`, confirm the `sessions` table exists after migration.

Run seeders:

```powershell
php artisan db:seed
```

Reset local database safely:

```powershell
php artisan migrate:fresh --seed
```

Use `migrate:fresh` only in local development or disposable test databases.

## Production/cPanel Setup

1. Open cPanel.
2. Go to MySQL Databases.
3. Create a database, for example `josi_db`. cPanel will likely prefix it, such as `cpanelusername_josi_db`.
4. Create a database user, for example `josi_user`. cPanel will likely prefix it, such as `cpanelusername_josi_user`.
5. Assign the user to the database.
6. Grant the minimum required privileges for the application. For initial migrations you need create/alter/index privileges. For runtime, restrict privileges where possible.
7. Copy the exact database name, username, password, host, and port into `.env`.
8. Run the DB health check.
9. Run migrations.
10. Run seeders.

### Subdomain document root and web login

Set the `app` subdomain document root to Laravel's `public` directory, not to
the Laravel project directory. For example, if the backend is uploaded to
`/home/cpanelusername/josi-backend`, use:

```text
/home/cpanelusername/josi-backend/public
```

Point Laravel at the production API hostname and the React login page:

```env
APP_ENV=production
APP_DEBUG=false
APP_URL=https://app.example.com
WEB_LOGIN_URL=https://example.com/login
```

With this setup:

- `https://app.example.com` redirects to the React login page.
- `https://app.example.com/api/v1/...` continues through Laravel's API routes.
- `https://app.example.com/admin` and `https://app.example.com/dashboard`
  continue through Laravel's Filament panels.

If the host does not allow the subdomain document root to be changed, the
project-level `.htaccess` forwards requests into `public/` and disables
directory indexes as a fallback. The public document root is still preferred
because it prevents direct web access to `.env`, `vendor`, and application
source files at the server configuration level.

cPanel `.env` example:

```env
DB_CONNECTION=mysql
DB_HOST=localhost
DB_PORT=3306
DB_DATABASE=cpanelusername_josi_db
DB_USERNAME=cpanelusername_josi_user
DB_PASSWORD=your_secure_password
```

## Migration Commands

Check migration state:

```powershell
php artisan migrate:status
```

Run pending migrations:

```powershell
php artisan migrate
```

Rebuild a local database without seeding:

```powershell
php artisan migrate:fresh
```

Rebuild and seed a local database:

```powershell
php artisan migrate:fresh --seed
```

Run seeders only:

```powershell
php artisan db:seed
```

Never run `php artisan migrate:fresh` in production.

## Initial Database Creation Order

1. Configure `.env`.
2. Confirm database connection with `php artisan josi:check-db`.
3. Create users table updates.
4. Create core model migrations.
5. Create RBAC package tables.
6. Run migrations.
7. Run seeders.
8. Test login and registration APIs.

## Sanctum Setup

Install and publish Sanctum in the full Laravel runtime:

```powershell
composer require laravel/sanctum
php artisan vendor:publish --provider="Laravel\Sanctum\SanctumServiceProvider"
php artisan migrate
```

Confirm this table exists:

- `personal_access_tokens`

This repository also includes a `personal_access_tokens` migration for environments where the published Sanctum migration is not present yet.

## Spatie Laravel Permission Setup

Install and publish Spatie Permission in the full Laravel runtime:

```powershell
composer require spatie/laravel-permission
php artisan vendor:publish --provider="Spatie\Permission\PermissionServiceProvider"
php artisan migrate
```

Confirm these tables exist:

- `roles`
- `permissions`
- `model_has_roles`
- `model_has_permissions`
- `role_has_permissions`

This repository includes Spatie-compatible table migrations and seeders so the database is ready before Filament resources are built.

## Tables Supported

Core tables:

- `users`
- `rider_profiles`
- `fleets`
- `vehicles`
- `rider_documents`
- `fleet_documents`
- `vehicle_documents`
- `zones`
- `zone_prices`
- `trips`
- `payments`
- `rider_cash_ledgers`
- `audit_logs`
- `sessions`
- `personal_access_tokens`
- `roles`
- `permissions`
- `model_has_roles`
- `model_has_permissions`
- `role_has_permissions`

The current migrations use `rider_profiles` and `rider_documents`; the code also includes `DriverProfile` and `DriverDocument` model aliases. If the team wants physical table names `driver_profiles` and `driver_documents`, rename those migrations before the first production migration.

The password reset flow currently stores hashed reset fields on `users`:

- `password_reset_code`
- `password_reset_code_expires_at`
- `password_reset_verified_at`
- `password_reset_token`
- `password_reset_code_attempts`
- `password_reset_sent_at`

## Seeders

Run:

```powershell
php artisan db:seed
```

Seeder order:

1. `RolesAndPermissionsSeeder`
2. `SuperAdminSeeder`
3. `ZoneSeeder`
4. `ZonePriceSeeder`
5. `SampleFleetSeeder`
6. `SampleDriverSeeder`

Default roles:

- `super_admin`
- `admin`
- `fleet_owner`
- `driver`
- `customer`

Default super admin comes from env:

```env
SUPER_ADMIN_NAME="Josi Super Admin"
SUPER_ADMIN_EMAIL=admin@josi.local
SUPER_ADMIN_PHONE=08000000000
SUPER_ADMIN_PASSWORD=password
```

Use a strong `SUPER_ADMIN_PASSWORD` outside local development.

## Production Safety Checklist

- Never commit `.env`.
- Commit `.env.example` only.
- Never expose database credentials in logs.
- Never hardcode database credentials.
- Use strong production database passwords.
- Restrict database user privileges where possible.
- Take a database backup before migrations in production.
- Never run `migrate:fresh` in production.
- Run `php artisan migrate:status` before production migration.
- Store uploaded document paths only, not raw file bytes.
- Keep KYC files in private storage.
- Confirm `personal_access_tokens` exists before mobile login testing.
- Confirm `sessions` exists before Filament admin login testing.
- Confirm RBAC tables exist before admin/API permission testing.
