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

function Assert-NotContains([string] $relativePath, [string] $needle, [string] $label) {
    $path = Resolve-RepoPath $relativePath
    if (-not (Test-Path -LiteralPath $path)) {
        $failures.Add("Cannot inspect missing file: $relativePath")
        return
    }

    $content = Get-Content -LiteralPath $path -Raw
    if ($content.Contains($needle)) {
        $failures.Add("$label should not appear in $relativePath")
    }
}

$requiredFiles = @(
    'artisan',
    'composer.json',
    'composer.lock',
    'bootstrap/app.php',
    'bootstrap/cache/.gitignore',
    'public/index.php',
    'public/.htaccess',
    'routes/console.php',
    '.env.example',
    '.gitignore',
    'app/Providers/AppServiceProvider.php',
    'app/Providers/RouteServiceProvider.php',
    'config/database.php',
    'config/app.php',
    'config/auth.php',
    'config/cache.php',
    'config/filesystems.php',
    'config/hashing.php',
    'config/logging.php',
    'config/mail.php',
    'config/permission.php',
    'config/queue.php',
    'config/sanctum.php',
    'config/services.php',
    'app/Console/Commands/CheckDatabaseConnection.php',
    'app/Console/Kernel.php',
    'docs/database-setup.md',
    'database/seeders/RolesAndPermissionsSeeder.php',
    'database/seeders/SuperAdminSeeder.php',
    'database/seeders/ZoneSeeder.php',
    'database/seeders/ZonePriceSeeder.php',
    'database/seeders/SampleFleetSeeder.php',
    'database/seeders/SampleDriverSeeder.php'
)

foreach ($file in $requiredFiles) {
    Assert-FileExists $file
}

Assert-Contains '.env.example' 'DB_CONNECTION=mysql' 'MySQL env connection'
Assert-Contains '.env.example' 'DB_HOST=127.0.0.1' 'Local DB host'
Assert-Contains '.env.example' 'DB_PORT=3306' 'MySQL port'
Assert-Contains '.env.example' 'DB_DATABASE=josi_db' 'Local DB name'
Assert-Contains '.env.example' 'DB_USERNAME=root' 'Local DB username'
Assert-Contains '.env.example' 'DB_PASSWORD=' 'Local DB password placeholder'
Assert-Contains '.env.example' 'cpanelusername_josi_db' 'cPanel DB example'
Assert-Contains '.env.example' 'SUPER_ADMIN_PASSWORD=password' 'Super admin env password example'

Assert-Contains '.gitignore' '.env' '.env ignored'
Assert-Contains '.gitignore' '!.env.example' '.env.example committed'
Assert-Contains '.gitignore' '/vendor/' 'Composer vendor ignored'
Assert-Contains '.gitignore' '/.tools/' 'Local portable tooling ignored'
Assert-Contains '.gitignore' '/public/storage' 'Generated storage link ignored'

Assert-Contains 'composer.json' '"laravel/framework": "^12.0"' 'Laravel runtime dependency'
Assert-Contains 'composer.json' '"laravel/sanctum": "^4.0"' 'Sanctum dependency'
Assert-Contains 'composer.json' '"spatie/laravel-permission": "^6.0"' 'Spatie permission dependency'
Assert-Contains 'bootstrap/app.php' 'Illuminate\Foundation\Application' 'Laravel application bootstrap'
Assert-Contains 'bootstrap/app.php' 'App\Http\Kernel::class' 'HTTP kernel binding'
Assert-Contains 'bootstrap/app.php' 'App\Console\Kernel::class' 'Console kernel binding'
Assert-Contains 'public/index.php' 'bootstrap/app.php' 'Public entrypoint loads Laravel bootstrap'
Assert-Contains 'app/Providers/AppServiceProvider.php' 'Schema::defaultStringLength(191)' 'MariaDB 10.1 indexed string compatibility'

Assert-Contains 'config/database.php' "env('DB_CONNECTION'" 'DB connection from env'
Assert-Contains 'config/database.php' "env('DB_HOST'" 'DB host from env'
Assert-Contains 'config/database.php' "env('DB_PORT'" 'DB port from env'
Assert-Contains 'config/database.php' "env('DB_DATABASE'" 'DB name from env'
Assert-Contains 'config/database.php' "env('DB_USERNAME'" 'DB username from env'
Assert-Contains 'config/database.php' "env('DB_PASSWORD'" 'DB password from env'
Assert-Contains 'config/database.php' "'charset' => 'utf8mb4'" 'utf8mb4 charset'
Assert-Contains 'config/database.php' "'collation' => 'utf8mb4_unicode_ci'" 'utf8mb4 collation'

