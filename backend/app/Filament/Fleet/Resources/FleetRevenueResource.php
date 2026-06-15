<?php

namespace App\Filament\Fleet\Resources;

use App\Enums\RemittanceStatus;
use App\Filament\Fleet\Resources\FleetRevenueResource\Pages\ListFleetRevenue;
use App\Filament\Fleet\Resources\FleetRevenueResource\Pages\ViewFleetRevenue;
use App\Models\RiderCashLedger;
use App\Support\Filament\DashboardAccess;
use App\Support\Filament\Display;
use BackedEnum;
use Filament\Actions\ViewAction;
use Filament\Forms\Components\Textarea;
use Filament\Forms\Components\TextInput;
use Filament\Resources\Resource;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Schema;
use Filament\Support\Icons\Heroicon;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Support\Facades\Auth;

class FleetRevenueResource extends Resource
{
    protected static ?string $model = RiderCashLedger::class;

    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedWallet;

    protected static string|\UnitEnum|null $navigationGroup = 'Finance';

    protected static ?string $navigationLabel = 'Wallet / Revenue';

    protected static ?int $navigationSort = 10;

    public static function getEloquentQuery(): Builder
    {
        $fleetId = DashboardAccess::fleetIdFor(Auth::user());

        return parent::getEloquentQuery()
            ->whereHas('riderProfile', fn (Builder $query): Builder => $query->where('fleet_id', $fleetId))
            ->with(['riderProfile', 'trip']);
    }

    public static function form(Schema $schema): Schema
    {
        return $schema
            ->components([
                Section::make('Revenue')
                    ->columns(3)
                    ->schema([
                        TextInput::make('amount_collected')->formatStateUsing(fn (mixed $state): string => Display::money($state))->disabled(),
                        TextInput::make('rider_share')->formatStateUsing(fn (mixed $state): string => Display::money($state))->disabled(),
                        TextInput::make('company_share')->formatStateUsing(fn (mixed $state): string => Display::money($state))->disabled(),
                        TextInput::make('amount_to_remit')->formatStateUsing(fn (mixed $state): string => Display::money($state))->disabled(),
                        TextInput::make('amount_remitted')->formatStateUsing(fn (mixed $state): string => Display::money($state))->disabled(),
                        TextInput::make('remittance_status')->formatStateUsing(fn (mixed $state): string => Display::label($state))->disabled(),
                        Textarea::make('notes')->disabled()->columnSpanFull(),
                    ]),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('riderProfile.first_name')->label('Rider')->formatStateUsing(fn (RiderCashLedger $record): string => trim(($record->riderProfile?->first_name ?? '').' '.($record->riderProfile?->last_name ?? '')) ?: 'Unassigned'),
                TextColumn::make('trip_id')->label('Trip')->formatStateUsing(fn (mixed $state): string => '#'.$state),
                TextColumn::make('amount_collected')->formatStateUsing(fn (mixed $state): string => Display::money($state))->sortable(),
                TextColumn::make('company_share')->formatStateUsing(fn (mixed $state): string => Display::money($state))->sortable(),
                TextColumn::make('amount_to_remit')->formatStateUsing(fn (mixed $state): string => Display::money($state))->sortable(),
                TextColumn::make('amount_remitted')->formatStateUsing(fn (mixed $state): string => Display::money($state))->sortable(),
                TextColumn::make('remittance_status')->badge()->formatStateUsing(fn (mixed $state): string => Display::label($state))->color(fn (mixed $state): string => Display::statusColor($state)),
                TextColumn::make('created_at')->dateTime('M j, Y')->sortable(),
            ])
            ->filters([
                SelectFilter::make('remittance_status')->options(Display::options(RemittanceStatus::cases())),
            ])
            ->recordActions([
                ViewAction::make(),
            ])
            ->defaultSort('created_at', 'desc')
            ->emptyStateHeading('No revenue entries yet')
            ->emptyStateDescription('Cash and revenue ledger rows from linked trips will appear here.');
    }

    public static function canCreate(): bool
    {
        return false;
    }

    public static function canEdit($record): bool
    {
        return false;
    }

    public static function getPages(): array
    {
        return [
            'index' => ListFleetRevenue::route('/'),
            'view' => ViewFleetRevenue::route('/{record}'),
        ];
    }
}
