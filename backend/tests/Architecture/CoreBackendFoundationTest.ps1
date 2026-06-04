$ErrorActionPreference = 'Stop'

$root = Resolve-Path (Join-Path $PSScriptRoot '..\..')
$failures = New-Object System.Collections.Generic.List[string]

function Resolve-RepoPath([string] $relativePath) {
    return Join-Path $root $relativePath
}

function Assert-FileExists([string] $relativePath) {
    if (-not (Test-Path -LiteralPath (Resolve-RepoPath $relativePath))) {
        $failures.Add("Missing file: $relativePath")
    }
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

$requiredFiles = @(
    'app/Models/User.php',
    'app/Models/RiderProfile.php',
    'app/Models/Fleet.php',
    'app/Models/Vehicle.php',
    'app/Models/RiderDocument.php',
    'app/Models/FleetDocument.php',
    'app/Models/VehicleDocument.php',
    'app/Models/Zone.php',
    'app/Models/ZonePrice.php',
    'app/Models/Trip.php',
    'app/Models/Payment.php',
    'app/Models/RiderCashLedger.php',
    'app/Models/AuditLog.php',
    'app/Services/DriverApprovalService.php',
    'app/Services/FleetApprovalService.php',
    'app/Services/DocumentVerificationService.php',
    'app/Services/PricingService.php',
    'app/Services/TripService.php',
    'app/Services/PaymentService.php',
    'app/Services/CashLedgerService.php',
    'app/Services/AuditLogService.php',
    'database/seeders/DatabaseSeeder.php',
    'database/seeders/JosiMvpSeeder.php'
)

$enumFiles = @(
    'UserRole',
    'UserStatus',
    'ApplicationStatus',
    'AvailabilityStatus',
    'VerificationStatus',
    'VehicleType',
    'VehicleStatus',
    'PaymentMethod',
    'PaymentStatus',
    'TripStatus',
    'RemittanceStatus'
)

foreach ($file in $requiredFiles) {
    Assert-FileExists $file
}

foreach ($enum in $enumFiles) {
    Assert-FileExists "app/Enums/$enum.php"
}

$enumCases = @{
    'app/Enums/UserRole.php' = @('super_admin', 'admin', 'fleet_owner', 'driver', 'customer')
    'app/Enums/UserStatus.php' = @('active', 'inactive', 'suspended')
    'app/Enums/ApplicationStatus.php' = @('pending', 'under_review', 'approved', 'rejected', 'suspended')
    'app/Enums/AvailabilityStatus.php' = @('offline', 'online', 'busy', 'unavailable')
    'app/Enums/VerificationStatus.php' = @('pending', 'verified', 'rejected')
    'app/Enums/VehicleType.php' = @('bike', 'motorcycle', 'tricycle', 'car', 'van')
    'app/Enums/VehicleStatus.php' = @('active', 'inactive', 'under_maintenance', 'suspended')
    'app/Enums/PaymentMethod.php' = @('cash', 'card', 'transfer', 'wallet')
    'app/Enums/PaymentStatus.php' = @('pending', 'paid', 'failed', 'cancelled', 'cash_collected', 'remitted')
    'app/Enums/TripStatus.php' = @('requested', 'assigned', 'accepted', 'ongoing', 'completed', 'cancelled')
    'app/Enums/RemittanceStatus.php' = @('pending', 'partially_remitted', 'remitted', 'disputed', 'waived')
}

foreach ($entry in $enumCases.GetEnumerator()) {
    foreach ($case in $entry.Value) {
        Assert-Contains $entry.Key "'$case'" "Enum case $case"
    }
}

$relationships = @{
    'app/Models/User.php' = @('function riderProfile', 'function fleet', 'function trips', 'function auditLogs')
    'app/Models/RiderProfile.php' = @('function user', 'function fleet', 'function vehicles', 'function riderDocuments', 'function trips', 'function riderCashLedgers')
    'app/Models/Fleet.php' = @('function user', 'function riderProfiles', 'function driverProfiles', 'function vehicles', 'function fleetDocuments')
    'app/Models/Vehicle.php' = @('function fleet', 'function riderProfile', 'function driverProfile', 'function vehicleDocuments', 'function trips')
    'app/Models/Trip.php' = @('function customer', 'function riderProfile', 'function vehicle', 'function pickupZone', 'function destinationZone', 'function payment', 'function riderCashLedger')
    'app/Models/AuditLog.php' = @('function user', 'function auditable')
}

foreach ($entry in $relationships.GetEnumerator()) {
    foreach ($relationship in $entry.Value) {
        Assert-Contains $entry.Key $relationship "Relationship $relationship"
    }
}

$tables = @(
    'users',
    'fleets',
    'rider_profiles',
    'vehicles',
    'rider_documents',
    'fleet_documents',
    'vehicle_documents',
    'zones',
    'zone_prices',
    'trips',
    'payments',
    'rider_cash_ledgers',
    'audit_logs',
    'personal_access_tokens',
    'roles',
    'permissions',
    'permission_role',
    'role_user'
)

foreach ($table in $tables) {
    $migrationMatch = Get-ChildItem -LiteralPath (Resolve-RepoPath 'database/migrations') -Filter '*.php' |
        Where-Object { (Get-Content -LiteralPath $_.FullName -Raw).Contains("Schema::create('$table'") }

    if (-not $migrationMatch) {
        $failures.Add("Missing migration table: $table")
    }
}

Assert-Contains 'database/migrations/2026_06_04_000010_create_trips_table.php' "foreignId('driver_profile_id')" 'driver_profile_id FK'
Assert-Contains 'database/migrations/2026_06_04_000011_create_payments_table.php' "payment_reference" 'payment_reference index/unique column'
Assert-Contains 'database/migrations/2026_06_04_000013_create_audit_logs_table.php' 'nullableMorphs' 'audit morph columns'
Assert-Contains 'database/seeders/JosiMvpSeeder.php' 'superadmin@josi.test' 'super admin seed'
Assert-Contains 'database/seeders/JosiMvpSeeder.php' 'fleet.owner@josi.test' 'fleet owner seed'
Assert-Contains 'database/seeders/JosiMvpSeeder.php' 'rider@josi.test' 'rider seed'
Assert-Contains 'database/seeders/JosiMvpSeeder.php' 'customer@josi.test' 'customer seed'

if ($failures.Count -gt 0) {
    Write-Host 'Core backend foundation test failed:' -ForegroundColor Red
    foreach ($failure in $failures) {
        Write-Host " - $failure" -ForegroundColor Red
    }
    exit 1
}

Write-Host 'Core backend foundation test passed.' -ForegroundColor Green
