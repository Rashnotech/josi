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

Assert-Contains 'lib/features/customer/customer_screens.dart' 'ref.watch(customerTripsProvider)' 'Bookings screen uses customer trip provider'
Assert-Contains 'lib/features/customer/customer_screens.dart' '_readableBookingDate' 'Bookings screen formats dates'
Assert-Contains 'lib/features/customer/customer_screens.dart' 'Bike Number' 'Bookings screen shows plate number label'
Assert-Contains 'lib/features/customer/customer_screens.dart' 'context.go(AppRoutes.customerSearchingRider)' 'Pending booking opens rider search'
Assert-Contains 'lib/features/customer/customer_screens.dart' 'Cancel Ride' 'Bookings screen exposes cancel action'
Assert-Contains 'lib/features/customer/customer_screens.dart' 'cancelTrip' 'Bookings screen calls customer cancel API'
Assert-Contains 'lib/features/customer/customer_screens.dart' 'activeCustomerTripProvider.notifier' 'Bookings screen selects trip before navigation'
Assert-Contains 'lib/core/repositories/repositories.dart' '_readableDateLabel' 'Repository formats API trip timestamps'
Assert-Contains 'lib/core/repositories/repositories.dart' '/customer/trips/$tripId/cancel' 'Repository uses customer cancel endpoint'
Assert-NotContains 'lib/features/customer/customer_screens.dart' '_BookingMiniMap' 'Booking mini map placeholder removed'
Assert-NotContains 'lib/features/customer/customer_screens.dart' '_BookingMiniMapPainter' 'Booking mini map painter removed'
Assert-NotContains 'lib/features/customer/customer_screens.dart' 'booking-sms-button' 'Dead booking SMS action removed'
Assert-NotContains 'lib/features/customer/customer_screens.dart' 'Reschedule' 'Dead booking reschedule action removed'

if ($failures.Count -gt 0) {
    Write-Host 'Customer bookings eval failed:' -ForegroundColor Red
    foreach ($failure in $failures) {
        Write-Host " - $failure" -ForegroundColor Red
    }
    exit 1
}

Write-Host 'Customer bookings eval passed.' -ForegroundColor Green
