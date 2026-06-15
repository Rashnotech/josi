<?php

namespace App\Filament\Admin\Resources;

use App\Enums\VehicleDocumentType;
use App\Filament\Admin\Resources\VehicleDocumentResource\Pages\CreateVehicleDocument;
use App\Filament\Admin\Resources\VehicleDocumentResource\Pages\EditVehicleDocument;
use App\Filament\Admin\Resources\VehicleDocumentResource\Pages\ListVehicleDocuments;
use App\Filament\Admin\Resources\VehicleDocumentResource\Pages\ViewVehicleDocument;
use App\Models\VehicleDocument;
use App\Support\Filament\DocumentResource;
use BackedEnum;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Support\Icons\Heroicon;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;

class VehicleDocumentResource extends Resource
{
    protected static ?string $model = VehicleDocument::class;

    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedDocumentCheck;

    protected static string|\UnitEnum|null $navigationGroup = 'Fleet & Vehicles';

    protected static ?string $navigationLabel = 'Vehicle Documents';

    protected static ?int $navigationSort = 20;

    public static function getEloquentQuery(): Builder
    {
        return parent::getEloquentQuery()->with(['vehicle.fleet', 'verifier']);
    }

    public static function form(Schema $schema): Schema
    {
        return DocumentResource::vehicleForm($schema);
    }

    public static function table(Table $table): Table
    {
        return DocumentResource::table($table, 'vehicle.plate_number', 'Vehicle', VehicleDocumentType::cases());
    }

    public static function getPages(): array
    {
        return [
            'index' => ListVehicleDocuments::route('/'),
            'create' => CreateVehicleDocument::route('/create'),
            'view' => ViewVehicleDocument::route('/{record}'),
            'edit' => EditVehicleDocument::route('/{record}/edit'),
        ];
    }
}
