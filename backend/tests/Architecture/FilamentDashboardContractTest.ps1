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

@(
    'composer.json',
    'config/app.php',
    'app/Models/User.php',
    'app/Models/Role.php',
    'app/Models/Permission.php',
    'app/Providers/AuthServiceProvider.php',
    'app/Providers/Filament/AdminPanelProvider.php',
    'app/Providers/Filament/FleetPanelProvider.php',
    'app/Support/Filament/DashboardAccess.php',
    'app/Support/Filament/Display.php',
    'app/Support/Filament/ResourceActions.php',
    'app/Support/Filament/DriverProfileResource.php',
    'app/Support/Filament/DocumentResource.php',
    'app/Services/VehicleVerificationService.php',
    'public/images/josi-logo.png',
    'resources/views/filament/partials/panel-loader.blade.php',
    'docs/filament-dashboard.md'
) | ForEach-Object { Assert-FileExists $_ }

@(
    'app/Filament/Admin/Resources/UserResource.php',
    'app/Filament/Admin/Resources/RoleResource.php',
    'app/Filament/Admin/Resources/RiderResource.php',
    'app/Filament/Admin/Resources/CourierResource.php',
    'app/Filament/Admin/Resources/FleetOwnerResource.php',
    'app/Filament/Admin/Resources/VehicleResource.php',
    'app/Filament/Admin/Resources/RiderDocumentResource.php',
    'app/Filament/Admin/Resources/FleetDocumentResource.php',
    'app/Filament/Admin/Resources/VehicleDocumentResource.php',
    'app/Filament/Admin/Resources/ZoneResource.php',
    'app/Filament/Admin/Resources/ZonePriceResource.php',
    'app/Filament/Admin/Resources/TripResource.php',
    'app/Filament/Admin/Resources/PaymentResource.php',
    'app/Filament/Admin/Resources/RiderCashLedgerResource.php',
    'app/Filament/Admin/Resources/AuditLogResource.php'
) | ForEach-Object { Assert-FileExists $_ }

@(
    'app/Filament/Fleet/Resources/BusinessProfileResource.php',
    'app/Filament/Fleet/Resources/FleetVehicleResource.php',
    'app/Filament/Fleet/Resources/FleetDriverResource.php',
    'app/Filament/Fleet/Resources/FleetDocumentResource.php',
    'app/Filament/Fleet/Resources/FleetTripResource.php',
    'app/Filament/Fleet/Resources/FleetRevenueResource.php',
    'app/Filament/Fleet/Pages/FleetSettings.php'
) | ForEach-Object { Assert-FileExists $_ }

@(
    'app/Filament/Admin/Widgets/AdminDashboardHero.php',
    'app/Filament/Admin/Widgets/AdminOverviewStats.php',
    'app/Filament/Admin/Widgets/ApplicationStatusChart.php',
    'app/Filament/Admin/Widgets/CashRemittanceSummary.php',
    'app/Filament/Admin/Widgets/RecentRegistrations.php',
    'app/Filament/Admin/Widgets/RecentTrips.php',
    'app/Filament/Admin/Widgets/RecentPayments.php',
    'app/Filament/Fleet/Widgets/FleetBusinessSummary.php',
    'app/Filament/Fleet/Widgets/FleetOverviewStats.php',
    'app/Filament/Fleet/Widgets/FleetDocumentsStatus.php',
    'app/Filament/Fleet/Widgets/FleetRecentActivity.php',
    'resources/views/filament/widgets/admin-dashboard-hero.blade.php',
    'resources/views/filament/widgets/cash-remittance-summary.blade.php',
    'resources/views/filament/widgets/fleet-business-summary.blade.php',
    'resources/views/filament/widgets/fleet-documents-status.blade.php'
) | ForEach-Object { Assert-FileExists $_ }

Assert-Contains 'composer.json' '"filament/filament"' 'Filament package'
Assert-Contains 'composer.json' '"spatie/laravel-permission"' 'Spatie permission package'
Assert-Contains 'config/app.php' 'Filament\FilamentServiceProvider::class' 'Filament service provider'
Assert-Contains 'config/app.php' 'Spatie\Permission\PermissionServiceProvider::class' 'Spatie service provider'
Assert-Contains 'config/app.php' 'App\Providers\Filament\AdminPanelProvider::class' 'Admin panel provider registration'
Assert-Contains 'config/app.php' 'App\Providers\Filament\FleetPanelProvider::class' 'Fleet panel provider registration'

