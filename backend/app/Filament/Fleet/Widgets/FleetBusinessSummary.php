<?php

namespace App\Filament\Fleet\Widgets;

use App\Support\Filament\DashboardAccess;
use App\Support\Filament\Display;
use Filament\Widgets\Widget;
use Illuminate\Support\Facades\Auth;

class FleetBusinessSummary extends Widget
{
    protected string $view = 'filament.widgets.fleet-business-summary';

    protected int|string|array $columnSpan = 'full';

    protected static ?int $sort = -20;

    protected function getViewData(): array
    {
        $fleet = DashboardAccess::fleetFor(Auth::user());

        return [
            'fleet' => $fleet,
            'statusLabel' => Display::label($fleet?->application_status),
            'statusColor' => Display::statusColor($fleet?->application_status),
            'vehicles' => $fleet?->vehicles()->count() ?? 0,
            'drivers' => $fleet?->riderProfiles()->count() ?? 0,
            'documents' => $fleet?->fleetDocuments()->count() ?? 0,
        ];
    }
}
