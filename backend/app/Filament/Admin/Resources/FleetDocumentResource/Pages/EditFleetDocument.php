<?php

namespace App\Filament\Admin\Resources\FleetDocumentResource\Pages;

use App\Filament\Admin\Resources\FleetDocumentResource;
use Filament\Actions\DeleteAction;
use Filament\Resources\Pages\EditRecord;

class EditFleetDocument extends EditRecord
{
    protected static string $resource = FleetDocumentResource::class;

    protected function getHeaderActions(): array
    {
        return [
            DeleteAction::make(),
        ];
    }
}
