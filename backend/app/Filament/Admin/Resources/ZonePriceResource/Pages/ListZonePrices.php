<?php

namespace App\Filament\Admin\Resources\ZonePriceResource\Pages;

use App\Filament\Admin\Resources\ZonePriceResource;
use Filament\Actions\CreateAction;
use Filament\Resources\Pages\ListRecords;

class ListZonePrices extends ListRecords
{
    protected static string $resource = ZonePriceResource::class;

    protected function getHeaderActions(): array
    {
        return [
            CreateAction::make()->label('Create price'),
        ];
    }
}
