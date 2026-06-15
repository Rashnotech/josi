<?php

namespace App\Filament\Admin\Resources;

use App\Enums\PaymentMethod;
use App\Enums\PaymentStatus;
use App\Enums\TripStatus;
use App\Filament\Admin\Resources\TripResource\Pages\CreateTrip;
use App\Filament\Admin\Resources\TripResource\Pages\EditTrip;
use App\Filament\Admin\Resources\TripResource\Pages\ListTrips;
use App\Filament\Admin\Resources\TripResource\Pages\ViewTrip;
use App\Models\RiderProfile;
use App\Models\Trip;
use App\Models\User;
use App\Models\Vehicle;
use App\Models\Zone;
use App\Support\Filament\Display;
use BackedEnum;
use Filament\Actions\Action;
use Filament\Actions\DeleteAction;
use Filament\Actions\EditAction;
use Filament\Actions\ViewAction;
use Filament\Forms\Components\DateTimePicker;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\Textarea;
use Filament\Forms\Components\TextInput;
use Filament\Resources\Resource;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Components\Tabs;
use Filament\Schemas\Components\Tabs\Tab;
use Filament\Schemas\Schema;
use Filament\Support\Icons\Heroicon;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Support\Facades\Auth;

class TripResource extends Resource
{
    protected static ?string $model = Trip::class;

    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedMap;

    protected static string|\UnitEnum|null $navigationGroup = 'Operations';

    protected static ?string $navigationLabel = 'Trips / Orders';

    protected static ?int $navigationSort = 10;

    public static function getEloquentQuery(): Builder
    {
        return parent::getEloquentQuery()->with(['customer', 'riderProfile.user', 'vehicle', 'pickupZone', 'destinationZone']);
    }

    public static function form(Schema $schema): Schema
    {
        return $schema
            ->components([
                Tabs::make('Trip')
                    ->columnSpanFull()
                    ->tabs([
                        Tab::make('Assignment')
                            ->schema([
                                Section::make()->columns(2)->schema([
                                    Select::make('customer_id')->label('Customer')->options(fn (): array => User::query()->orderBy('name')->pluck('name', 'id')->all())->searchable()->preload(),
                                    Select::make('driver_profile_id')->label('Rider/courier')->options(fn (): array => RiderProfile::query()->orderBy('first_name')->get()->mapWithKeys(fn (RiderProfile $profile): array => [$profile->getKey() => trim("{$profile->first_name} {$profile->last_name}")])->all())->searchable()->preload(),
                                    Select::make('vehicle_id')->options(fn (): array => Vehicle::query()->orderBy('plate_number')->pluck('plate_number', 'id')->all())->searchable()->preload(),
                                ]),
                            ]),
                        Tab::make('Route')
                            ->schema([
                                Section::make()->columns(2)->schema([
                                    Select::make('pickup_zone_id')->relationship('pickupZone', 'name')->searchable()->preload(),
                                    Select::make('destination_zone_id')->relationship('destinationZone', 'name')->searchable()->preload(),
                                    Textarea::make('pickup_address')->required(),
                                    Textarea::make('destination_address')->required(),
                                    TextInput::make('pickup_latitude')->numeric(),
                                    TextInput::make('pickup_longitude')->numeric(),
                                    TextInput::make('destination_latitude')->numeric(),
                                    TextInput::make('destination_longitude')->numeric(),
                                ]),
                            ]),
                        Tab::make('Payment and Status')
                            ->schema([
                                Section::make()->columns(3)->schema([
                                    TextInput::make('amount')->numeric()->prefix('NGN')->required(),
                                    Select::make('payment_method')->options(Display::options(PaymentMethod::cases()))->required(),
                                    Select::make('payment_status')->options(Display::options(PaymentStatus::cases()))->required(),
                                    Select::make('trip_status')->options(Display::options(TripStatus::cases()))->required(),
                                    Textarea::make('cancellation_reason')->columnSpanFull(),
                                ]),
                            ]),
                        Tab::make('Timeline')
                            ->schema([
                                Section::make()->columns(3)->schema([
                                    DateTimePicker::make('requested_at')->seconds(false),
                                    DateTimePicker::make('accepted_at')->seconds(false),
                                    DateTimePicker::make('started_at')->seconds(false),
                                    DateTimePicker::make('completed_at')->seconds(false),
                                    DateTimePicker::make('cancelled_at')->seconds(false),
                                ]),
                            ]),
                    ]),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('id')->label('Trip')->sortable()->formatStateUsing(fn (mixed $state): string => '#'.$state),
                TextColumn::make('customer.name')->label('Customer')->searchable()->placeholder('Guest'),
                TextColumn::make('riderProfile.first_name')->label('Rider')->formatStateUsing(fn (Trip $record): string => trim(($record->riderProfile?->first_name ?? '').' '.($record->riderProfile?->last_name ?? '')) ?: 'Unassigned'),
                TextColumn::make('vehicle.plate_number')->label('Vehicle')->searchable()->placeholder('Unassigned'),
                TextColumn::make('pickupZone.name')->label('Pickup')->searchable()->toggleable(),
                TextColumn::make('destinationZone.name')->label('Destination')->searchable()->toggleable(),
                TextColumn::make('amount')->formatStateUsing(fn (mixed $state): string => Display::money($state))->sortable(),
                TextColumn::make('payment_method')->badge()->formatStateUsing(fn (mixed $state): string => Display::label($state))->color('gray'),
                TextColumn::make('payment_status')->badge()->formatStateUsing(fn (mixed $state): string => Display::label($state))->color(fn (mixed $state): string => Display::statusColor($state)),
                TextColumn::make('trip_status')->badge()->formatStateUsing(fn (mixed $state): string => Display::label($state))->color(fn (mixed $state): string => Display::statusColor($state)),
                TextColumn::make('requested_at')->dateTime('M j, Y H:i')->sortable()->placeholder('Not set'),
            ])
            ->filters([
                SelectFilter::make('trip_status')->options(Display::options(TripStatus::cases())),
                SelectFilter::make('payment_status')->options(Display::options(PaymentStatus::cases())),
                SelectFilter::make('payment_method')->options(Display::options(PaymentMethod::cases())),
            ])
            ->recordActions([
                ViewAction::make(),
                EditAction::make(),
                Action::make('cancel')
                    ->label('Cancel trip')
                    ->icon('heroicon-o-x-circle')
                    ->color('danger')
                    ->form([Textarea::make('reason')->label('Cancellation reason')->required()->maxLength(1000)])
                    ->visible(fn (Trip $record): bool => $record->trip_status !== TripStatus::Cancelled)
                    ->action(function (Trip $record, array $data): void {
                        $record->forceFill([
                            'trip_status' => TripStatus::Cancelled,
                            'cancelled_at' => now(),
                            'cancellation_reason' => $data['reason'],
                        ])->save();

                        app(\App\Services\AuditLogService::class)->log('trip.cancelled', Auth::user(), $record, [], $record->only(['trip_status', 'cancelled_at', 'cancellation_reason']));
                    }),
                DeleteAction::make(),
            ])
            ->defaultSort('requested_at', 'desc')
            ->emptyStateHeading('No trips yet')
            ->emptyStateDescription('Trip and order records will appear here when customers request logistics service.');
    }

    public static function getPages(): array
    {
        return [
            'index' => ListTrips::route('/'),
            'create' => CreateTrip::route('/create'),
            'view' => ViewTrip::route('/{record}'),
            'edit' => EditTrip::route('/{record}/edit'),
        ];
    }
}
