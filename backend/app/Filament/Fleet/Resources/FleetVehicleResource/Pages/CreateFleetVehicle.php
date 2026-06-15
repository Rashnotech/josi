<?php

namespace App\Filament\Fleet\Resources\FleetVehicleResource\Pages;

use App\Enums\VehicleStatus;
use App\Enums\VerificationStatus;
use App\Filament\Fleet\Resources\FleetVehicleResource;
use App\Support\Filament\DashboardAccess;
use Filament\Resources\Pages\CreateRecord;
use Illuminate\Support\Facades\Auth;

class CreateFleetVehicle extends CreateRecord
{
    protected static string $resource = FleetVehicleResource::class;

    protected function mutateFormDataBeforeCreate(array $data): array
    {
        $data['fleet_id'] = DashboardAccess::fleetIdFor(Auth::user());
        $data['vehicle_status'] = VehicleStatus::Inactive->value;
        $data['verification_status'] = VerificationStatus::Pending->value;

        return $data;
    }
}