Assert-Contains 'app/Providers/Filament/AdminPanelProvider.php' "->id(DashboardAccess::ADMIN_PANEL)" 'Admin panel id'
Assert-Contains 'app/Providers/Filament/AdminPanelProvider.php' "->path('admin')" 'Admin panel path'
Assert-Contains 'app/Providers/Filament/AdminPanelProvider.php' "->brandLogo(asset('images/josi-logo.png'))" 'Admin panel uses Josi brand logo'
Assert-Contains 'app/Providers/Filament/AdminPanelProvider.php' "->brandLogoHeight('2.25rem')" 'Admin panel logo height'
Assert-Contains 'app/Providers/Filament/AdminPanelProvider.php' "->favicon(asset('images/josi-logo.png'))" 'Admin panel favicon'
Assert-Contains 'app/Providers/Filament/AdminPanelProvider.php' "PanelsRenderHook::BODY_START" 'Admin panel loading hook'
Assert-Contains 'app/Providers/Filament/AdminPanelProvider.php' "filament.partials.panel-loader" 'Admin panel loading view'
Assert-Contains 'app/Providers/Filament/AdminPanelProvider.php' 'AdminDashboardHero::class' 'Admin dashboard hero widget'
Assert-Contains 'app/Providers/Filament/AdminPanelProvider.php' 'RecentPayments::class' 'Recent payments widget'
Assert-Contains 'app/Providers/Filament/FleetPanelProvider.php' "->id(DashboardAccess::FLEET_PANEL)" 'Fleet panel id'
Assert-Contains 'app/Providers/Filament/FleetPanelProvider.php' "->path('dashboard')" 'Fleet panel path'
Assert-Contains 'app/Providers/Filament/FleetPanelProvider.php' "->brandLogo(asset('images/josi-logo.png'))" 'Fleet panel uses Josi brand logo'
Assert-Contains 'app/Providers/Filament/FleetPanelProvider.php' "->brandLogoHeight('2.25rem')" 'Fleet panel logo height'
Assert-Contains 'app/Providers/Filament/FleetPanelProvider.php' "->favicon(asset('images/josi-logo.png'))" 'Fleet panel favicon'
Assert-Contains 'app/Providers/Filament/FleetPanelProvider.php' "PanelsRenderHook::BODY_START" 'Fleet panel loading hook'
Assert-Contains 'app/Providers/Filament/FleetPanelProvider.php' "filament.partials.panel-loader" 'Fleet panel loading view'
Assert-Contains 'app/Providers/Filament/FleetPanelProvider.php' 'FleetBusinessSummary::class' 'Fleet business summary widget'
Assert-Contains 'resources/views/filament/partials/panel-loader.blade.php' 'josi-panel-loader' 'Filament panel loader shell'
Assert-Contains 'resources/views/filament/partials/panel-loader.blade.php' 'livewire:navigating' 'Filament loader handles Livewire navigation'
Assert-Contains 'resources/views/filament/partials/panel-loader.blade.php' 'Loading Josi dashboard' 'Filament loader accessible label'

$filamentFiles = Get-ChildItem -LiteralPath (Resolve-RepoPath 'app/Filament') -Recurse -Filter '*.php'
foreach ($file in $filamentFiles) {
    $content = Get-Content -LiteralPath $file.FullName -Raw
    if ($content.Contains('protected static ?string $navigationGroup')) {
        $failures.Add("Filament v5 navigationGroup type mismatch in $($file.FullName)")
    }
}

Assert-Contains 'app/Models/User.php' 'implements FilamentUser' 'User implements Filament access contract'
Assert-Contains 'app/Models/User.php' 'use HasRoles;' 'User uses Spatie roles'
Assert-Contains 'app/Models/User.php' 'canAccessPanel' 'User panel guard method'
Assert-Contains 'app/Models/Role.php' 'SpatieRole' 'Role model extends Spatie role'
Assert-Contains 'app/Models/Permission.php' 'SpatiePermission' 'Permission model extends Spatie permission'

