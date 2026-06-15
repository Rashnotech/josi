<?php

namespace App\Filament\Fleet\Resources;

use App\Enums\PaymentStatus;
use App\Enums\TripStatus;
use App\Filament\Fleet\Resources\FleetTripResource\Pages\ListFleetTrips;
use App\Filament\Fleet\Resources\FleetTripResource\Pages\ViewFleetTrip;
use App\Models\Trip;
use App\Support\Filament\DashboardAccess;
use App\Support\Filament\Display;
use BackedEnum;
use Filament\Actions\ViewAction;
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

class FleetTripResource extends Resource
{
    protected static ?string $model = Trip::class;

    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedMap;

    protected static string|\UnitEnum|null $navigationGroup = 'Operations';

    protected static ?string $navigationLabel = 'Trips / Orders';

    protected static ?int $navigationSort = 10;

    public static function getEloquentQuery(): Builder
    {
        $fleetId = DashboardAccess::fleetIdFor(Auth::user());

        return parent::getEloquentQuery()
            ->whereHas('riderProfile', fn (Builder $query): Builder => $query->where('fleet_id', $fleetId))
            ->with(['customer', 'riderProfile', 'vehicle', 'pickupZone', 'destinationZone']);
    }

    public static function form(Schema $schema): Schema
    {
        return $schema
            ->components([
                Section::make('Trip Summary')
                    ->columns(2)
                    ->schema([
                        TextInput::make('customer.name')->label('Customer')->disabled(),
                        TextInput::make('riderProfile.first_name')->label('Rider')->disabled(),
                        TextInput::make('vehicle.plate_number')->label('Vehicle')->disabled(),
                        TextInput::make('amount')->formatStateUsing(fn (mixed $state): string => Display::money($state))->disabled(),
                        TextInput::make('payment_status')->formatStateUsing(fn (mixed $state): string => Display::label($state))->disabled(),
                        TextInput::make('trip_status')->formatStateUsing(fn (mixed $state): string => Display::label($state))->disabled(),
                    ]),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('id')->label('Trip')->formatStateUsing(fn (mixed $state): string => '#'.$state)->sortable(),
                TextColumn::make('riderProfile.first_name')->label('Rider')->formatStateUsing(fn (Trip $record): string => trim(($record->riderProfile?->first_name ?? '').' '.($record->riderProfile?->last_name ?? '')) ?: 'Unassigned'),
                TextColumn::make('vehicle.plate_number')->label('Vehicle')->placeholder('Unassigned'),
                TextColumn::make('pickupZone.name')->label('Pickup')->toggleable(),
                TextColumn::make('destinationZone.name')->label('Destination')->toggleable(),
                TextColumn::make('amount')->formatStateUsing(fn (mixed $state): string => Display::money($state))->sortable(),
                TextColumn::make('payment_status')->badge()->formatStateUsing(fn (mixed $state): string => Display::label($state))->color(fn (mixed $state): string => Display::statusColor($state)),
                TextColumn::make('trip_status')->badge()->formatStateUsing(fn (mixed $state): string => Display::label($state))->color(fn (mixed $state): string => Display::statusColor($state)),
                TextColumn::make('requested_at')->dateTime('M j, Y H:i')->sortable(),
            ])
            ->filters([
                SelectFilter::make('trip_status')->options(Display::options(TripStatus::cases())),
                SelectFilter::make('payment_status')->options(Display::options(PaymentStatus::cases())),
            ])
            ->recordActions([
                ViewAction::make(),
            ])
            ->defaultSort('requested_at', 'desc')
            ->emptyStateHeading('No linked trips yet')
            ->emptyStateDescription('Trips from riders and couriers linked to your business will appear here.');
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
            'index' => ListFleetTrips::route('/'),
            'view' => ViewFleetTrip::route('/{record}'),
        ];
    }
}
