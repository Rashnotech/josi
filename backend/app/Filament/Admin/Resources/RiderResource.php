<?php

namespace App\Filament\Admin\Resources;

use App\Enums\UserRole;
use App\Filament\Admin\Resources\RiderResource\Pages\CreateRider;
use App\Filament\Admin\Resources\RiderResource\Pages\EditRider;
use App\Filament\Admin\Resources\RiderResource\Pages\ListRiders;
use App\Filament\Admin\Resources\RiderResource\Pages\ViewRider;
use App\Models\RiderProfile;
use App\Support\Filament\DriverProfileResource;
use BackedEnum;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Support\Icons\Heroicon;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;

class RiderResource extends Resource
{
    protected static ?string $model = RiderProfile::class;

    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedUserGroup;

    protected static string|\UnitEnum|null $navigationGroup = 'Applications';

    protected static ?int $navigationSort = 10;

    protected static ?string $recordTitleAttribute = 'first_name';

    public static function getEloquentQuery(): Builder
    {
        return DriverProfileResource::accountRoleScope(
            parent::getEloquentQuery()->with(['user', 'fleet']),
            [UserRole::Rider->value, UserRole::Driver->value]
        );
    }

    public static function form(Schema $schema): Schema
    {
        return DriverProfileResource::form($schema, UserRole::Rider->value);
    }

    public static function table(Table $table): Table
    {
        return DriverProfileResource::table($table, 'rider');
    }

    public static function getPages(): array
    {
        return [
            'index' => ListRiders::route('/'),
            'create' => CreateRider::route('/create'),
            'view' => ViewRider::route('/{record}'),
            'edit' => EditRider::route('/{record}/edit'),
        ];
    }
}
