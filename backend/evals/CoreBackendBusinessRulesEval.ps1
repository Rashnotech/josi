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

Assert-Contains 'app/Services/PricingService.php' 'ActiveZonePriceNotFoundException' 'Pricing error when no active zone price exists'
Assert-Contains 'app/Services/PricingService.php' "where('is_active', true)" 'Pricing uses active zone prices only'
Assert-Contains 'app/Services/PricingService.php' 'assertPaymentMethodAllowed' 'Pricing controls allowed payment methods'
Assert-Contains 'app/Http/Controllers/Api/V1/CustomerTripController.php' "Rule::in(['ride', 'courier'])" 'Customer trip service type limited to ride/courier'
Assert-Contains 'app/Http/Controllers/Api/V1/CustomerTripController.php' 'resolveZonePair' 'Customer trip requests resolve backend zone pricing'
Assert-Contains 'app/Http/Controllers/Api/V1/CustomerTripController.php' 'No active customer route pricing is available yet.' 'Customer trip has user-friendly missing-pricing error'
Assert-Contains 'app/Http/Controllers/Api/V1/CustomerAddressController.php' "'address' => ['required', 'string', 'max:1000']" 'Customer saved addresses require real address text'
Assert-Contains 'app/Http/Controllers/Api/V1/CustomerProfileController.php' "'gender' => ['sometimes', 'nullable', 'string', 'max:50']" 'Customer profile update accepts gender'

Assert-Contains 'app/Services/PaymentService.php' 'markVerifiedPaid' 'Online payment backend verification path'
Assert-Contains 'app/Services/PaymentService.php' 'markCashCollected' 'Cash collection path'
Assert-Contains 'app/Services/PaymentService.php' 'Cash payments must be collected from completed trips' 'Cash cannot be marked as online paid'

Assert-Contains 'app/Services/CashLedgerService.php' 'createForCashTrip' 'Cash ledger creation service'
Assert-Contains 'app/Services/CashLedgerService.php' 'TripStatus::Completed' 'Cash ledger requires completed trip'
Assert-Contains 'app/Services/CashLedgerService.php' 'firstOrCreate' 'Cash ledger avoids duplicate trip ledgers'
Assert-Contains 'app/Services/CashLedgerService.php' 'recordRemittance' 'Admin remittance update path'
Assert-Contains 'app/Services/TripService.php' "'service_type'" 'Trip request persists ride/courier service type'
Assert-Contains 'app/Models/CustomerSavedAddress.php' "'user_id'" 'Saved addresses are owned by customer user'

Assert-Contains 'app/Services/DriverApprovalService.php' 'driver.approved' 'Driver approval audit action'
Assert-Contains 'app/Services/FleetApprovalService.php' 'fleet.approved' 'Fleet approval audit action'
Assert-Contains 'app/Services/DocumentVerificationService.php' 'document.verified' 'Document verification audit action'
Assert-Contains 'app/Services/PaymentService.php' 'payment.verified' 'Payment verification audit action'
Assert-Contains 'app/Services/CashLedgerService.php' 'cash_ledger.remittance_updated' 'Cash remittance audit action'

Assert-Contains 'database/migrations/2026_06_04_000005_create_rider_documents_table.php' 'file_path' 'Rider documents store private storage path'
Assert-Contains 'database/migrations/2026_06_04_000006_create_fleet_documents_table.php' 'file_path' 'Fleet documents store private storage path'
Assert-Contains 'database/migrations/2026_06_04_000007_create_vehicle_documents_table.php' 'file_path' 'Vehicle documents store private storage path'

Assert-Contains 'README.md' 'Riders do not control pricing' 'Business rule documented'
Assert-Contains 'README.md' 'Frontend payment status is not trusted' 'Payment trust rule documented'
Assert-Contains 'README.md' 'Raw files belong in private storage' 'KYC storage rule documented'
Assert-Contains 'docs/auth-api.md' 'POST /api/v1/customer/addresses' 'Customer saved address endpoint documented'
Assert-Contains 'docs/auth-api.md' 'POST /api/v1/customer/trips' 'Customer trip request endpoint documented'
Assert-Contains 'docs/auth-api.md' '`service_type` accepts `ride` or `courier`' 'Customer trip service type documented'

$tripService = Get-Content -LiteralPath (Resolve-RepoPath 'app/Services/TripService.php') -Raw
foreach ($forbidden in @('WebSocket', 'broadcast(', 'push notification', 'matching engine')) {
    if ($tripService.Contains($forbidden)) {
        $failures.Add("Forbidden future feature appears in TripService: $forbidden")
    }
}

foreach ($documentMigration in @(
    'database/migrations/2026_06_04_000005_create_rider_documents_table.php',
    'database/migrations/2026_06_04_000006_create_fleet_documents_table.php',
    'database/migrations/2026_06_04_000007_create_vehicle_documents_table.php'
)) {
    $content = Get-Content -LiteralPath (Resolve-RepoPath $documentMigration) -Raw
    if ($content.Contains('binary(') -or $content.Contains('mediumBlob') -or $content.Contains('longBlob')) {
        $failures.Add("Document migration stores raw file data: $documentMigration")
    }
}

if ($failures.Count -gt 0) {
    Write-Host 'Core backend business rules eval failed:' -ForegroundColor Red
    foreach ($failure in $failures) {
        Write-Host " - $failure" -ForegroundColor Red
    }
    exit 1
}

Write-Host 'Core backend business rules eval passed.' -ForegroundColor Green
