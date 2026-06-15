<?php

namespace App\Filament\Admin\Resources\RiderResource\Pages;

use App\Filament\Admin\Resources\RiderResource;
use Filament\Actions\CreateAction;
use Filament\Resources\Pages\ListRecords;

class ListRiders extends ListRecords
{
    protected static string $resource = RiderResource::class;

    protected function getHeaderActions(): array
    {
        return [
            CreateAction::make()->label('Add rider'),
        ];
    }
}
