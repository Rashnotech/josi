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

function Assert-NotContains([string] $relativePath, [string] $needle, [string] $label) {
    $path = Resolve-RepoPath $relativePath
    if (-not (Test-Path -LiteralPath $path)) {
        $failures.Add("Cannot inspect missing file: $relativePath")
        return
    }

    $content = Get-Content -LiteralPath $path -Raw
    if ($content.Contains($needle)) {
        $failures.Add("$label found forbidden text in $relativePath")
    }
}

Assert-Contains 'app/Http/Controllers/Api/V1/CustomerTripController.php' 'ApplicationStatus::Approved' 'Only approved riders are searchable'
Assert-Contains 'app/Http/Controllers/Api/V1/CustomerTripController.php' 'VehicleStatus::Active' 'Only active bikes are searchable'
Assert-Contains 'app/Http/Controllers/Api/V1/CustomerTripController.php' 'VerificationStatus::Verified' 'Only verified bikes are searchable'
Assert-Contains 'app/Http/Controllers/Api/V1/CustomerTripController.php' "whereNotIn('availability_status'" 'Busy riders are excluded'
Assert-Contains 'app/Http/Controllers/Api/V1/CustomerTripController.php' 'assignToRider' 'Customer request assigns selected rider'
Assert-Contains 'app/Http/Controllers/Api/V1/CustomerTripController.php' 'AvailabilityStatus::Busy' 'Requested rider becomes busy'
Assert-Contains 'app/Http/Controllers/Api/V1/CustomerTripController.php' "'customer_name' =>" 'Trip payload includes customer name'
Assert-Contains 'app/Http/Controllers/Api/V1/CustomerTripController.php' "'rating' => ['required', 'integer', 'min:1', 'max:5']" 'Review rating validation'
Assert-Contains 'app/Http/Controllers/Api/V1/DriverTripController.php' 'startTrip' 'Driver arrival starts trip'
Assert-Contains 'app/Http/Controllers/Api/V1/DriverTripController.php' 'declineTrip' 'Driver decline releases assigned trip'
Assert-Contains 'app/Http/Controllers/Api/V1/DriverTripController.php' 'TripStatus::Completed' 'Driver trip history includes completed trips'
Assert-Contains 'app/Http/Controllers/Api/V1/DriverTripController.php' 'TripStatus::Cancelled' 'Driver trip history includes cancelled trips'
Assert-Contains 'app/Http/Controllers/Api/V1/DriverWalletController.php' 'TripStatus::Completed' 'Wallet only counts completed trips'
Assert-Contains 'app/Http/Controllers/Api/V1/DriverWalletController.php' 'amount_to_remit' 'Wallet computes pending remittance from ledger'
Assert-Contains 'app/Http/Controllers/Api/V1/DriverWalletController.php' 'rider_share' 'Wallet uses rider share when a cash ledger exists'
Assert-Contains 'app/Http/Controllers/Api/V1/DriverWalletController.php' "'is_credit' => true" 'Wallet transactions are earning credits'
Assert-Contains 'app/Services/TripService.php' 'TripStatus::Ongoing' 'Arrival moves trip to ongoing'
Assert-Contains 'app/Services/TripService.php' 'started_at' 'Arrival records timestamp'
Assert-Contains 'app/Services/TripService.php' 'Only assigned trips can be declined.' 'Only assigned trips are declined'
Assert-Contains 'app/Services/TripService.php' 'trip.declined' 'Decline action is audited'
Assert-NotContains 'app/Http/Controllers/Api/V1/CustomerTripController.php' 'JosiMockData' 'Backend must not use mobile mock data'

if ($failures.Count -gt 0) {
    Write-Host 'Trip matching business rules eval failed:' -ForegroundColor Red
    foreach ($failure in $failures) {
        Write-Host " - $failure" -ForegroundColor Red
    }
    exit 1
}

Write-Host 'Trip matching business rules eval passed.' -ForegroundColor Green
