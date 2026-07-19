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

Assert-Contains 'docs/filament-dashboard.md' 'The canonical owner role is `pack_owner`' 'Pack owner canonical role documented'
Assert-Contains 'app/Enums/UserRole.php' "case PackOwner = 'pack_owner'" 'Pack owner enum exists'
Assert-Contains 'app/Enums/UserRole.php' "case FleetOwner = 'fleet_owner'" 'Fleet owner legacy alias exists'
Assert-Contains 'app/Support/Filament/DashboardAccess.php' 'UserRole::PackOwner->value' 'Pack owner dashboard access'
Assert-Contains 'app/Support/Filament/DashboardAccess.php' 'UserRole::FleetOwner->value' 'Fleet owner legacy dashboard access'
Assert-Contains 'app/Providers/Filament/AdminPanelProvider.php' "->brandLogo(asset('images/josi-logo.png'))" 'Admin dashboard uses company logo'
Assert-Contains 'app/Providers/Filament/FleetPanelProvider.php' "->brandLogo(asset('images/josi-logo.png'))" 'Fleet dashboard uses company logo'
Assert-Contains 'app/Providers/Filament/AdminPanelProvider.php' '->default()' 'Admin dashboard is the default Filament panel'
Assert-NotContains 'app/Providers/Filament/AdminPanelProvider.php' 'shouldRegisterPanel' 'Admin panel conditional registration'
Assert-NotContains 'app/Providers/Filament/FleetPanelProvider.php' 'shouldRegisterPanel' 'Fleet panel conditional registration'
Assert-Contains 'app/Providers/Filament/AdminPanelProvider.php' "->favicon(asset('images/josi-logo.png'))" 'Admin dashboard browser favicon'
Assert-Contains 'app/Providers/Filament/FleetPanelProvider.php' "->favicon(asset('images/josi-logo.png'))" 'Fleet dashboard browser favicon'
Assert-Contains 'app/Providers/Filament/AdminPanelProvider.php' 'PanelsRenderHook::BODY_START' 'Admin dashboard loading overlay hook'
Assert-Contains 'app/Providers/Filament/FleetPanelProvider.php' 'PanelsRenderHook::BODY_START' 'Fleet dashboard loading overlay hook'
Assert-Contains 'resources/views/filament/partials/panel-loader.blade.php' 'josi-panel-loader' 'Shared Filament loader exists'
Assert-Contains 'resources/views/filament/partials/panel-loader.blade.php' 'livewire:navigated' 'Shared Filament loader finishes Livewire navigation'

Assert-Contains 'app/Policies/UserPolicy.php' 'DashboardAccess::canManageAdmins' 'Only super admin creates admins'
Assert-Contains 'app/Filament/Admin/Resources/UserResource.php' 'UserRole::SuperAdmin' 'Super admin option guarded'
Assert-Contains 'app/Filament/Admin/Resources/UserResource.php' 'Hash::make' 'Admin-created passwords are hashed'
Assert-Contains 'app/Filament/Admin/Resources/UserResource/Pages/CreateUser.php' 'syncUserRole' 'Spatie roles synced from role column on create'
Assert-Contains 'app/Filament/Admin/Resources/UserResource/Pages/EditUser.php' 'syncUserRole' 'Spatie roles synced from role column on edit'
Assert-Contains 'app/Filament/Admin/Pages/SystemSettings.php' 'canManageSystemSettings' 'Critical settings restricted'

Assert-Contains 'app/Filament/Fleet/Resources/FleetVehicleResource/Pages/CreateFleetVehicle.php' '$data[''fleet_id''] = DashboardAccess::fleetIdFor(Auth::user());' 'Fleet vehicle create forces owner'
Assert-Contains 'app/Filament/Fleet/Resources/FleetVehicleResource/Pages/EditFleetVehicle.php' '$data[''fleet_id''] = DashboardAccess::fleetIdFor(Auth::user());' 'Fleet vehicle edit preserves owner'
Assert-Contains 'app/Filament/Fleet/Resources/FleetDocumentResource/Pages/CreateFleetDocument.php' '$data[''fleet_id''] = DashboardAccess::fleetIdFor(Auth::user());' 'Fleet document create forces owner'
Assert-Contains 'app/Filament/Fleet/Resources/FleetDocumentResource/Pages/EditFleetDocument.php' '$data[''fleet_id''] = DashboardAccess::fleetIdFor(Auth::user());' 'Fleet document edit preserves owner'
Assert-Contains 'app/Filament/Fleet/Resources/FleetVehicleResource/Pages/CreateFleetVehicle.php' '$data[''vehicle_status''] = VehicleStatus::Inactive->value;' 'Fleet owner cannot spoof vehicle status'
Assert-Contains 'app/Filament/Fleet/Resources/FleetVehicleResource/Pages/CreateFleetVehicle.php' '$data[''verification_status''] = VerificationStatus::Pending->value;' 'Fleet owner cannot spoof verification status'
Assert-Contains 'app/Filament/Fleet/Resources/FleetDocumentResource.php' '->disabled()' 'Fleet owner cannot edit verification status'

Assert-Contains 'app/Filament/Admin/Resources/ZonePriceResource/Pages/CreateZonePrice.php' 'ensureNoDuplicateActiveRoute' 'Zone price create prevents duplicate active route'
Assert-Contains 'app/Filament/Admin/Resources/ZonePriceResource/Pages/EditZonePrice.php' 'whereKeyNot($this->getRecord()->getKey())' 'Zone price edit ignores current record'

Assert-Contains 'app/Filament/Admin/Resources/PaymentResource.php' 'DashboardAccess::isSuperAdmin(Auth::user())' 'Raw gateway response super admin only'
Assert-Contains 'app/Support/Filament/DocumentResource.php' "->visibility('private')" 'Document uploads remain private'
Assert-Contains 'app/Policies/RiderCashLedgerPolicy.php' 'isStaff' 'Riders cannot edit cash ledger'
Assert-Contains 'app/Policies/ZonePricePolicy.php' 'isStaff' 'Fleet owners cannot edit pricing'
Assert-Contains 'app/Policies/AuditLogPolicy.php' 'return false;' 'Audit logs are read only'

Assert-Contains 'app/Support/Filament/ResourceActions.php' 'approve' 'Approval action present'
Assert-Contains 'app/Support/Filament/ResourceActions.php' 'reject' 'Reject action present'
Assert-Contains 'app/Support/Filament/ResourceActions.php' 'suspend' 'Suspend action present'
Assert-Contains 'app/Support/Filament/ResourceActions.php' 'verify' 'Verify action present'
Assert-Contains 'app/Support/Filament/ResourceActions.php' 'mark_failed' 'Payment failed action present'
Assert-Contains 'app/Support/Filament/ResourceActions.php' 'admin_note' 'Cash ledger admin note action present'

if ($failures.Count -gt 0) {
    Write-Host 'Filament dashboard business rules eval failed:' -ForegroundColor Red
    foreach ($failure in $failures) {
        Write-Host " - $failure" -ForegroundColor Red
    }
    exit 1
}

Write-Host 'Filament dashboard business rules eval passed.' -ForegroundColor Green
