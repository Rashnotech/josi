<?php

namespace App\Filament\Admin\Resources;

use App\Enums\VehicleStatus;
use App\Enums\VehicleType;
use App\Enums\VerificationStatus;
use App\Filament\Admin\Resources\VehicleResource\Pages\CreateVehicle;
use App\Filament\Admin\Resources\VehicleResource\Pages\EditVehicle;
use App\Filament\Admin\Resources\VehicleResource\Pages\ListVehicles;
use App\Filament\Admin\Resources\VehicleResource\Pages\ViewVehicle;
use App\Models\Fleet;
use App\Models\RiderProfile;
use App\Models\Vehicle;
use App\Support\Filament\Display;
use App\Support\Filament\ResourceActions;
use BackedEnum;
use Filament\Actions\ActionGroup;
use Filament\Actions\DeleteAction;
use Filament\Actions\EditAction;
use Filament\Actions\ViewAction;
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

class VehicleResource extends Resource
{
    protected static ?string $model = Vehicle::class;

    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedTruck;

    protected static string|\UnitEnum|null $navigationGroup = 'Fleet & Vehicles';

    protected static ?int $navigationSort = 10;

    protected static ?string $recordTitleAttribute = 'plate_number';

    public static function getEloquentQuery(): Builder
    {
        return parent::getEloquentQuery()
            ->with(['fleet', 'riderProfile.user'])
            ->withCount('vehicleDocuments');
    }

    public static function form(Schema $schema): Schema
    {
        return $schema
            ->components([
                Section::make('Ownership')
                    ->columns(2)
                    ->schema([
                        Select::make('fleet_id')
                            ->label('Pack owner')
                            ->options(fn (): array => Fleet::query()->orderBy('business_name')->pluck('business_name', 'id')->all())
                            ->searchable()
                            ->preload(),
                        Select::make('driver_profile_id')
                            ->label('Assigned rider/courier')
                            ->options(fn (): array => RiderProfile::query()
                                ->with('user')
                                ->orderBy('first_name')
                                ->get()
                                ->mapWithKeys(fn (RiderProfile $profile): array => [
                                    $profile->getKey() => trim("{$profile->first_name} {$profile->last_name}") ?: $profile->user?->name,
                                ])
                                ->all())
                            ->searchable()
                            ->preload(),
                    ]),
                Section::make('Vehicle Details')
                    ->columns(3)
                    ->schema([
                        Select::make('vehicle_type')->options(Display::options(VehicleType::cases()))->required(),
                        TextInput::make('brand')->required()->maxLength(120),
                        TextInput::make('model')->required()->maxLength(120),
                        TextInput::make('color')->required()->maxLength(80),
                        TextInput::make('plate_number')->required()->maxLength(50)->unique(ignoreRecord: true),
                        TextInput::make('chassis_number')->maxLength(120),
                        TextInput::make('engine_number')->maxLength(120),
                    ]),
                Section::make('Status')
                    ->columns(2)
                    ->schema([
                        Select::make('vehicle_status')->options(Display::options(VehicleStatus::cases()))->required()->default(VehicleStatus::Inactive->value),
                        Select::make('verification_status')->options(Display::options(VerificationStatus::cases()))->required()->default(VerificationStatus::Pending->value),
                    ]),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('plate_number')->searchable()->sortable()->weight('medium'),
                TextColumn::make('fleet.business_name')->label('Pack owner')->searchable()->placeholder('Unassigned'),
                TextColumn::make('riderProfile.first_name')->label('Driver')->formatStateUsing(fn (Vehicle $record): string => trim(($record->riderProfile?->first_name ?? '').' '.($record->riderProfile?->last_name ?? '')) ?: 'Unassigned')->searchable(),
                TextColumn::make('vehicle_type')->badge()->formatStateUsing(fn (mixed $state): string => Display::label($state))->color('gray'),
                TextColumn::make('brand')->searchable()->sortable(),
                TextColumn::make('model')->searchable()->sortable(),
                TextColumn::make('vehicle_status')->badge()->formatStateUsing(fn (mixed $state): string => Display::label($state))->color(fn (mixed $state): string => Display::statusColor($state)),
                TextColumn::make('verification_status')->badge()->formatStateUsing(fn (mixed $state): string => Display::label($state))->color(fn (mixed $state): string => Display::statusColor($state)),
                TextColumn::make('vehicle_documents_count')->counts('vehicleDocuments')->label('Documents')->sortable(),
                TextColumn::make('created_at')->dateTime('M j, Y')->sortable(),
            ])
            ->filters([
                SelectFilter::make('vehicle_type')->options(Display::options(VehicleType::cases())),
                SelectFilter::make('vehicle_status')->options(Display::options(VehicleStatus::cases())),
                SelectFilter::make('verification_status')->options(Display::options(VerificationStatus::cases())),
            ])
            ->recordActions([
                ViewAction::make(),
                EditAction::make(),
                ActionGroup::make(ResourceActions::vehicleWorkflow())->label('Workflow'),
                DeleteAction::make(),
            ])
            ->defaultSort('created_at', 'desc')
            ->emptyStateHeading('No vehicles registered yet')
            ->emptyStateDescription('Vehicles from rider and pack-owner onboarding will appear here for verification.');
    }

    public static function getPages(): array
    {
        return [
            'index' => ListVehicles::route('/'),
            'create' => CreateVehicle::route('/create'),
            'view' => ViewVehicle::route('/{record}'),
            'edit' => EditVehicle::route('/{record}/edit'),
        ];
    }
}
