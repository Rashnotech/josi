<?php

namespace App\Filament\Fleet\Resources;

use App\Enums\ApplicationStatus;
use App\Enums\AvailabilityStatus;
use App\Filament\Fleet\Resources\FleetDriverResource\Pages\ListFleetDrivers;
use App\Filament\Fleet\Resources\FleetDriverResource\Pages\ViewFleetDriver;
use App\Models\RiderProfile;
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

class FleetDriverResource extends Resource
{
    protected static ?string $model = RiderProfile::class;

    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedUsers;

    protected static string|\UnitEnum|null $navigationGroup = 'Fleet';

    protected static ?string $navigationLabel = 'Riders / Couriers';

    protected static ?int $navigationSort = 20;

    public static function getEloquentQuery(): Builder
    {
        return DashboardAccess::scopeToCurrentFleet(parent::getEloquentQuery()->with('user'), Auth::user());
    }

    public static function form(Schema $schema): Schema
    {
        return $schema
            ->components([
                Section::make('Driver Profile')
                    ->columns(2)
                    ->schema([
                        TextInput::make('first_name')->disabled(),
                        TextInput::make('last_name')->disabled(),
                        TextInput::make('phone')->disabled(),
                        TextInput::make('city')->disabled(),
                        TextInput::make('state')->disabled(),
                        TextInput::make('application_status')->formatStateUsing(fn (mixed $state): string => Display::label($state))->disabled(),
                        TextInput::make('availability_status')->formatStateUsing(fn (mixed $state): string => Display::label($state))->disabled(),
                    ]),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('user.name')->label('Account')->searchable()->sortable()->weight('medium'),
                TextColumn::make('first_name')->searchable(),
                TextColumn::make('last_name')->searchable(),
                TextColumn::make('phone')->searchable(),
                TextColumn::make('application_status')->badge()->formatStateUsing(fn (mixed $state): string => Display::label($state))->color(fn (mixed $state): string => Display::statusColor($state)),
                TextColumn::make('availability_status')->badge()->formatStateUsing(fn (mixed $state): string => Display::label($state))->color(fn (mixed $state): string => Display::statusColor($state)),
                TextColumn::make('created_at')->dateTime('M j, Y')->sortable(),
            ])
            ->filters([
                SelectFilter::make('application_status')->options(Display::options(ApplicationStatus::cases())),
                SelectFilter::make('availability_status')->options(Display::options(AvailabilityStatus::cases())),
            ])
            ->recordActions([
                ViewAction::make(),
            ])
            ->defaultSort('created_at', 'desc')
            ->emptyStateHeading('No linked riders or couriers')
            ->emptyStateDescription('Josi admins can link riders and couriers to your business as onboarding progresses.');
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
            'index' => ListFleetDrivers::route('/'),
            'view' => ViewFleetDriver::route('/{record}'),
        ];
    }
}
