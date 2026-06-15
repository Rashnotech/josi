<?php

namespace App\Filament\Fleet\Resources\FleetVehicleResource\Pages;

use App\Filament\Fleet\Resources\FleetVehicleResource;
use Filament\Actions\CreateAction;
use Filament\Resources\Pages\ListRecords;

class ListFleetVehicles extends ListRecords
{
    protected static string $resource = FleetVehicleResource::class;

    protected function getHeaderActions(): array
    {
        return [
            CreateAction::make()->label('Add vehicle'),
        ];
    }
}
