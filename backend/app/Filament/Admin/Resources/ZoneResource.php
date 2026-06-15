<?php

namespace App\Filament\Admin\Resources;

use App\Filament\Admin\Resources\ZoneResource\Pages\CreateZone;
use App\Filament\Admin\Resources\ZoneResource\Pages\EditZone;
use App\Filament\Admin\Resources\ZoneResource\Pages\ListZones;
use App\Models\Zone;
use BackedEnum;
use Filament\Actions\DeleteAction;
use Filament\Actions\EditAction;
use Filament\Forms\Components\Textarea;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Toggle;
use Filament\Resources\Resource;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Schema;
use Filament\Support\Icons\Heroicon;
use Filament\Tables\Columns\IconColumn;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\TernaryFilter;
use Filament\Tables\Table;

class ZoneResource extends Resource
{
    protected static ?string $model = Zone::class;

    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedMapPin;

    protected static string|\UnitEnum|null $navigationGroup = 'Operations';

    protected static ?int $navigationSort = 30;

    protected static ?string $recordTitleAttribute = 'name';

    public static function form(Schema $schema): Schema
    {
        return $schema
            ->components([
                Section::make('Zone')
                    ->columns(2)
                    ->schema([
                        TextInput::make('name')->required()->maxLength(255),
                        TextInput::make('city')->required()->maxLength(120),
                        TextInput::make('state')->required()->maxLength(120),
                        TextInput::make('radius_km')->label('Radius')->numeric()->prefix('km')->required(),
                        TextInput::make('latitude')->numeric()->required(),
                        TextInput::make('longitude')->numeric()->required(),
                        Textarea::make('description')->columnSpanFull(),
                        Toggle::make('is_active')->label('Active')->default(true),
                    ]),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('name')->searchable()->sortable()->weight('medium'),
                TextColumn::make('city')->searchable()->sortable(),
                TextColumn::make('state')->searchable()->sortable(),
                TextColumn::make('radius_km')->label('Radius')->suffix(' km')->sortable(),
                IconColumn::make('is_active')->label('Active')->boolean(),
                TextColumn::make('updated_at')->dateTime('M j, Y H:i')->sortable(),
            ])
            ->filters([
                TernaryFilter::make('is_active')->label('Active status'),
            ])
            ->recordActions([
                EditAction::make(),
                DeleteAction::make(),
            ])
            ->defaultSort('name')
            ->emptyStateHeading('No zones configured')
            ->emptyStateDescription('Create pickup and destination zones before adding zone-to-zone pricing.');
    }

    public static function getPages(): array
    {
        return [
            'index' => ListZones::route('/'),
            'create' => CreateZone::route('/create'),
            'edit' => EditZone::route('/{record}/edit'),
        ];
    }
}
