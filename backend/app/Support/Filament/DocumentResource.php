<?php

namespace App\Support\Filament;

use App\Enums\FleetDocumentType;
use App\Enums\RiderDocumentType;
use App\Enums\VehicleDocumentType;
use App\Enums\VerificationStatus;
use App\Models\Fleet;
use App\Models\RiderProfile;
use App\Models\Vehicle;
use Filament\Actions\ActionGroup;
use Filament\Actions\DeleteAction;
use Filament\Actions\EditAction;
use Filament\Actions\ViewAction;
use Filament\Forms\Components\FileUpload;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\Textarea;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Schema;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Table;

class DocumentResource
{
    public static function riderForm(Schema $schema): Schema
    {
        return self::form(
            $schema,
            ownerField: Select::make('driver_profile_id')
                ->label('Rider/courier')
                ->options(fn (): array => RiderProfile::query()->orderBy('first_name')->get()->mapWithKeys(fn (RiderProfile $profile): array => [
                    $profile->getKey() => trim("{$profile->first_name} {$profile->last_name}"),
                ])->all())
                ->searchable()
                ->preload()
                ->required(),
            typeCases: RiderDocumentType::cases(),
            directory: 'kyc/riders'
        );
    }

    public static function fleetForm(Schema $schema): Schema
    {
        return self::form(
            $schema,
            ownerField: Select::make('fleet_id')
                ->label('Pack owner')
                ->options(fn (): array => Fleet::query()->orderBy('business_name')->pluck('business_name', 'id')->all())
                ->searchable()
                ->preload()
                ->required(),
            typeCases: FleetDocumentType::cases(),
            directory: 'kyc/fleets'
        );
    }

    public static function vehicleForm(Schema $schema): Schema
    {
        return self::form(
            $schema,
            ownerField: Select::make('vehicle_id')
                ->label('Vehicle')
                ->options(fn (): array => Vehicle::query()->orderBy('plate_number')->pluck('plate_number', 'id')->all())
                ->searchable()
                ->preload()
                ->required(),
            typeCases: VehicleDocumentType::cases(),
            directory: 'kyc/vehicles'
        );
    }

    public static function table(Table $table, string $ownerColumn, string $ownerLabel, array $typeCases): Table
    {
        return $table
            ->columns([
                TextColumn::make($ownerColumn)->label($ownerLabel)->searchable()->sortable()->weight('medium'),
                TextColumn::make('document_type')->badge()->formatStateUsing(fn (mixed $state): string => Display::label($state))->color('gray')->sortable(),
                TextColumn::make('original_file_name')->label('File')->searchable()->placeholder('Stored file'),
                TextColumn::make('file_size')->label('Size')->formatStateUsing(fn (mixed $state): string => Display::fileSize($state))->toggleable(),
                TextColumn::make('verification_status')->badge()->formatStateUsing(fn (mixed $state): string => Display::label($state))->color(fn (mixed $state): string => Display::statusColor($state))->sortable(),
                TextColumn::make('verifier.name')->label('Verified by')->placeholder('Not verified')->toggleable(),
                TextColumn::make('verified_at')->dateTime('M j, Y H:i')->placeholder('Pending')->sortable(),
                TextColumn::make('created_at')->dateTime('M j, Y')->sortable(),
            ])
            ->filters([
                SelectFilter::make('document_type')->options(Display::options($typeCases)),
                SelectFilter::make('verification_status')->options(Display::options(VerificationStatus::cases())),
            ])
            ->recordActions([
                ViewAction::make(),
                EditAction::make(),
                ActionGroup::make(ResourceActions::documentWorkflow())->label('Workflow'),
                DeleteAction::make(),
            ])
            ->defaultSort('created_at', 'desc')
            ->emptyStateHeading('No documents uploaded yet')
            ->emptyStateDescription('Uploaded KYC and vehicle documents will appear here for verification.');
    }

    private static function form(Schema $schema, Select $ownerField, array $typeCases, string $directory): Schema
    {
        return $schema
            ->components([
                Section::make('Document')
                    ->columns(2)
                    ->schema([
                        $ownerField,
                        Select::make('document_type')->options(Display::options($typeCases))->required(),
                        FileUpload::make('file_path')
                            ->label('File')
                            ->disk('private')
                            ->directory($directory)
                            ->visibility('private')
                            ->downloadable()
                            ->openable()
                            ->preserveFilenames()
                            ->required(),
                        Select::make('verification_status')
                            ->options(Display::options(VerificationStatus::cases()))
                            ->required()
                            ->default(VerificationStatus::Pending->value),
                        Textarea::make('rejection_reason')->columnSpanFull(),
                    ]),
            ]);
    }
}
