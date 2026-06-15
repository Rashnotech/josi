<?php

namespace App\Filament\Fleet\Resources;

use App\Enums\VehicleStatus;
use App\Enums\VehicleType;
use App\Enums\VerificationStatus;
use App\Filament\Fleet\Resources\FleetVehicleResource\Pages\CreateFleetVehicle;
use App\Filament\Fleet\Resources\FleetVehicleResource\Pages\EditFleetVehicle;
use App\Filament\Fleet\Resources\FleetVehicleResource\Pages\ListFleetVehicles;
use App\Models\RiderProfile;
use App\Models\Vehicle;
use App\Support\Filament\DashboardAccess;
use App\Support\Filament\Display;
use BackedEnum;
use Filament\Actions\EditAction;
use Filament\Forms\Components\Hidden;
use Filament\Forms\Components\Select;
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

class FleetVehicleResource extends Resource
{
    protected static ?string $model = Vehicle::class;

    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedTruck;

    protected static string|\UnitEnum|null $navigationGroup = 'Fleet';

    protected static ?string $navigationLabel = 'Vehicles';

    protected static ?int $navigationSort = 10;

    protected static ?string $recordTitleAttribute = 'plate_number';

    public static function getEloquentQuery(): Builder
    {
        return DashboardAccess::scopeToCurrentFleet(parent::getEloquentQuery()->with(['riderProfile']), Auth::user());
    }

    public static function form(Schema $schema): Schema
    {
        $fleetId = DashboardAccess::fleetIdFor(Auth::user());

        return $schema
            ->components([
                Hidden::make('fleet_id')->default($fleetId),
                Section::make('Vehicle')
                    ->columns(3)
                    ->schema([
                        Select::make('driver_profile_id')
                            ->label('Assigned rider/courier')
                            ->options(fn (): array => RiderProfile::query()
                                ->where('fleet_id', $fleetId)
                                ->orderBy('first_name')
                                ->get()
                                ->mapWithKeys(fn (RiderProfile $profile): array => [$profile->getKey() => trim("{$profile->first_name} {$profile->last_name}")])
                                ->all())
                            ->searchable()
                            ->preload(),
                        Select::make('vehicle_type')->options(Display::options(VehicleType::cases()))->required(),
                        TextInput::make('brand')->required()->maxLength(120),
                        TextInput::make('model')->required()->maxLength(120),
                        TextInput::make('color')->required()->maxLength(80),
                        TextInput::make('plate_number')->required()->maxLength(50)->unique(ignoreRecord: true),
                        TextInput::make('chassis_number')->maxLength(120),
                        TextInput::make('engine_number')->maxLength(120),
                        Hidden::make('vehicle_status')->default(VehicleStatus::Inactive->value),
                        Hidden::make('verification_status')->default(VerificationStatus::Pending->value),
                    ]),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('plate_number')->searchable()->sortable()->weight('medium'),
                TextColumn::make('vehicle_type')->badge()->formatStateUsing(fn (mixed $state): string => Display::label($state))->color('gray'),
                TextColumn::make('brand')->searchable(),
                TextColumn::make('model')->searchable(),
                TextColumn::make('vehicle_status')->badge()->formatStateUsing(fn (mixed $state): string => Display::label($state))->color(fn (mixed $state): string => Display::statusColor($state)),
                TextColumn::make('verification_status')->badge()->formatStateUsing(fn (mixed $state): string => Display::label($state))->color(fn (mixed $state): string => Display::statusColor($state)),
                TextColumn::make('created_at')->dateTime('M j, Y')->sortable(),
            ])
            ->filters([
                SelectFilter::make('vehicle_status')->options(Display::options(VehicleStatus::cases())),
                SelectFilter::make('verification_status')->options(Display::options(VerificationStatus::cases())),
            ])
            ->recordActions([
                EditAction::make(),
            ])
            ->defaultSort('created_at', 'desc')
            ->emptyStateHeading('No vehicles yet')
            ->emptyStateDescription('Add your fleet vehicles here. Josi admins will verify them before activation.');
    }

    public static function getPages(): array
    {
        return [
            'index' => ListFleetVehicles::route('/'),
            'create' => CreateFleetVehicle::route('/create'),
            'edit' => EditFleetVehicle::route('/{record}/edit'),
        ];
    }
}
