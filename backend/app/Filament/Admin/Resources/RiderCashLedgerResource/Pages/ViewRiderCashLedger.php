<?php

namespace App\Filament\Admin\Resources\RiderCashLedgerResource\Pages;

use App\Filament\Admin\Resources\RiderCashLedgerResource;
use Filament\Actions\EditAction;
use Filament\Resources\Pages\ViewRecord;

class ViewRiderCashLedger extends ViewRecord
{
    protected static string $resource = RiderCashLedgerResource::class;

    protected function getHeaderActions(): array
    {
        return [
            EditAction::make(),
        ];
    }
}
