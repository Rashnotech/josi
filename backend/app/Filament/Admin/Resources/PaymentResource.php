<?php

namespace App\Filament\Admin\Resources;

use App\Enums\PaymentMethod;
use App\Enums\PaymentStatus;
use App\Filament\Admin\Resources\PaymentResource\Pages\CreatePayment;
use App\Filament\Admin\Resources\PaymentResource\Pages\EditPayment;
use App\Filament\Admin\Resources\PaymentResource\Pages\ListPayments;
use App\Filament\Admin\Resources\PaymentResource\Pages\ViewPayment;
use App\Models\Payment;
use App\Models\Trip;
use App\Models\User;
use App\Support\Filament\DashboardAccess;
use App\Support\Filament\Display;
use App\Support\Filament\ResourceActions;
use BackedEnum;
use Filament\Actions\ActionGroup;
use Filament\Actions\DeleteAction;
use Filament\Actions\EditAction;
use Filament\Actions\ViewAction;
use Filament\Forms\Components\DateTimePicker;
use Filament\Forms\Components\KeyValue;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Resources\Resource;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Schema;
use Filament\Support\Icons\Heroicon;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Support\Facades\Auth;

class PaymentResource extends Resource
{
    protected static ?string $model = Payment::class;

    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedCreditCard;

    protected static string|\UnitEnum|null $navigationGroup = 'Payments';

    protected static ?int $navigationSort = 10;

    public static function getEloquentQuery(): Builder
    {
        return parent::getEloquentQuery()->with(['trip', 'user']);
    }

    public static function form(Schema $schema): Schema
    {
        return $schema
            ->components([
                Section::make('Payment')
                    ->columns(2)
                    ->schema([
                        Select::make('trip_id')->label('Trip')->options(fn (): array => Trip::query()->latest()->limit(250)->get()->mapWithKeys(fn (Trip $trip): array => [$trip->getKey() => '#'.$trip->getKey().' - '.Display::money($trip->amount)])->all())->searchable(),
                        Select::make('user_id')->label('Payer')->options(fn (): array => User::query()->orderBy('name')->pluck('name', 'id')->all())->searchable()->preload(),
                        TextInput::make('amount')->numeric()->prefix('NGN')->required(),
                        Select::make('payment_method')->options(Display::options(PaymentMethod::cases()))->required(),
                        Select::make('payment_status')->options(Display::options(PaymentStatus::cases()))->required(),
                        TextInput::make('payment_reference')->maxLength(255),
                        TextInput::make('gateway')->maxLength(100),
                        DateTimePicker::make('paid_at')->seconds(false),
                        DateTimePicker::make('failed_at')->seconds(false),
                        KeyValue::make('gateway_response')
                            ->label('Gateway response')
                            ->visible(fn (): bool => DashboardAccess::isSuperAdmin(Auth::user()))
                            ->columnSpanFull(),
                    ]),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('payment_reference')->label('Reference')->searchable()->placeholder('No reference')->copyable(),
                TextColumn::make('trip_id')->label('Trip')->formatStateUsing(fn (mixed $state): string => $state ? '#'.$state : 'No trip')->sortable(),
                TextColumn::make('user.name')->label('Payer')->searchable()->placeholder('Unknown'),
                TextColumn::make('amount')->formatStateUsing(fn (mixed $state): string => Display::money($state))->sortable(),
                TextColumn::make('payment_method')->badge()->formatStateUsing(fn (mixed $state): string => Display::label($state))->color('gray'),
                TextColumn::make('payment_status')->badge()->formatStateUsing(fn (mixed $state): string => Display::label($state))->color(fn (mixed $state): string => Display::statusColor($state)),
                TextColumn::make('gateway')->placeholder('Manual')->toggleable(),
                TextColumn::make('paid_at')->dateTime('M j, Y H:i')->placeholder('Not paid')->sortable(),
                TextColumn::make('created_at')->dateTime('M j, Y')->sortable(),
            ])
            ->filters([
                SelectFilter::make('payment_method')->options(Display::options(PaymentMethod::cases())),
                SelectFilter::make('payment_status')->options(Display::options(PaymentStatus::cases())),
            ])
            ->recordActions([
                ViewAction::make(),
                EditAction::make(),
                ActionGroup::make(ResourceActions::paymentWorkflow())->label('Workflow'),
                DeleteAction::make(),
            ])
            ->defaultSort('created_at', 'desc')
            ->emptyStateHeading('No payments recorded yet')
            ->emptyStateDescription('Online, wallet, transfer, and cash collection records will appear here.');
    }

    public static function getPages(): array
    {
        return [
            'index' => ListPayments::route('/'),
            'create' => CreatePayment::route('/create'),
            'view' => ViewPayment::route('/{record}'),
            'edit' => EditPayment::route('/{record}/edit'),
        ];
    }
}
