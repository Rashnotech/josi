<?php

namespace App\Filament\Admin\Widgets;

use App\Models\Trip;
use App\Support\Filament\Display;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;
use Filament\Widgets\TableWidget;

class RecentTrips extends TableWidget
{
    protected static ?string $heading = 'Recent Trips';

    protected static ?int $sort = 21;

    public function table(Table $table): Table
    {
        return $table
            ->query(Trip::query()->with(['customer', 'riderProfile'])->latest()->limit(8))
            ->columns([
                TextColumn::make('id')->label('Trip')->formatStateUsing(fn (mixed $state): string => '#'.$state),
                TextColumn::make('customer.name')->label('Customer')->placeholder('Guest'),
                TextColumn::make('amount')->formatStateUsing(fn (mixed $state): string => Display::money($state)),
                TextColumn::make('trip_status')->badge()->formatStateUsing(fn (mixed $state): string => Display::label($state))->color(fn (mixed $state): string => Display::statusColor($state)),
                TextColumn::make('created_at')->dateTime('M j, H:i'),
            ])
            ->paginated(false);
    }
}
