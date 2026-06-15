<?php

namespace App\Filament\Admin\Pages;

use App\Enums\TripStatus;
use App\Models\Trip;
use App\Support\Filament\Display;
use BackedEnum;
use Filament\Pages\Page;
use Filament\Schemas\Components\Grid;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Components\Text;
use Filament\Schemas\Schema;
use Filament\Support\Enums\FontWeight;
use Filament\Support\Icons\Heroicon;

class TripReport extends Page
{
    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedChartBar;

    protected static string|\UnitEnum|null $navigationGroup = 'Reports';

    protected static ?string $navigationLabel = 'Trip Report';

    protected static ?int $navigationSort = 30;

    public function content(Schema $schema): Schema
    {
        return $schema->components([
            Grid::make(['default' => 1, 'md' => 2, 'xl' => 3])
                ->schema(
                    collect(TripStatus::cases())
                        ->map(fn (TripStatus $status): Section => $this->statusSection($status))
                        ->all()
                ),
        ]);
    }

    private function statusSection(TripStatus $status): Section
    {
        $query = Trip::query()->where('trip_status', $status->value);

        return Section::make(Display::label($status))
            ->schema([
                Text::make('Trips: '.number_format((clone $query)->count()))
                    ->weight(FontWeight::SemiBold)
                    ->color(Display::statusColor($status)),
                Text::make('Amount: '.Display::money((clone $query)->sum('amount')))
                    ->color('gray'),
            ]);
    }
}
