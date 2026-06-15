<?php

namespace App\Filament\Fleet\Resources\FleetDocumentResource\Pages;

use App\Filament\Fleet\Resources\FleetDocumentResource;
use App\Support\Filament\DashboardAccess;
use Filament\Resources\Pages\EditRecord;
use Illuminate\Support\Facades\Auth;

class EditFleetDocument extends EditRecord
{
    protected static string $resource = FleetDocumentResource::class;

    protected function mutateFormDataBeforeSave(array $data): array
    {
        $data['fleet_id'] = DashboardAccess::fleetIdFor(Auth::user());

        unset($data['verification_status'], $data['rejection_reason']);

        return $data;
    }
}
