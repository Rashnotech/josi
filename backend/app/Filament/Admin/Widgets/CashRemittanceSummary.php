<?php

namespace App\Filament\Admin\Widgets;

use App\Enums\RemittanceStatus;
use App\Models\RiderCashLedger;
use App\Support\Filament\Display;
use Filament\Widgets\Widget;

class CashRemittanceSummary extends Widget
{
    protected string $view = 'filament.widgets.cash-remittance-summary';

    protected static ?int $sort = 11;

    protected int|string|array $columnSpan = 'full';

    protected function getViewData(): array
    {
        $pending = RiderCashLedger::query()->where('remittance_status', RemittanceStatus::Pending->value)->sum('amount_to_remit');
        $partial = RiderCashLedger::query()->where('remittance_status', RemittanceStatus::PartiallyRemitted->value)->sum('amount_to_remit');
        $remitted = RiderCashLedger::query()->where('remittance_status', RemittanceStatus::Remitted->value)->sum('amount_remitted');
        $disputed = RiderCashLedger::query()->where('remittance_status', RemittanceStatus::Disputed->value)->sum('amount_to_remit');

        return [
            'pending' => Display::money($pending),
            'partial' => Display::money($partial),
            'remitted' => Display::money($remitted),
            'disputed' => Display::money($disputed),
        ];
    }
}
