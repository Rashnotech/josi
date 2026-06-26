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

Assert-Contains 'routes/api.php' "available-riders" 'Customer available rider route'
Assert-Contains 'routes/api.php' "request-rider" 'Customer request rider route'
Assert-Contains 'routes/api.php' "CustomerTripController::class, 'cancel'" 'Customer cancel trip route'
Assert-Contains 'routes/api.php' "review" 'Customer rider review route'
Assert-Contains 'routes/api.php' "DriverTripController::class, 'arrived'" 'Driver arrival route'
Assert-Contains 'routes/api.php' "DriverTripController::class, 'decline'" 'Driver decline route'
Assert-Contains 'routes/api.php' 'DriverWalletController::class' 'Driver wallet route'
Assert-Contains 'app/Http/Controllers/Api/V1/CustomerTripController.php' 'public function availableRiders' 'Available riders endpoint'
Assert-Contains 'app/Http/Controllers/Api/V1/CustomerTripController.php' 'public function requestRider' 'Request rider endpoint'
Assert-Contains 'app/Http/Controllers/Api/V1/CustomerTripController.php' 'rider_notified' 'Request rider notification flag'
Assert-Contains 'app/Http/Controllers/Api/V1/CustomerTripController.php' 'public function cancel' 'Customer cancel endpoint'
Assert-Contains 'app/Http/Controllers/Api/V1/CustomerTripController.php' 'cancelTrip' 'Customer cancel endpoint uses trip service'
Assert-Contains 'app/Http/Controllers/Api/V1/CustomerTripController.php' 'public function review' 'Review endpoint'
Assert-Contains 'app/Http/Controllers/Api/V1/CustomerTripController.php' 'is_arrived_at_pickup' 'Customer arrival payload flag'
Assert-Contains 'app/Http/Controllers/Api/V1/CustomerTripController.php' "'customer_name' =>" 'Trip payload includes customer name'
Assert-Contains 'app/Http/Controllers/Api/V1/DriverTripController.php' 'public function arrived' 'Driver arrived endpoint'
Assert-Contains 'app/Http/Controllers/Api/V1/DriverTripController.php' 'public function decline' 'Driver decline endpoint'
Assert-Contains 'app/Http/Controllers/Api/V1/DriverTripController.php' 'TripStatus::Completed' 'Driver trip history includes completed trips'
Assert-Contains 'app/Http/Controllers/Api/V1/DriverTripController.php' 'TripStatus::Cancelled' 'Driver trip history includes cancelled trips'
Assert-Contains 'app/Http/Controllers/Api/V1/DriverWalletController.php' "'summary' =>" 'Driver wallet summary payload'
Assert-Contains 'app/Http/Controllers/Api/V1/DriverWalletController.php' "'transactions' =>" 'Driver wallet transaction payload'
Assert-Contains 'app/Http/Controllers/Api/V1/DriverWalletController.php' 'riderCashLedgers' 'Driver wallet uses rider cash ledger data'
Assert-Contains 'app/Models/Trip.php' 'public function review()' 'Trip review relation'
Assert-Contains 'app/Models/TripReview.php' 'class TripReview extends Model' 'Trip review model'
Assert-Contains 'database/migrations/2026_06_19_000001_create_trip_reviews_table.php' "Schema::create('trip_reviews'" 'Trip review migration'

if ($failures.Count -gt 0) {
    Write-Host 'Trip matching contract test failed:' -ForegroundColor Red
    foreach ($failure in $failures) {
        Write-Host " - $failure" -ForegroundColor Red
    }
    exit 1
}

Write-Host 'Trip matching contract test passed.' -ForegroundColor Green
