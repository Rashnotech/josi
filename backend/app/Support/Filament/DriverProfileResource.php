<?php

namespace App\Support\Filament;

use App\Enums\ApplicationStatus;
use App\Enums\AvailabilityStatus;
use App\Models\Fleet;
use App\Models\User;
use Filament\Actions\ActionGroup;
use Filament\Actions\DeleteAction;
use Filament\Actions\EditAction;
use Filament\Actions\ViewAction;
use Filament\Forms\Components\DateTimePicker;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\Textarea;
use Filament\Forms\Components\TextInput;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Schema;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;

class DriverProfileResource
{
    public static function form(Schema $schema, string $role): Schema
    {
        return $schema
            ->components([
                Section::make(ucfirst($role).' Identity')
                    ->columns(2)
                    ->schema([
                        Select::make('user_id')
                            ->label('User account')
                            ->relationship(
                                'user',
                                'name',
                                modifyQueryUsing: fn (Builder $query): Builder => $query->where('role', $role)
                            )
                            ->searchable()
                            ->preload()
                            ->required(),
                        Select::make('fleet_id')
                            ->label('Pack owner')
                            ->options(fn (): array => Fleet::query()->orderBy('business_name')->pluck('business_name', 'id')->all())
                            ->searchable()
                            ->preload(),
                        TextInput::make('first_name')->required()->maxLength(255),
                        TextInput::make('last_name')->required()->maxLength(255),
                        TextInput::make('phone')->tel()->required()->maxLength(30),
                        TextInput::make('license_number')->label('License number')->maxLength(255),
                        Textarea::make('address')->required()->columnSpanFull(),
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
                        Select::make('availability_status')
                            ->options(Display::options(AvailabilityStatus::cases()))
                            ->required()
                            ->default(AvailabilityStatus::Offline->value),
                        Textarea::make('rejection_reason')->columnSpanFull(),
                        DateTimePicker::make('approved_at')->seconds(false),
                        DateTimePicker::make('rejected_at')->seconds(false),
                        DateTimePicker::make('last_location_updated_at')->seconds(false)->disabled(),
                    ]),
            ]);
    }

    public static function table(Table $table, string $roleLabel): Table
    {
        return $table
            ->columns([
                TextColumn::make('user.name')->label('Account')->searchable()->sortable()->weight('medium'),
                TextColumn::make('first_name')->searchable()->toggleable(),
                TextColumn::make('last_name')->searchable()->toggleable(),
                TextColumn::make('phone')->searchable(),
                TextColumn::make('fleet.business_name')->label('Pack owner')->searchable()->placeholder('Independent'),
                TextColumn::make('city')->searchable()->toggleable(),
                TextColumn::make('state')->searchable()->toggleable(),
                TextColumn::make('application_status')
                    ->badge()
                    ->formatStateUsing(fn (mixed $state): string => Display::label($state))
                    ->color(fn (mixed $state): string => Display::statusColor($state))
                    ->sortable(),
                TextColumn::make('availability_status')
                    ->badge()
                    ->formatStateUsing(fn (mixed $state): string => Display::label($state))
                    ->color(fn (mixed $state): string => Display::statusColor($state)),
                TextColumn::make('approved_at')->dateTime('M j, Y H:i')->sortable()->placeholder('Not approved')->toggleable(),
                TextColumn::make('created_at')->dateTime('M j, Y')->sortable(),
            ])
            ->filters([
                SelectFilter::make('application_status')->options(Display::options(ApplicationStatus::cases())),
                SelectFilter::make('availability_status')->options(Display::options(AvailabilityStatus::cases())),
                SelectFilter::make('fleet_id')
                    ->label('Pack owner')
                    ->relationship('fleet', 'business_name')
                    ->searchable()
                    ->preload(),
            ])
            ->recordActions([
                ViewAction::make(),
                EditAction::make(),
                ActionGroup::make(ResourceActions::driverWorkflow())->label('Workflow'),
                DeleteAction::make(),
            ])
            ->defaultSort('created_at', 'desc')
            ->emptyStateHeading("No {$roleLabel} applications yet")
            ->emptyStateDescription("New {$roleLabel} onboarding records will appear here for review.");
    }

    public static function accountRoleScope(Builder $query, array $roles): Builder
    {
        return $query->whereHas(
            'user',
            fn (Builder $userQuery): Builder => $userQuery->whereIn('role', $roles)
        );
    }
}
