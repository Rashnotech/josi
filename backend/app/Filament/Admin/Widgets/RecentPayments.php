<?php

namespace App\Filament\Admin\Widgets;

use App\Models\Payment;
use App\Support\Filament\Display;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;
use Filament\Widgets\TableWidget;

class RecentPayments extends TableWidget
{
    protected static ?string $heading = 'Recent Payments';

    protected static ?int $sort = 22;

    public function table(Table $table): Table
    {
        return $table
            ->query(Payment::query()->with('user')->latest()->limit(8))
            ->columns([
                TextColumn::make('payment_reference')->label('Reference')->placeholder('Manual'),
                TextColumn::make('user.name')->label('Payer')->placeholder('Unknown'),
                TextColumn::make('amount')->formatStateUsing(fn (mixed $state): string => Display::money($state)),
                TextColumn::make('payment_status')->badge()->formatStateUsing(fn (mixed $state): string => Display::label($state))->color(fn (mixed $state): string => Display::statusColor($state)),
                TextColumn::make('created_at')->dateTime('M j, H:i'),
            ])
            ->paginated(false);
    }
}