Assert-Contains 'config/app.php' "'timezone' => env('APP_TIMEZONE', 'Africa/Lagos')" 'Africa/Lagos timezone'

Assert-Contains 'app/Console/Commands/CheckDatabaseConnection.php' "protected `$signature = 'josi:check-db'" 'Database health check command signature'
Assert-Contains 'app/Console/Commands/CheckDatabaseConnection.php' 'getPdo()' 'Health check opens PDO connection'
Assert-Contains 'app/Console/Commands/CheckDatabaseConnection.php' 'getDatabaseName()' 'Health check displays database'
Assert-Contains 'app/Console/Commands/CheckDatabaseConnection.php' 'getDriverName()' 'Health check displays driver'

Assert-Contains 'database/seeders/DatabaseSeeder.php' 'RolesAndPermissionsSeeder::class' 'Roles seed order'
Assert-Contains 'database/seeders/DatabaseSeeder.php' 'SuperAdminSeeder::class' 'Super admin seed order'
Assert-Contains 'database/seeders/DatabaseSeeder.php' 'ZoneSeeder::class' 'Zone seed order'
Assert-Contains 'database/seeders/DatabaseSeeder.php' 'ZonePriceSeeder::class' 'Zone price seed order'
Assert-Contains 'database/seeders/DatabaseSeeder.php' 'SampleFleetSeeder::class' 'Sample fleet seed order'
Assert-Contains 'database/seeders/DatabaseSeeder.php' 'SampleDriverSeeder::class' 'Sample driver seed order'
Assert-Contains 'database/seeders/SuperAdminSeeder.php' "env('SUPER_ADMIN_PASSWORD')" 'Super admin password from env'

Assert-Contains 'database/migrations/2026_06_04_000011_create_payments_table.php' "longText('gateway_response')" 'Gateway response old MariaDB JSON fallback'
Assert-Contains 'database/migrations/2026_06_04_000013_create_audit_logs_table.php' "longText('old_values')" 'Audit old values old MariaDB JSON fallback'
Assert-Contains 'database/migrations/2026_06_04_000013_create_audit_logs_table.php' "longText('new_values')" 'Audit new values old MariaDB JSON fallback'
Assert-Contains 'database/migrations/2026_06_04_000014_add_auth_fields_to_users_table.php' 'historical migration as a no-op' 'Auth fields no-op migration documented'
Assert-NotContains 'database/migrations/2026_06_04_000014_add_auth_fields_to_users_table.php' 'Schema::hasColumn' 'MariaDB 10.1 incompatible column introspection'

Assert-Contains 'docs/database-setup.md' 'php artisan migrate' 'Migrate command documented'
Assert-Contains 'docs/database-setup.md' 'php artisan migrate:fresh' 'Migrate fresh command documented'
Assert-Contains 'docs/database-setup.md' 'php artisan migrate:fresh --seed' 'Migrate fresh seed command documented'
Assert-Contains 'docs/database-setup.md' 'php artisan db:seed' 'DB seed command documented'
Assert-Contains 'docs/database-setup.md' 'php artisan migrate:status' 'Migrate status command documented'
Assert-Contains 'docs/database-setup.md' 'php artisan josi:check-db' 'Health check command documented'
Assert-Contains 'docs/database-setup.md' 'vendor:publish --provider="Laravel\Sanctum\SanctumServiceProvider"' 'Sanctum publish documented'
Assert-Contains 'docs/database-setup.md' 'vendor:publish --provider="Spatie\Permission\PermissionServiceProvider"' 'Spatie publish documented'
Assert-Contains 'docs/database-setup.md' 'MariaDB 10.1 compatibility' 'Old MariaDB compatibility documented'
Assert-Contains 'docs/database-setup.md' 'Never run `migrate:fresh` in production.' 'Production safety warning'

if ($failures.Count -gt 0) {
    Write-Host 'Database setup test failed:' -ForegroundColor Red
    foreach ($failure in $failures) {
        Write-Host " - $failure" -ForegroundColor Red
    }
    exit 1
}

Write-Host 'Database setup test passed.' -ForegroundColor Green
