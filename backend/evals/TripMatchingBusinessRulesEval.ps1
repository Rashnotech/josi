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
Assert-Contains 'app/Http/Controllers/Api/V1/CustomerTripController.php' "'rating' => ['required', 'integer', 'min:1', 'max:5']" 'Review rating validation'
Assert-Contains 'app/Http/Controllers/Api/V1/DriverTripController.php' 'startTrip' 'Driver arrival starts trip'
Assert-Contains 'app/Services/TripService.php' 'TripStatus::Ongoing' 'Arrival moves trip to ongoing'
Assert-Contains 'app/Services/TripService.php' 'started_at' 'Arrival records timestamp'
Assert-NotContains 'app/Http/Controllers/Api/V1/CustomerTripController.php' 'JosiMockData' 'Backend must not use mobile mock data'

if ($failures.Count -gt 0) {
    Write-Host 'Trip matching business rules eval failed:' -ForegroundColor Red
    foreach ($failure in $failures) {
        Write-Host " - $failure" -ForegroundColor Red
    }
    exit 1
}

Write-Host 'Trip matching business rules eval passed.' -ForegroundColor Green
