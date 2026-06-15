<?php

namespace App\Filament\Admin\Resources;

use App\Enums\UserRole;
use App\Enums\UserStatus;
use App\Filament\Admin\Resources\UserResource\Pages\CreateUser;
use App\Filament\Admin\Resources\UserResource\Pages\EditUser;
use App\Filament\Admin\Resources\UserResource\Pages\ListUsers;
use App\Filament\Admin\Resources\UserResource\Pages\ViewUser;
use App\Models\User;
use App\Support\Filament\DashboardAccess;
use App\Support\Filament\Display;
use BackedEnum;
use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteAction;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\EditAction;
use Filament\Actions\ViewAction;
use Filament\Forms\Components\DateTimePicker;
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
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\Rules\Password;

class UserResource extends Resource
{
    protected static ?string $model = User::class;

    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedUsers;

    protected static string|\UnitEnum|null $navigationGroup = 'User Management';

    protected static ?int $navigationSort = 10;

    protected static ?string $recordTitleAttribute = 'name';

    public static function getEloquentQuery(): Builder
    {
        return parent::getEloquentQuery()->with('roles');
    }

    public static function form(Schema $schema): Schema
    {
        return $schema
            ->components([
                Section::make('Account')
                    ->description('Create staff accounts carefully. Public registration cannot create admin roles.')
                    ->columns(2)
                    ->schema([
                        TextInput::make('name')->required()->maxLength(255),
                        TextInput::make('email')->email()->required()->maxLength(255)->unique(ignoreRecord: true),
                        TextInput::make('phone')->tel()->required()->maxLength(30)->unique(ignoreRecord: true),
                        Select::make('role')
                            ->required()
                            ->options(fn (): array => self::roleOptions())
                            ->disabled(fn (?User $record): bool => $record?->role === UserRole::SuperAdmin && ! DashboardAccess::isSuperAdmin(Auth::user())),
                        Select::make('status')
                            ->required()
                            ->options(Display::options(UserStatus::cases()))
                            ->default(UserStatus::Active->value),
                    ]),
                Section::make('Security')
                    ->columns(2)
                    ->schema([
                        TextInput::make('password')
                            ->password()
                            ->revealable()
                            ->rule(Password::default())
                            ->required(fn (string $operation): bool => $operation === 'create')
                            ->dehydrated(fn (?string $state): bool => filled($state))
                            ->dehydrateStateUsing(fn (string $state): string => Hash::make($state)),
                        TextInput::make('password_confirmation')
                            ->password()
                            ->revealable()
                            ->same('password')
                            ->dehydrated(false),
                    ]),
                Section::make('Verification and Activity')
                    ->columns(3)
                    ->schema([
                        DateTimePicker::make('email_verified_at')->seconds(false),
                        DateTimePicker::make('phone_verified_at')->seconds(false),
                        DateTimePicker::make('last_login_at')->seconds(false)->disabled(),
                    ]),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('name')->searchable()->sortable()->weight('medium'),
                TextColumn::make('email')->searchable()->sortable()->copyable(),
                TextColumn::make('phone')->searchable()->toggleable(),
                TextColumn::make('role')
                    ->badge()
                    ->formatStateUsing(fn (mixed $state): string => Display::label($state))
                    ->color(fn (mixed $state): string => $state === UserRole::SuperAdmin ? 'danger' : 'gray')
                    ->sortable(),
                TextColumn::make('status')
                    ->badge()
                    ->formatStateUsing(fn (mixed $state): string => Display::label($state))
                    ->color(fn (mixed $state): string => Display::statusColor($state))
                    ->sortable(),
                TextColumn::make('email_verified_at')->label('Email verified')->dateTime('M j, Y H:i')->sortable()->toggleable(),
                TextColumn::make('phone_verified_at')->label('Phone verified')->dateTime('M j, Y H:i')->sortable()->toggleable(isToggledHiddenByDefault: true),
                TextColumn::make('last_login_at')->dateTime('M j, Y H:i')->sortable()->placeholder('Never'),
                TextColumn::make('created_at')->dateTime('M j, Y')->sortable()->toggleable(),
            ])
            ->filters([
                SelectFilter::make('role')->options(Display::options(UserRole::cases())),
                SelectFilter::make('status')->options(Display::options(UserStatus::cases())),
            ])
            ->recordActions([
                ViewAction::make(),
                EditAction::make(),
                DeleteAction::make(),
            ])
            ->toolbarActions([
                BulkActionGroup::make([
                    DeleteBulkAction::make(),
                ]),
            ])
            ->defaultSort('created_at', 'desc')
            ->emptyStateHeading('No users match this view')
            ->emptyStateDescription('Users will appear here as customers, riders, couriers, pack owners, and staff join Josi.');
    }

    public static function getPages(): array
    {
        return [
            'index' => ListUsers::route('/'),
            'create' => CreateUser::route('/create'),
            'view' => ViewUser::route('/{record}'),
            'edit' => EditUser::route('/{record}/edit'),
        ];
    }

    private static function roleOptions(): array
    {
        $roles = collect(UserRole::cases());

        if (! DashboardAccess::isSuperAdmin(Auth::user())) {
            $roles = $roles->reject(fn (UserRole $role): bool => $role === UserRole::SuperAdmin);
        }

        return Display::options($roles->all());
    }
}
