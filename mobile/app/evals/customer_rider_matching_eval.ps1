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

Assert-Contains 'lib/core/repositories/repositories.dart' "available-riders" 'Customer available riders API call'
Assert-Contains 'lib/core/repositories/repositories.dart' "request-rider" 'Customer request rider API call'
Assert-Contains 'lib/core/repositories/repositories.dart' "submitRiderReview" 'Customer review repository method'
Assert-Contains 'lib/core/repositories/repositories.dart' "markArrivedAtPickup" 'Rider arrival repository method'
Assert-Contains 'lib/core/providers/app_providers.dart' "riderTripProvider" 'Rider trip provider'
Assert-Contains 'lib/core/services/phone_call_service.dart' "MethodChannel('josi_ride/phone')" 'Native phone dial channel'
Assert-Contains 'lib/features/customer/customer_screens.dart' "active-trip-call-button" 'Arrived screen call action'
Assert-Contains 'lib/features/customer/customer_screens.dart' "Rider notified" 'Waiting screen before rider arrival'
Assert-Contains 'lib/features/customer/customer_screens.dart' "Rate Rider" 'Customer rating transition'
Assert-Contains 'lib/features/rider/rider_screens.dart' "markArrivedAtPickup" 'Rider arrival button calls backend'
Assert-NotContains 'lib/features/customer/customer_screens.dart' "Book Mini" 'Book Mini removed from searching screen'
Assert-NotContains 'lib/features/customer/customer_screens.dart' "book-mini-button" 'Book Mini button removed'
Assert-NotContains 'lib/features/customer/customer_screens.dart' "OTP - 6546" 'Fake OTP removed from arrived screen'
Assert-NotContains 'lib/features/customer/customer_screens.dart' "Rate per" 'Fake rate removed from arrived screen'
Assert-NotContains 'lib/features/customer/customer_screens.dart' "No. of Seats" 'Fake seats removed from arrived screen'

if ($failures.Count -gt 0) {
    Write-Host 'Customer rider matching mobile eval failed:' -ForegroundColor Red
    foreach ($failure in $failures) {
        Write-Host " - $failure" -ForegroundColor Red
    }
    exit 1
}

Write-Host 'Customer rider matching mobile eval passed.' -ForegroundColor Green
