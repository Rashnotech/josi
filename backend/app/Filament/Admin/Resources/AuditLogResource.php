<?php

namespace App\Filament\Admin\Resources;

use App\Filament\Admin\Resources\AuditLogResource\Pages\ListAuditLogs;
use App\Filament\Admin\Resources\AuditLogResource\Pages\ViewAuditLog;
use App\Models\AuditLog;
use BackedEnum;
use Filament\Actions\ViewAction;
use Filament\Forms\Components\KeyValue;
use Filament\Forms\Components\TextInput;
use Filament\Resources\Resource;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Schema;
use Filament\Support\Icons\Heroicon;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;

class AuditLogResource extends Resource
{
    protected static ?string $model = AuditLog::class;

    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedShieldExclamation;

    protected static string|\UnitEnum|null $navigationGroup = 'System';

    protected static ?string $navigationLabel = 'Audit Logs';

    protected static ?int $navigationSort = 10;

    public static function getEloquentQuery(): Builder
    {
        return parent::getEloquentQuery()->with('user');
    }

    public static function form(Schema $schema): Schema
    {
        return $schema
            ->components([
                Section::make('Audit Event')
                    ->columns(2)
                    ->schema([
                        TextInput::make('user.name')->label('Actor')->disabled(),
                        TextInput::make('action')->disabled(),
                        TextInput::make('auditable_type')->label('Model')->disabled(),
                        TextInput::make('auditable_id')->label('Record ID')->disabled(),
                        TextInput::make('ip_address')->disabled(),
                        TextInput::make('user_agent')->disabled(),
                        KeyValue::make('old_values')->disabled()->columnSpanFull(),
                        KeyValue::make('new_values')->disabled()->columnSpanFull(),
                    ]),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('created_at')->dateTime('M j, Y H:i:s')->sortable(),
                TextColumn::make('user.name')->label('Actor')->searchable()->placeholder('System'),
                TextColumn::make('action')->badge()->color('gray')->searchable(),
                TextColumn::make('auditable_type')->label('Model')->formatStateUsing(fn (?string $state): string => class_basename((string) $state))->searchable(),
                TextColumn::make('auditable_id')->label('Record')->sortable(),
                TextColumn::make('ip_address')->toggleable(isToggledHiddenByDefault: true),
            ])
            ->filters([
                SelectFilter::make('action')->options(fn (): array => AuditLog::query()->distinct()->orderBy('action')->pluck('action', 'action')->all()),
                SelectFilter::make('auditable_type')->label('Model')->options(fn (): array => AuditLog::query()->distinct()->orderBy('auditable_type')->pluck('auditable_type', 'auditable_type')->mapWithKeys(fn (string $value): array => [$value => class_basename($value)])->all()),
            ])
            ->recordActions([
                ViewAction::make(),
            ])
            ->defaultSort('created_at', 'desc')
            ->emptyStateHeading('No audit events yet')
            ->emptyStateDescription('Sensitive admin actions will appear here automatically.');
    }

    public static function canCreate(): bool
    {
        return false;
    }

    public static function canEdit($record): bool
    {
        return false;
    }

    public static function canDelete($record): bool
    {
        return false;
    }

    public static function getPages(): array
    {
        return [
            'index' => ListAuditLogs::route('/'),
            'view' => ViewAuditLog::route('/{record}'),
        ];
    }
}
