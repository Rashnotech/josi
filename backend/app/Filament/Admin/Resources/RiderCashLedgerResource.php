<?php

namespace App\Filament\Admin\Resources;

use App\Enums\RemittanceStatus;
use App\Filament\Admin\Resources\RiderCashLedgerResource\Pages\EditRiderCashLedger;
use App\Filament\Admin\Resources\RiderCashLedgerResource\Pages\ListRiderCashLedgers;
use App\Filament\Admin\Resources\RiderCashLedgerResource\Pages\ViewRiderCashLedger;
use App\Models\RiderCashLedger;
use App\Support\Filament\Display;
use App\Support\Filament\ResourceActions;
use BackedEnum;
use Filament\Actions\ActionGroup;
use Filament\Actions\EditAction;
use Filament\Actions\ViewAction;
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

class RiderCashLedgerResource extends Resource
{
    protected static ?string $model = RiderCashLedger::class;

    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedBanknotes;

    protected static string|\UnitEnum|null $navigationGroup = 'Payments';

    protected static ?string $navigationLabel = 'Cash Ledger';

    protected static ?int $navigationSort = 20;

    public static function getEloquentQuery(): Builder
    {
        return parent::getEloquentQuery()->with(['riderProfile.user', 'trip']);
    }

    public static function form(Schema $schema): Schema
    {
        return $schema
            ->components([
                Section::make('Cash Collection')
                    ->columns(3)
                    ->schema([
                        TextInput::make('amount_collected')->numeric()->prefix('NGN')->disabled(),
                        TextInput::make('rider_share')->numeric()->prefix('NGN')->disabled(),
                        TextInput::make('company_share')->numeric()->prefix('NGN')->disabled(),
                        TextInput::make('amount_to_remit')->numeric()->prefix('NGN')->disabled(),
                        TextInput::make('amount_remitted')->numeric()->prefix('NGN')->disabled(),
                        Select::make('remittance_status')->options(Display::options(RemittanceStatus::cases()))->required(),
                        Textarea::make('notes')->columnSpanFull(),
                    ]),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('riderProfile.first_name')->label('Rider')->formatStateUsing(fn (RiderCashLedger $record): string => trim(($record->riderProfile?->first_name ?? '').' '.($record->riderProfile?->last_name ?? '')) ?: 'Unassigned')->searchable(),
                TextColumn::make('trip_id')->label('Trip')->formatStateUsing(fn (mixed $state): string => '#'.$state)->sortable(),
                TextColumn::make('amount_collected')->formatStateUsing(fn (mixed $state): string => Display::money($state))->sortable(),
                TextColumn::make('company_share')->formatStateUsing(fn (mixed $state): string => Display::money($state))->sortable(),
                TextColumn::make('amount_to_remit')->formatStateUsing(fn (mixed $state): string => Display::money($state))->sortable(),
                TextColumn::make('amount_remitted')->formatStateUsing(fn (mixed $state): string => Display::money($state))->sortable(),
                TextColumn::make('remittance_status')->badge()->formatStateUsing(fn (mixed $state): string => Display::label($state))->color(fn (mixed $state): string => Display::statusColor($state)),
                TextColumn::make('remitted_at')->dateTime('M j, Y H:i')->placeholder('Pending')->sortable(),
                TextColumn::make('created_at')->dateTime('M j, Y')->sortable(),
            ])
            ->filters([
                SelectFilter::make('remittance_status')->options(Display::options(RemittanceStatus::cases())),
            ])
            ->recordActions([
                ViewAction::make(),
                EditAction::make(),
                ActionGroup::make(ResourceActions::cashLedgerWorkflow())->label('Remittance'),
            ])
            ->defaultSort('created_at', 'desc')
            ->emptyStateHeading('No cash ledger entries yet')
            ->emptyStateDescription('Completed cash trips create remittance entries for admin review.');
    }

    public static function getPages(): array
    {
        return [
            'index' => ListRiderCashLedgers::route('/'),
            'view' => ViewRiderCashLedger::route('/{record}'),
            'edit' => EditRiderCashLedger::route('/{record}/edit'),
        ];
    }
}
