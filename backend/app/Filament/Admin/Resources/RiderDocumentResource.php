<?php

namespace App\Filament\Admin\Resources;

use App\Enums\RiderDocumentType;
use App\Filament\Admin\Resources\RiderDocumentResource\Pages\CreateRiderDocument;
use App\Filament\Admin\Resources\RiderDocumentResource\Pages\EditRiderDocument;
use App\Filament\Admin\Resources\RiderDocumentResource\Pages\ListRiderDocuments;
use App\Filament\Admin\Resources\RiderDocumentResource\Pages\ViewRiderDocument;
use App\Models\RiderDocument;
use App\Support\Filament\DocumentResource;
use BackedEnum;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Support\Icons\Heroicon;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;

class RiderDocumentResource extends Resource
{
    protected static ?string $model = RiderDocument::class;

    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedIdentification;

    protected static string|\UnitEnum|null $navigationGroup = 'KYC Documents';

    protected static ?string $navigationLabel = 'Rider Documents';

    protected static ?int $navigationSort = 10;

    public static function getEloquentQuery(): Builder
    {
        return parent::getEloquentQuery()->with(['riderProfile.user', 'verifier']);
    }

    public static function form(Schema $schema): Schema
    {
        return DocumentResource::riderForm($schema);
    }

    public static function table(Table $table): Table
    {
        return DocumentResource::table($table, 'riderProfile.first_name', 'Owner', RiderDocumentType::cases());
    }

    public static function getPages(): array
    {
        return [
            'index' => ListRiderDocuments::route('/'),
            'create' => CreateRiderDocument::route('/create'),
            'view' => ViewRiderDocument::route('/{record}'),
            'edit' => EditRiderDocument::route('/{record}/edit'),
        ];
    }
}
