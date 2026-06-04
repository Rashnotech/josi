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
    '.env.example',
    '.gitignore',
    'config/database.php',
    'config/app.php',
    'config/sanctum.php',
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

Assert-Contains 'docs/database-setup.md' 'php artisan migrate' 'Migrate command documented'
Assert-Contains 'docs/database-setup.md' 'php artisan migrate:fresh' 'Migrate fresh command documented'
Assert-Contains 'docs/database-setup.md' 'php artisan migrate:fresh --seed' 'Migrate fresh seed command documented'
Assert-Contains 'docs/database-setup.md' 'php artisan db:seed' 'DB seed command documented'
Assert-Contains 'docs/database-setup.md' 'php artisan migrate:status' 'Migrate status command documented'
Assert-Contains 'docs/database-setup.md' 'php artisan josi:check-db' 'Health check command documented'
Assert-Contains 'docs/database-setup.md' 'vendor:publish --provider="Laravel\Sanctum\SanctumServiceProvider"' 'Sanctum publish documented'
Assert-Contains 'docs/database-setup.md' 'vendor:publish --provider="Spatie\Permission\PermissionServiceProvider"' 'Spatie publish documented'
Assert-Contains 'docs/database-setup.md' 'Never run `migrate:fresh` in production.' 'Production safety warning'

if ($failures.Count -gt 0) {
    Write-Host 'Database setup test failed:' -ForegroundColor Red
    foreach ($failure in $failures) {
        Write-Host " - $failure" -ForegroundColor Red
    }
    exit 1
}

Write-Host 'Database setup test passed.' -ForegroundColor Green
