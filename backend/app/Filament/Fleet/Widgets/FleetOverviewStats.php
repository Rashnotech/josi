<?php

namespace App\Filament\Fleet\Widgets;

use App\Enums\VerificationStatus;
use App\Models\RiderCashLedger;
use App\Models\Trip;
use App\Models\Vehicle;
use App\Support\Filament\DashboardAccess;
use App\Support\Filament\Display;
use Filament\Widgets\StatsOverviewWidget;
use Filament\Widgets\StatsOverviewWidget\Stat;
use Illuminate\Support\Facades\Auth;

class FleetOverviewStats extends StatsOverviewWidget
{
    protected static ?int $sort = -10;

    protected function getStats(): array
    {
        $fleetId = DashboardAccess::fleetIdFor(Auth::user());

        $tripQuery = Trip::query()->whereHas('riderProfile', fn ($query) => $query->where('fleet_id', $fleetId));
        $ledgerQuery = RiderCashLedger::query()->whereHas('riderProfile', fn ($query) => $query->where('fleet_id', $fleetId));

        return [
            Stat::make('Total vehicles', number_format(Vehicle::query()->where('fleet_id', $fleetId)->count()))->icon('heroicon-o-truck')->color('gray'),
            Stat::make('Approved vehicles', number_format(Vehicle::query()->where('fleet_id', $fleetId)->where('verification_status', VerificationStatus::Verified->value)->count()))->icon('heroicon-o-check-circle')->color('success'),
            Stat::make('Pending vehicle verification', number_format(Vehicle::query()->where('fleet_id', $fleetId)->where('verification_status', VerificationStatus::Pending->value)->count()))->icon('heroicon-o-clock')->color('warning'),
            Stat::make('Linked riders/couriers', number_format(DashboardAccess::fleetFor(Auth::user())?->riderProfiles()->count() ?? 0))->icon('heroicon-o-users')->color('info'),
            Stat::make('Total trips', number_format((clone $tripQuery)->count()))->icon('heroicon-o-map')->color('gray'),
            Stat::make('Cash / revenue summary', Display::money((clone $ledgerQuery)->sum('amount_collected')))->icon('heroicon-o-wallet')->color('success'),
        ];
    }
}
