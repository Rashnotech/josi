<?php

namespace App\Filament\Fleet\Resources;

use App\Enums\FleetDocumentType;
use App\Enums\VerificationStatus;
use App\Filament\Fleet\Resources\FleetDocumentResource\Pages\CreateFleetDocument;
use App\Filament\Fleet\Resources\FleetDocumentResource\Pages\EditFleetDocument;
use App\Filament\Fleet\Resources\FleetDocumentResource\Pages\ListFleetDocuments;
use App\Models\FleetDocument;
use App\Support\Filament\DashboardAccess;
use App\Support\Filament\Display;
use BackedEnum;
use Filament\Actions\EditAction;
use Filament\Forms\Components\FileUpload;
use Filament\Forms\Components\Hidden;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\Textarea;
use Filament\Resources\Resource;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Schema;
use Filament\Support\Icons\Heroicon;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Support\Facades\Auth;

class FleetDocumentResource extends Resource
{
    protected static ?string $model = FleetDocument::class;

    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedDocumentText;

    protected static string|\UnitEnum|null $navigationGroup = 'Business';

    protected static ?string $navigationLabel = 'Documents';

    protected static ?int $navigationSort = 20;

    public static function getEloquentQuery(): Builder
    {
        return DashboardAccess::scopeToCurrentFleet(parent::getEloquentQuery()->with('verifier'), Auth::user());
    }

    public static function form(Schema $schema): Schema
    {
        return $schema
            ->components([
                Hidden::make('fleet_id')->default(DashboardAccess::fleetIdFor(Auth::user())),
                Section::make('Fleet Document')
                    ->columns(2)
                    ->schema([
                        Select::make('document_type')->options(Display::options(FleetDocumentType::cases()))->required(),
                        FileUpload::make('file_path')
                            ->label('Document file')
                            ->disk('private')
                            ->directory('kyc/fleets')
                            ->visibility('private')
                            ->downloadable()
                            ->openable()
                            ->preserveFilenames()
                            ->required(),
                        Select::make('verification_status')->options(Display::options(VerificationStatus::cases()))->disabled()->default(VerificationStatus::Pending->value),
                        Textarea::make('rejection_reason')->disabled()->columnSpanFull(),
                    ]),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('document_type')->badge()->formatStateUsing(fn (mixed $state): string => Display::label($state))->color('gray')->sortable(),
                TextColumn::make('original_file_name')->label('File')->placeholder('Stored file'),
                TextColumn::make('verification_status')->badge()->formatStateUsing(fn (mixed $state): string => Display::label($state))->color(fn (mixed $state): string => Display::statusColor($state)),
                TextColumn::make('verifier.name')->label('Verified by')->placeholder('Pending'),
                TextColumn::make('verified_at')->dateTime('M j, Y H:i')->placeholder('Pending')->sortable(),
                TextColumn::make('created_at')->dateTime('M j, Y')->sortable(),
            ])
            ->filters([
                SelectFilter::make('document_type')->options(Display::options(FleetDocumentType::cases())),
                SelectFilter::make('verification_status')->options(Display::options(VerificationStatus::cases())),
            ])
            ->recordActions([
                EditAction::make(),
            ])
            ->defaultSort('created_at', 'desc')
            ->emptyStateHeading('No documents uploaded')
            ->emptyStateDescription('Upload business registration, tax, owner ID, and company profile documents here.');
    }

    public static function getPages(): array
    {
        return [
            'index' => ListFleetDocuments::route('/'),
            'create' => CreateFleetDocument::route('/create'),
            'edit' => EditFleetDocument::route('/{record}/edit'),
        ];
    }
}
