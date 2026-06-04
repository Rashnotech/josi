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

Assert-Contains 'config/database.php' "env('DB_PASSWORD'" 'Database password must come from env'
Assert-Contains 'config/database.php' "'strict' => true" 'MySQL strict mode enabled'
Assert-Contains 'config/database.php' "'prefix_indexes' => true" 'MySQL prefixed indexes enabled'
Assert-Contains 'config/app.php' 'Africa/Lagos' 'Laravel timezone configured for Lagos'
Assert-Contains '.gitignore' '.env' 'Environment files ignored'

Assert-Contains 'docs/database-setup.md' 'cPanel database names often include the cPanel account username as a prefix' 'cPanel prefix explained'
Assert-Contains 'docs/database-setup.md' 'CREATE DATABASE josi_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;' 'Local DB creation command'
Assert-Contains 'docs/database-setup.md' 'Take a database backup before migrations in production.' 'Production backup warning'
Assert-Contains 'docs/database-setup.md' 'Store uploaded document paths only, not raw file bytes.' 'Document storage rule'
Assert-Contains 'docs/database-setup.md' 'The current migrations use `rider_profiles` and `rider_documents`' 'Driver table naming caveat documented'

Assert-Contains 'database/migrations/2026_06_04_000018_create_permission_role_table.php' 'role_has_permissions' 'Spatie role permission table'
Assert-Contains 'database/migrations/2026_06_04_000019_create_role_user_table.php' 'model_has_roles' 'Spatie model role table'
Assert-Contains 'database/migrations/2026_06_04_000020_create_model_has_permissions_table.php' 'model_has_permissions' 'Spatie model permission table'
Assert-Contains 'database/migrations/2026_06_04_000015_create_personal_access_tokens_table.php' 'personal_access_tokens' 'Sanctum tokens table'

$superAdminSeeder = Get-Content -LiteralPath (Resolve-RepoPath 'database/seeders/SuperAdminSeeder.php') -Raw
if ($superAdminSeeder.Contains("Hash::make('password')") -or $superAdminSeeder.Contains('"password"')) {
    $failures.Add('SuperAdminSeeder appears to hardcode the default password')
}

$databaseConfig = Get-Content -LiteralPath (Resolve-RepoPath 'config/database.php') -Raw
foreach ($forbidden in @('secure_password_here', 'cpanelusername_josi_user', 'cpanelusername_josi_db')) {
    if ($databaseConfig.Contains($forbidden)) {
        $failures.Add("Production placeholder appears inside config/database.php: $forbidden")
    }
}

if ($failures.Count -gt 0) {
    Write-Host 'Database operational readiness eval failed:' -ForegroundColor Red
    foreach ($failure in $failures) {
        Write-Host " - $failure" -ForegroundColor Red
    }
    exit 1
}

Write-Host 'Database operational readiness eval passed.' -ForegroundColor Green
