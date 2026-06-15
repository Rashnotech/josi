<?php

namespace App\Filament\Fleet\Widgets;

use App\Models\Trip;
use App\Support\Filament\DashboardAccess;
use App\Support\Filament\Display;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;
use Filament\Widgets\TableWidget;
use Illuminate\Support\Facades\Auth;

class FleetRecentActivity extends TableWidget
{
    protected static ?string $heading = 'Recent Activity';

    protected static ?int $sort = 20;

    public function table(Table $table): Table
    {
        $fleetId = DashboardAccess::fleetIdFor(Auth::user());

        return $table
            ->query(
                Trip::query()
                    ->whereHas('riderProfile', fn ($query) => $query->where('fleet_id', $fleetId))
                    ->with(['riderProfile', 'vehicle'])
                    ->latest()
                    ->limit(8)
            )
            ->columns([
                TextColumn::make('id')->label('Trip')->formatStateUsing(fn (mixed $state): string => '#'.$state),
                TextColumn::make('riderProfile.first_name')->label('Rider')->formatStateUsing(fn (Trip $record): string => trim(($record->riderProfile?->first_name ?? '').' '.($record->riderProfile?->last_name ?? '')) ?: 'Unassigned'),
                TextColumn::make('vehicle.plate_number')->label('Vehicle')->placeholder('Unassigned'),
                TextColumn::make('amount')->formatStateUsing(fn (mixed $state): string => Display::money($state)),
                TextColumn::make('trip_status')->badge()->formatStateUsing(fn (mixed $state): string => Display::label($state))->color(fn (mixed $state): string => Display::statusColor($state)),
                TextColumn::make('created_at')->dateTime('M j, H:i'),
            ])
            ->paginated(false);
    }
}
