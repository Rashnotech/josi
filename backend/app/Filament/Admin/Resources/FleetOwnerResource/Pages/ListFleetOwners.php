<?php

namespace App\Filament\Admin\Resources\FleetOwnerResource\Pages;

use App\Filament\Admin\Resources\FleetOwnerResource;
use Filament\Actions\CreateAction;
use Filament\Resources\Pages\ListRecords;

class ListFleetOwners extends ListRecords
{
    protected static string $resource = FleetOwnerResource::class;

    protected function getHeaderActions(): array
    {
        return [
            CreateAction::make()->label('Add pack owner'),
        ];
    }
}
