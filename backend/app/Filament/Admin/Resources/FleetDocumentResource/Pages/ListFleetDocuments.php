<?php

namespace App\Filament\Admin\Resources\FleetDocumentResource\Pages;

use App\Filament\Admin\Resources\FleetDocumentResource;
use Filament\Actions\CreateAction;
use Filament\Resources\Pages\ListRecords;

class ListFleetDocuments extends ListRecords
{
    protected static string $resource = FleetDocumentResource::class;

    protected function getHeaderActions(): array
    {
        return [
            CreateAction::make()->label('Upload fleet document'),
        ];
    }
}
