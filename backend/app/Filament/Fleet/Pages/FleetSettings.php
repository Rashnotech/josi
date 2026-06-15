<?php

namespace App\Filament\Fleet\Pages;

use BackedEnum;
use Filament\Pages\Page;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Components\Text;
use Filament\Schemas\Schema;
use Filament\Support\Enums\FontWeight;
use Filament\Support\Icons\Heroicon;

class FleetSettings extends Page
{
    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedCog6Tooth;

    protected static string|\UnitEnum|null $navigationGroup = 'Settings';

    protected static ?string $navigationLabel = 'Settings';

    protected static ?int $navigationSort = 10;

    public function content(Schema $schema): Schema
    {
        return $schema->components([
            Section::make('Fleet Account')
                ->schema([
                    Text::make('Profile, vehicles, documents, linked trips, and revenue are scoped to this signed-in business.')
                        ->weight(FontWeight::Medium)
                        ->color('gray'),
                ]),
        ]);
    }
}
