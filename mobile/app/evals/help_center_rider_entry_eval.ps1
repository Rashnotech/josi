$ErrorActionPreference = 'Stop'

$root = Resolve-Path (Join-Path $PSScriptRoot '..')
$failures = New-Object System.Collections.Generic.List[string]

function Resolve-AppPath([string] $relativePath) {
    return Join-Path $root $relativePath
}

function Assert-Contains([string] $relativePath, [string] $needle, [string] $label) {
    $path = Resolve-AppPath $relativePath
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
    $path = Resolve-AppPath $relativePath
    if (-not (Test-Path -LiteralPath $path)) {
        $failures.Add("Cannot inspect missing file: $relativePath")
        return
    }

    $content = Get-Content -LiteralPath $path -Raw
    if ($content.Contains($needle)) {
        $failures.Add("$label found forbidden text in $relativePath")
    }
}

$sharedScreens = 'lib/features/shared/shared_screens.dart'
$loginScreen = 'lib/features/auth/auth_screens.dart'
$splashScreen = 'lib/features/splash/splash_screen.dart'
$riderScreens = 'lib/features/rider/rider_screens.dart'

Assert-Contains $sharedScreens "detail: '+234 9162599418'" 'Current support phone number'
Assert-Contains $sharedScreens "detail: 'jositransport.com'" 'Current support website'
Assert-Contains $sharedScreens "detail: 'support@jositransport.com'" 'Current support email'
Assert-Contains $sharedScreens "detail: 'Josi Ride'" 'Josi Ride social handle'
Assert-Contains $sharedScreens 'titleFontSize: 18' 'Compact Help Center title'
Assert-Contains $sharedScreens 'class _HelpContactList extends StatefulWidget' 'Expandable Contact Us rows'
Assert-NotContains $sharedScreens '(480) 555-0103' 'Legacy support phone number'
Assert-Contains $loginScreen '? AppRoutes.riderHome' 'Approved rider login dashboard route'
Assert-Contains $splashScreen '? AppRoutes.riderHome' 'Approved rider restored-session dashboard route'
Assert-Contains $loginScreen ': AppRoutes.riderEntry' 'Rider login onboarding resolver route'
Assert-Contains $splashScreen ': AppRoutes.riderEntry' 'Restored rider onboarding resolver route'
Assert-Contains $riderScreens 'onboarding.isSubmitted' 'Submitted onboarding dashboard bypass'

if ($failures.Count -gt 0) {
    Write-Host 'Help Center and rider entry eval failed:' -ForegroundColor Red
    foreach ($failure in $failures) {
        Write-Host " - $failure" -ForegroundColor Red
    }
    exit 1
}

Write-Host 'Help Center and rider entry eval passed.' -ForegroundColor Green
