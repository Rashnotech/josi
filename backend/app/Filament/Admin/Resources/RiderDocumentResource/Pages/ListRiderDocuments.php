<?php

namespace App\Filament\Admin\Resources\RiderDocumentResource\Pages;

use App\Filament\Admin\Resources\RiderDocumentResource;
use Filament\Actions\CreateAction;
use Filament\Resources\Pages\ListRecords;

class ListRiderDocuments extends ListRecords
{
    protected static string $resource = RiderDocumentResource::class;

    protected function getHeaderActions(): array
    {
        return [
            CreateAction::make()->label('Upload rider document'),
        ];
    }
}
