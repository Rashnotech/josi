<?php

namespace App\Filament\Admin\Resources;

use App\Enums\FleetDocumentType;
use App\Filament\Admin\Resources\FleetDocumentResource\Pages\CreateFleetDocument;
use App\Filament\Admin\Resources\FleetDocumentResource\Pages\EditFleetDocument;
use App\Filament\Admin\Resources\FleetDocumentResource\Pages\ListFleetDocuments;
use App\Filament\Admin\Resources\FleetDocumentResource\Pages\ViewFleetDocument;
use App\Models\FleetDocument;
use App\Support\Filament\DocumentResource;
use BackedEnum;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Support\Icons\Heroicon;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;

class FleetDocumentResource extends Resource
{
    protected static ?string $model = FleetDocument::class;

    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedDocumentText;

    protected static string|\UnitEnum|null $navigationGroup = 'KYC Documents';

    protected static ?string $navigationLabel = 'Fleet Documents';

    protected static ?int $navigationSort = 20;

    public static function getEloquentQuery(): Builder
    {
        return parent::getEloquentQuery()->with(['fleet.user', 'verifier']);
    }

    public static function form(Schema $schema): Schema
    {
        return DocumentResource::fleetForm($schema);
    }

    public static function table(Table $table): Table
    {
        return DocumentResource::table($table, 'fleet.business_name', 'Pack owner', FleetDocumentType::cases());
    }

    public static function getPages(): array
    {
        return [
            'index' => ListFleetDocuments::route('/'),
            'create' => CreateFleetDocument::route('/create'),
            'view' => ViewFleetDocument::route('/{record}'),
            'edit' => EditFleetDocument::route('/{record}/edit'),
        ];
    }
}
