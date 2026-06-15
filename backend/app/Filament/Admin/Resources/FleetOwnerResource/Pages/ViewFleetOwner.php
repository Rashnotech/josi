<?php

namespace App\Filament\Admin\Resources\FleetOwnerResource\Pages;

use App\Filament\Admin\Resources\FleetOwnerResource;
use Filament\Actions\EditAction;
use Filament\Resources\Pages\ViewRecord;

class ViewFleetOwner extends ViewRecord
{
    protected static string $resource = FleetOwnerResource::class;

    protected function getHeaderActions(): array
    {
        return [
            EditAction::make(),
        ];
    }
}
