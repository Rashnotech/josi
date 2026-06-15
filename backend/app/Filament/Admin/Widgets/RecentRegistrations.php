<?php

namespace App\Filament\Admin\Widgets;

use App\Models\User;
use App\Support\Filament\Display;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;
use Filament\Widgets\TableWidget;

class RecentRegistrations extends TableWidget
{
    protected static ?string $heading = 'Recent Registrations';

    protected static ?int $sort = 20;

    public function table(Table $table): Table
    {
        return $table
            ->query(User::query()->latest()->limit(8))
            ->columns([
                TextColumn::make('name')->weight('medium')->searchable(),
                TextColumn::make('role')->badge()->formatStateUsing(fn (mixed $state): string => Display::label($state))->color('gray'),
                TextColumn::make('status')->badge()->formatStateUsing(fn (mixed $state): string => Display::label($state))->color(fn (mixed $state): string => Display::statusColor($state)),
                TextColumn::make('created_at')->dateTime('M j, H:i'),
            ])
            ->paginated(false);
    }
}
