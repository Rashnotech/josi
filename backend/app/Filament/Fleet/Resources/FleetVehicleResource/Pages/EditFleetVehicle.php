<?php

namespace App\Filament\Fleet\Resources\FleetVehicleResource\Pages;

use App\Filament\Fleet\Resources\FleetVehicleResource;
use App\Support\Filament\DashboardAccess;
use Filament\Resources\Pages\EditRecord;
use Illuminate\Support\Facades\Auth;

class EditFleetVehicle extends EditRecord
{
    protected static string $resource = FleetVehicleResource::class;

    protected function mutateFormDataBeforeSave(array $data): array
    {
        $data['fleet_id'] = DashboardAccess::fleetIdFor(Auth::user());

        unset($data['vehicle_status'], $data['verification_status']);

        return $data;
    }
}