Assert-Contains 'app/Support/Filament/DashboardAccess.php' 'ADMIN_PANEL' 'Admin panel constant'
Assert-Contains 'app/Support/Filament/DashboardAccess.php' 'FLEET_PANEL' 'Fleet panel constant'
Assert-Contains 'app/Support/Filament/DashboardAccess.php' 'isStaff' 'Staff access helper'
Assert-Contains 'app/Support/Filament/DashboardAccess.php' 'isFleetOwner' 'Fleet access helper'
Assert-Contains 'app/Support/Filament/DashboardAccess.php' 'scopeToCurrentFleet' 'Fleet query scoping helper'

Assert-Contains 'app/Providers/AuthServiceProvider.php' 'UserPolicy::class' 'User policy mapping'
Assert-Contains 'app/Providers/AuthServiceProvider.php' 'FleetPolicy::class' 'Fleet policy mapping'
Assert-Contains 'app/Providers/AuthServiceProvider.php' 'AuditLogPolicy::class' 'Audit log policy mapping'
Assert-Contains 'app/Policies/AuditLogPolicy.php' 'isSuperAdmin' 'Audit logs super admin only'
Assert-Contains 'app/Policies/UserPolicy.php' 'canManageAdmins' 'Admin creation restricted'

Assert-Contains 'app/Support/Filament/ResourceActions.php' 'markUnderReview' 'Under review workflow'
Assert-Contains 'app/Support/Filament/ResourceActions.php' 'reactivate' 'Reactivate workflow'
Assert-Contains 'app/Support/Filament/ResourceActions.php' 'DocumentVerificationService::class)->verify' 'Document verify workflow'
Assert-Contains 'app/Support/Filament/ResourceActions.php' 'recordRemittance' 'Partial remittance workflow'
Assert-Contains 'app/Support/Filament/ResourceActions.php' 'markFullyRemitted' 'Full remittance workflow'
Assert-Contains 'app/Support/Filament/ResourceActions.php' 'markDisputed' 'Cash dispute workflow'

Assert-Contains 'app/Support/Filament/DocumentResource.php' "->disk('private')" 'Private document disk'
Assert-Contains 'app/Filament/Fleet/Resources/FleetVehicleResource.php' 'scopeToCurrentFleet' 'Fleet vehicle ownership scope'
Assert-Contains 'app/Filament/Fleet/Resources/FleetDocumentResource.php' 'scopeToCurrentFleet' 'Fleet document ownership scope'
Assert-Contains 'app/Filament/Fleet/Resources/FleetDriverResource.php' 'scopeToCurrentFleet' 'Fleet rider ownership scope'
Assert-Contains 'app/Filament/Fleet/Resources/FleetTripResource.php' 'whereHas(''riderProfile''' 'Fleet trip ownership scope'
Assert-Contains 'app/Filament/Fleet/Resources/FleetRevenueResource.php' 'whereHas(''riderProfile''' 'Fleet revenue ownership scope'

Assert-Contains 'app/Services/DriverApprovalService.php' 'driver.approved' 'Driver approval audit fallback'
Assert-Contains 'app/Services/FleetApprovalService.php' 'fleet.approved' 'Fleet approval audit'
Assert-Contains 'app/Services/DocumentVerificationService.php' 'document.verified' 'Document verify audit'
Assert-Contains 'app/Services/VehicleVerificationService.php' 'vehicle.verified' 'Vehicle verify audit'
Assert-Contains 'app/Services/PaymentService.php' 'payment.verified' 'Payment verify audit'
Assert-Contains 'app/Services/CashLedgerService.php' 'cash_ledger.remittance_updated' 'Cash ledger audit'

if ($failures.Count -gt 0) {
    Write-Host 'Filament dashboard contract test failed:' -ForegroundColor Red
    foreach ($failure in $failures) {
        Write-Host " - $failure" -ForegroundColor Red
    }
    exit 1
}

Write-Host 'Filament dashboard contract test passed.' -ForegroundColor Green
