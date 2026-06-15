<?php

namespace App\Filament\Admin\Resources\RiderResource\Pages;

use App\Filament\Admin\Resources\RiderResource;
use Filament\Actions\EditAction;
use Filament\Resources\Pages\ViewRecord;

class ViewRider extends ViewRecord
{
    protected static string $resource = RiderResource::class;

    protected function getHeaderActions(): array
    {
        return [
            EditAction::make(),
        ];
    }
}
