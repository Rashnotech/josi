<?php

namespace App\Filament\Admin\Resources\FleetDocumentResource\Pages;

use App\Filament\Admin\Resources\FleetDocumentResource;
use Filament\Actions\EditAction;
use Filament\Resources\Pages\ViewRecord;

class ViewFleetDocument extends ViewRecord
{
    protected static string $resource = FleetDocumentResource::class;

    protected function getHeaderActions(): array
    {
        return [
            EditAction::make(),
        ];
    }
}
