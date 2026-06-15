<?php

namespace App\Filament\Fleet\Pages;

use App\Filament\Fleet\Widgets\FleetBusinessSummary;
use App\Filament\Fleet\Widgets\FleetDocumentsStatus;
use App\Filament\Fleet\Widgets\FleetOverviewStats;
use App\Filament\Fleet\Widgets\FleetRecentActivity;
use Filament\Pages\Dashboard;

class FleetDashboard extends Dashboard
{
    public function getColumns(): int|array
    {
        return 2;
    }

    public function getWidgets(): array
    {
        return [
            FleetBusinessSummary::class,
            FleetOverviewStats::class,
            FleetDocumentsStatus::class,
            FleetRecentActivity::class,
        ];
    }
}
