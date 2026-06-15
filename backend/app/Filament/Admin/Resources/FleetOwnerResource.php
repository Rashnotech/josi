<?php

namespace App\Filament\Admin\Resources;

use App\Enums\ApplicationStatus;
use App\Enums\UserRole;
use App\Filament\Admin\Resources\FleetOwnerResource\Pages\CreateFleetOwner;
use App\Filament\Admin\Resources\FleetOwnerResource\Pages\EditFleetOwner;
use App\Filament\Admin\Resources\FleetOwnerResource\Pages\ListFleetOwners;
use App\Filament\Admin\Resources\FleetOwnerResource\Pages\ViewFleetOwner;
use App\Models\Fleet;
use App\Support\Filament\Display;
use App\Support\Filament\ResourceActions;
use BackedEnum;
use Filament\Actions\ActionGroup;
use Filament\Actions\DeleteAction;
use Filament\Actions\EditAction;
use Filament\Actions\ViewAction;
use Filament\Forms\Components\DateTimePicker;
use Filament\Forms\Components\Select;
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

class FleetOwnerResource extends Resource
{
    protected static ?string $model = Fleet::class;

    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedBuildingOffice2;

    protected static string|\UnitEnum|null $navigationGroup = 'Applications';

    protected static ?string $navigationLabel = 'Pack Owners';

    protected static ?string $modelLabel = 'pack owner';

    protected static ?string $pluralModelLabel = 'pack owners';

    protected static ?int $navigationSort = 30;

    protected static ?string $recordTitleAttribute = 'business_name';

    public static function getEloquentQuery(): Builder
    {
        return parent::getEloquentQuery()
            ->with(['user'])
            ->withCount(['vehicles', 'riderProfiles', 'fleetDocuments'])
            ->whereHas('user', fn (Builder $query): Builder => $query->whereIn('role', [
                UserRole::PackOwner->value,
                UserRole::FleetOwner->value,
            ]));
    }

    public static function form(Schema $schema): Schema
    {
        return $schema
            ->components([
                Section::make('Business Profile')
                    ->description('Pack owner records represent the business account that owns vehicles and linked riders or couriers.')
                    ->columns(2)
                    ->schema([
                        Select::make('user_id')
                            ->label('Owner account')
                            ->relationship(
                                'user',
                                'name',
                                modifyQueryUsing: fn (Builder $query): Builder => $query->whereIn('role', [
                                    UserRole::PackOwner->value,
                                    UserRole::FleetOwner->value,
                                ])
                            )
                            ->searchable()
                            ->preload()
                            ->required(),
                        TextInput::make('business_name')->required()->maxLength(255),
                        TextInput::make('business_email')->email()->maxLength(255),
                        TextInput::make('business_phone')->tel()->required()->maxLength(30),
                        TextInput::make('registration_number')->maxLength(255),
                        TextInput::make('vehicle_count')->numeric()->minValue(1)->default(1),
                        Textarea::make('business_address')->required()->columnSpanFull(),
                        TextInput::make('city')->required()->maxLength(120),
                        TextInput::make('state')->required()->maxLength(120),
                    ]),
                Section::make('Application')
                    ->columns(3)
                    ->schema([
                        Select::make('application_status')
                            ->options(Display::options(ApplicationStatus::cases()))
                            ->required()
                            ->default(ApplicationStatus::Pending->value),
                        DateTimePicker::make('approved_at')->seconds(false),
                        DateTimePicker::make('rejected_at')->seconds(false),
                        Textarea::make('rejection_reason')->columnSpanFull(),
                    ]),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('business_name')->searchable()->sortable()->weight('medium'),
                TextColumn::make('user.email')->label('Owner email')->searchable()->toggleable(),
                TextColumn::make('business_phone')->searchable(),
                TextColumn::make('city')->searchable()->toggleable(),
                TextColumn::make('state')->searchable()->toggleable(),
                TextColumn::make('application_status')
                    ->badge()
                    ->formatStateUsing(fn (mixed $state): string => Display::label($state))
                    ->color(fn (mixed $state): string => Display::statusColor($state))
                    ->sortable(),
                TextColumn::make('vehicles_count')->counts('vehicles')->label('Vehicles')->sortable(),
                TextColumn::make('rider_profiles_count')->counts('riderProfiles')->label('Linked drivers')->sortable(),
                TextColumn::make('fleet_documents_count')->counts('fleetDocuments')->label('Documents')->sortable(),
                TextColumn::make('approved_at')->dateTime('M j, Y H:i')->placeholder('Not approved')->sortable()->toggleable(),
                TextColumn::make('created_at')->dateTime('M j, Y')->sortable(),
            ])
            ->filters([
                SelectFilter::make('application_status')->options(Display::options(ApplicationStatus::cases())),
                SelectFilter::make('city')
                    ->options(fn (): array => Fleet::query()->whereNotNull('city')->distinct()->orderBy('city')->pluck('city', 'city')->all()),
            ])
            ->recordActions([
                ViewAction::make(),
                EditAction::make(),
                ActionGroup::make(ResourceActions::fleetWorkflow())->label('Workflow'),
                DeleteAction::make(),
            ])
            ->defaultSort('created_at', 'desc')
            ->emptyStateHeading('No pack owner applications yet')
            ->emptyStateDescription('Fleet and pack owner registration records will appear here for operational review.');
    }

    public static function getPages(): array
    {
        return [
            'index' => ListFleetOwners::route('/'),
            'create' => CreateFleetOwner::route('/create'),
            'view' => ViewFleetOwner::route('/{record}'),
            'edit' => EditFleetOwner::route('/{record}/edit'),
        ];
    }
}
