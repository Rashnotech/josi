<?php

namespace App\Filament\Fleet\Widgets;

use App\Enums\VerificationStatus;
use App\Support\Filament\DashboardAccess;
use App\Support\Filament\Display;
use Filament\Widgets\Widget;
use Illuminate\Support\Facades\Auth;

class FleetDocumentsStatus extends Widget
{
    protected string $view = 'filament.widgets.fleet-documents-status';

    protected int|string|array $columnSpan = 'full';

    protected static ?int $sort = 10;

    protected function getViewData(): array
    {
        $fleet = DashboardAccess::fleetFor(Auth::user());

        $items = [];

        foreach (VerificationStatus::cases() as $status) {
            $items[] = [
                'label' => Display::label($status),
                'color' => Display::statusColor($status),
                'count' => $fleet?->fleetDocuments()->where('verification_status', $status->value)->count() ?? 0,
            ];
        }

        return ['items' => $items];
    }
}
