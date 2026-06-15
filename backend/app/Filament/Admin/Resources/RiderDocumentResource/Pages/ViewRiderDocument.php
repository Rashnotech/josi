<?php

namespace App\Filament\Admin\Resources\RiderDocumentResource\Pages;

use App\Filament\Admin\Resources\RiderDocumentResource;
use Filament\Actions\EditAction;
use Filament\Resources\Pages\ViewRecord;

class ViewRiderDocument extends ViewRecord
{
    protected static string $resource = RiderDocumentResource::class;

    protected function getHeaderActions(): array
    {
        return [
            EditAction::make(),
        ];
    }
}
