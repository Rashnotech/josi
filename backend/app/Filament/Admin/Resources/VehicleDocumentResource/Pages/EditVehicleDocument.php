<?php

namespace App\Filament\Admin\Resources\VehicleDocumentResource\Pages;

use App\Filament\Admin\Resources\VehicleDocumentResource;
use Filament\Actions\DeleteAction;
use Filament\Resources\Pages\EditRecord;

class EditVehicleDocument extends EditRecord
{
    protected static string $resource = VehicleDocumentResource::class;

    protected function getHeaderActions(): array
    {
        return [
            DeleteAction::make(),
        ];
    }
}
