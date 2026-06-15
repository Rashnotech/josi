<?php

namespace App\Filament\Admin\Pages;

use App\Enums\PaymentStatus;
use App\Models\Payment;
use App\Models\RiderCashLedger;
use App\Support\Filament\Display;
use BackedEnum;
use Filament\Pages\Page;
use Filament\Schemas\Components\Grid;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Components\Text;
use Filament\Schemas\Schema;
use Filament\Support\Enums\FontWeight;
use Filament\Support\Enums\TextSize;
use Filament\Support\Icons\Heroicon;

class RevenueReport extends Page
{
    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedPresentationChartLine;

    protected static string|\UnitEnum|null $navigationGroup = 'Reports';

    protected static ?string $navigationLabel = 'Revenue Report';

    protected static ?int $navigationSort = 10;

    public function content(Schema $schema): Schema
    {
        return $schema->components([
            Grid::make(['default' => 1, 'md' => 2, 'xl' => 4])
                ->schema([
                    $this->metricSection('Paid revenue', $this->paidRevenue(), 'success'),
                    $this->metricSection('Cash collected', $this->cashCollected(), 'warning'),
                    $this->metricSection('Company share', Display::money(RiderCashLedger::query()->sum('company_share')), 'info'),
                    $this->metricSection('Remitted', Display::money(RiderCashLedger::query()->sum('amount_remitted')), 'success'),
                ]),
        ]);
    }

    private function metricSection(string $label, string $value, string $color): Section
    {
        return Section::make($label)
            ->schema([
                Text::make($value)
                    ->size(TextSize::Large)
                    ->weight(FontWeight::Bold)
                    ->color($color),
            ]);
    }

    private function paidRevenue(): string
    {
        return Display::money(Payment::query()->whereIn('payment_status', [
            PaymentStatus::Paid->value,
            PaymentStatus::CashCollected->value,
            PaymentStatus::Remitted->value,
        ])->sum('amount'));
    }

    private function cashCollected(): string
    {
        return Display::money(Payment::query()->where('payment_status', PaymentStatus::CashCollected->value)->sum('amount'));
    }
}
