<?php

namespace App\Filament\Admin\Resources\FleetOwnerResource\Pages;

use App\Filament\Admin\Resources\FleetOwnerResource;
use Filament\Actions\DeleteAction;
use Filament\Resources\Pages\EditRecord;

class EditFleetOwner extends EditRecord
{
    protected static string $resource = FleetOwnerResource::class;

    protected function getHeaderActions(): array
    {
        return [
            DeleteAction::make(),
        ];
    }
}
