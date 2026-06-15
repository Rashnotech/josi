<?php

namespace App\Filament\Admin\Resources;

use App\Enums\UserRole;
use App\Filament\Admin\Resources\CourierResource\Pages\CreateCourier;
use App\Filament\Admin\Resources\CourierResource\Pages\EditCourier;
use App\Filament\Admin\Resources\CourierResource\Pages\ListCouriers;
use App\Filament\Admin\Resources\CourierResource\Pages\ViewCourier;
use App\Models\RiderProfile;
use App\Support\Filament\DriverProfileResource;
use BackedEnum;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Support\Icons\Heroicon;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;

class CourierResource extends Resource
{
    protected static ?string $model = RiderProfile::class;

    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedTruck;

    protected static string|\UnitEnum|null $navigationGroup = 'Applications';

    protected static ?int $navigationSort = 20;

    protected static ?string $recordTitleAttribute = 'first_name';

    public static function getEloquentQuery(): Builder
    {
        return DriverProfileResource::accountRoleScope(
            parent::getEloquentQuery()->with(['user', 'fleet']),
            [UserRole::Courier->value]
        );
    }

    public static function form(Schema $schema): Schema
    {
        return DriverProfileResource::form($schema, UserRole::Courier->value);
    }

    public static function table(Table $table): Table
    {
        return DriverProfileResource::table($table, 'courier');
    }

    public static function getPages(): array
    {
        return [
            'index' => ListCouriers::route('/'),
            'create' => CreateCourier::route('/create'),
            'view' => ViewCourier::route('/{record}'),
            'edit' => EditCourier::route('/{record}/edit'),
        ];
    }
}
