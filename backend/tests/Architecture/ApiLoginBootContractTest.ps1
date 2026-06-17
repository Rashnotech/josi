$ErrorActionPreference = 'Stop'

$root = Resolve-Path (Join-Path $PSScriptRoot '..\..')
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

foreach ($provider in @(
    'app/Providers/Filament/AdminPanelProvider.php',
    'app/Providers/Filament/FleetPanelProvider.php'
)) {
    Assert-Contains $provider 'public function register(): void' 'Panel provider register override'
    Assert-Contains $provider 'isApiRequest()' 'API request guard'
    Assert-Contains $provider "return `$this->app['request']->is('api/*');" 'API path skip'
    Assert-Contains $provider 'parent::register();' 'Non-API Filament registration'
}

$probePath = Resolve-RepoPath 'tests/Architecture/ApiLoginBootProbe.php'
$output = & php $probePath 2>&1
if ($LASTEXITCODE -ne 0) {
    $failures.Add("API login boot probe failed: $output")
} else {
    try {
        $result = $output | ConvertFrom-Json

        if ($result.status -ne 422) {
            $failures.Add("Expected empty login request to return 422 validation response, got $($result.status)")
        }

        if ($result.elapsed_ms -gt 10000) {
            $failures.Add("Expected API login boot to finish under 10000ms, got $($result.elapsed_ms)ms")
        }
    } catch {
        $failures.Add("API login boot probe did not return JSON: $output")
    }
}

if ($failures.Count -gt 0) {
    Write-Host 'API login boot contract test failed:' -ForegroundColor Red
    foreach ($failure in $failures) {
        Write-Host " - $failure" -ForegroundColor Red
    }
    exit 1
}

Write-Host 'API login boot contract test passed.' -ForegroundColor Green
