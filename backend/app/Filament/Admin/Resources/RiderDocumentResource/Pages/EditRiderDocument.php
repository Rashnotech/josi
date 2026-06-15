<?php

namespace App\Filament\Admin\Resources\RiderDocumentResource\Pages;

use App\Filament\Admin\Resources\RiderDocumentResource;
use Filament\Actions\DeleteAction;
use Filament\Resources\Pages\EditRecord;

class EditRiderDocument extends EditRecord
{
    protected static string $resource = RiderDocumentResource::class;

    protected function getHeaderActions(): array
    {
        return [
            DeleteAction::make(),
        ];
    }
}
