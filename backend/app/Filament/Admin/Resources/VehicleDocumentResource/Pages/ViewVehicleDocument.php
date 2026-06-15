<?php

namespace App\Filament\Admin\Resources\VehicleDocumentResource\Pages;

use App\Filament\Admin\Resources\VehicleDocumentResource;
use Filament\Actions\EditAction;
use Filament\Resources\Pages\ViewRecord;

class ViewVehicleDocument extends ViewRecord
{
    protected static string $resource = VehicleDocumentResource::class;

    protected function getHeaderActions(): array
    {
        return [
            EditAction::make(),
        ];
    }
}
