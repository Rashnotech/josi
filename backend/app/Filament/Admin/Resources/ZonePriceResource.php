<?php

namespace App\Filament\Admin\Resources;

use App\Filament\Admin\Resources\ZonePriceResource\Pages\CreateZonePrice;
use App\Filament\Admin\Resources\ZonePriceResource\Pages\EditZonePrice;
use App\Filament\Admin\Resources\ZonePriceResource\Pages\ListZonePrices;
use App\Models\ZonePrice;
use App\Support\Filament\Display;
use BackedEnum;
use Filament\Actions\DeleteAction;
use Filament\Actions\EditAction;
use Filament\Forms\Components\Select;
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

class ZonePriceResource extends Resource
{
    protected static ?string $model = ZonePrice::class;

    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedReceiptPercent;

    protected static string|\UnitEnum|null $navigationGroup = 'Operations';

    protected static ?string $navigationLabel = 'Zone Pricing';

    protected static ?int $navigationSort = 20;

    public static function form(Schema $schema): Schema
    {
        return $schema
            ->components([
                Section::make('Route Pricing')
                    ->columns(2)
                    ->schema([
                        Select::make('pickup_zone_id')->relationship('pickupZone', 'name')->searchable()->preload()->required(),
                        Select::make('destination_zone_id')->relationship('destinationZone', 'name')->searchable()->preload()->required(),
                        TextInput::make('base_price')->numeric()->prefix('NGN')->required(),
                        Toggle::make('cash_allowed')->default(true),
                        Toggle::make('online_payment_allowed')->default(true),
                        Toggle::make('is_active')->default(true),
                    ]),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('pickupZone.name')->label('Pickup')->searchable()->sortable(),
                TextColumn::make('destinationZone.name')->label('Destination')->searchable()->sortable(),
                TextColumn::make('base_price')->label('Base price')->formatStateUsing(fn (mixed $state): string => Display::money($state))->sortable(),
                IconColumn::make('cash_allowed')->boolean(),
                IconColumn::make('online_payment_allowed')->boolean(),
                IconColumn::make('is_active')->label('Active')->boolean(),
                TextColumn::make('updated_at')->dateTime('M j, Y H:i')->sortable(),
            ])
            ->filters([
                TernaryFilter::make('is_active')->label('Active status'),
                TernaryFilter::make('cash_allowed'),
                TernaryFilter::make('online_payment_allowed'),
            ])
            ->recordActions([
                EditAction::make(),
                DeleteAction::make(),
            ])
            ->defaultSort('updated_at', 'desc')
            ->emptyStateHeading('No zone prices configured')
            ->emptyStateDescription('Add active route pricing before accepting priced trips.');
    }

    public static function getPages(): array
    {
        return [
            'index' => ListZonePrices::route('/'),
            'create' => CreateZonePrice::route('/create'),
            'edit' => EditZonePrice::route('/{record}/edit'),
        ];
    }

}
