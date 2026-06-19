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

Assert-Contains 'routes/api.php' "Route::post('/login'" 'Mobile login API route'
Assert-Contains 'app/Providers/Filament/AdminPanelProvider.php' "return `$this->app['request']->is('api/*');" 'Admin panel skips API requests'
Assert-Contains 'app/Providers/Filament/FleetPanelProvider.php' "return `$this->app['request']->is('api/*');" 'Fleet panel skips API requests'
Assert-Contains 'tests/Architecture/ApiLoginBootContractTest.ps1' 'elapsed_ms -gt 10000' 'API login boot time gate'
Assert-Contains 'tests/Architecture/ApiLoginBootProbe.php' "'/api/v1/auth/login'" 'Real login route probe'
Assert-Contains 'tests/Architecture/ApiLoginBootProbe.php' "'status' => `$response->getStatusCode()" 'Probe captures HTTP status'
Assert-Contains 'docs/auth-api.md' 'Mobile API login must not boot Filament panel discovery.' 'Auth API boot note'
Assert-Contains 'docs/auth-api.md' 'the local `php artisan serve` process is stale' 'Stale artisan serve timeout troubleshooting'
Assert-Contains 'docs/auth-api.md' 'A healthy empty login request returns `422` validation quickly' 'Healthy login probe expectation'

if ($failures.Count -gt 0) {
    Write-Host 'API login boot readiness eval failed:' -ForegroundColor Red
    foreach ($failure in $failures) {
        Write-Host " - $failure" -ForegroundColor Red
    }
    exit 1
}

Write-Host 'API login boot readiness eval passed.' -ForegroundColor Green
