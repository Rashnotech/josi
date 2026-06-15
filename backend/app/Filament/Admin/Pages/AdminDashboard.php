<?php

namespace App\Filament\Admin\Pages;

use App\Filament\Admin\Widgets\AdminDashboardHero;
use App\Filament\Admin\Widgets\AdminOverviewStats;
use App\Filament\Admin\Widgets\ApplicationStatusChart;
use App\Filament\Admin\Widgets\CashRemittanceSummary;
use App\Filament\Admin\Widgets\RecentPayments;
use App\Filament\Admin\Widgets\RecentRegistrations;
use App\Filament\Admin\Widgets\RecentTrips;
use Filament\Pages\Dashboard;

class AdminDashboard extends Dashboard
{
    public function getColumns(): int|array
    {
        return 2;
    }

    public function getWidgets(): array
    {
        return [
            AdminDashboardHero::class,
            AdminOverviewStats::class,
            ApplicationStatusChart::class,
            CashRemittanceSummary::class,
            RecentRegistrations::class,
            RecentTrips::class,
            RecentPayments::class,
        ];
    }
}
