<?php

namespace App\Filament\Admin\Resources\VehicleDocumentResource\Pages;

use App\Filament\Admin\Resources\VehicleDocumentResource;
use Filament\Actions\CreateAction;
use Filament\Resources\Pages\ListRecords;

class ListVehicleDocuments extends ListRecords
{
    protected static string $resource = VehicleDocumentResource::class;

    protected function getHeaderActions(): array
    {
        return [
            CreateAction::make()->label('Upload vehicle document'),
        ];
    }
}
