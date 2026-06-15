<?php

namespace App\Filament\Fleet\Resources;

use App\Enums\ApplicationStatus;
use App\Filament\Fleet\Resources\BusinessProfileResource\Pages\EditBusinessProfile;
use App\Filament\Fleet\Resources\BusinessProfileResource\Pages\ListBusinessProfiles;
use App\Models\Fleet;
use App\Support\Filament\DashboardAccess;
use App\Support\Filament\Display;
use BackedEnum;
use Filament\Actions\EditAction;
use Filament\Forms\Components\Textarea;
use Filament\Forms\Components\TextInput;
use Filament\Resources\Resource;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Schema;
use Filament\Support\Icons\Heroicon;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Support\Facades\Auth;

class BusinessProfileResource extends Resource
{
    protected static ?string $model = Fleet::class;

    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedBuildingOffice2;

    protected static string|\UnitEnum|null $navigationGroup = 'Business';

    protected static ?string $navigationLabel = 'Business Profile';

    protected static ?int $navigationSort = 10;

    public static function getEloquentQuery(): Builder
    {
        return parent::getEloquentQuery()
            ->whereKey(DashboardAccess::fleetIdFor(Auth::user()))
            ->withCount(['vehicles', 'riderProfiles', 'fleetDocuments']);
    }

    public static function form(Schema $schema): Schema
    {
        return $schema
            ->components([
                Section::make('Business Details')
                    ->columns(2)
                    ->schema([
                        TextInput::make('business_name')->required()->maxLength(255),
                        TextInput::make('business_email')->email()->maxLength(255),
                        TextInput::make('business_phone')->tel()->required()->maxLength(30),
                        TextInput::make('registration_number')->maxLength(255),
                        TextInput::make('vehicle_count')->numeric()->disabled(),
                        Textarea::make('business_address')->required()->columnSpanFull(),
                        TextInput::make('city')->required()->maxLength(120),
                        TextInput::make('state')->required()->maxLength(120),
                    ]),
                Section::make('Application Status')
                    ->columns(3)
                    ->schema([
                        TextInput::make('application_status')->formatStateUsing(fn (mixed $state): string => Display::label($state))->disabled(),
                        TextInput::make('approved_at')->disabled(),
                        TextInput::make('rejected_at')->disabled(),
                        Textarea::make('rejection_reason')->disabled()->columnSpanFull(),
                    ]),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('business_name')->weight('medium'),
                TextColumn::make('business_phone'),
                TextColumn::make('city'),
                TextColumn::make('state'),
                TextColumn::make('application_status')->badge()->formatStateUsing(fn (mixed $state): string => Display::label($state))->color(fn (mixed $state): string => Display::statusColor($state)),
                TextColumn::make('vehicles_count')->label('Vehicles'),
                TextColumn::make('rider_profiles_count')->label('Drivers'),
                TextColumn::make('fleet_documents_count')->label('Documents'),
            ])
            ->recordActions([
                EditAction::make()->label('Update profile'),
            ])
            ->emptyStateHeading('Business profile not found')
            ->emptyStateDescription('Sign in with the pack owner account that completed registration.');
    }

    public static function canCreate(): bool
    {
        return false;
    }

    public static function getPages(): array
    {
        return [
            'index' => ListBusinessProfiles::route('/'),
            'edit' => EditBusinessProfile::route('/{record}/edit'),
        ];
    }
}
