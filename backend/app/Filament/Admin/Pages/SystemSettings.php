<?php

namespace App\Filament\Admin\Pages;

use App\Support\Filament\DashboardAccess;
use BackedEnum;
use Filament\Pages\Page;
use Filament\Schemas\Components\Grid;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Components\Text;
use Filament\Schemas\Schema;
use Filament\Support\Enums\FontWeight;
use Filament\Support\Icons\Heroicon;
use Illuminate\Support\Facades\Auth;

class SystemSettings extends Page
{
    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedCog6Tooth;

    protected static string|\UnitEnum|null $navigationGroup = 'System';

    protected static ?string $navigationLabel = 'Settings';

    protected static ?int $navigationSort = 20;

    public static function canAccess(): bool
    {
        return DashboardAccess::canManageSystemSettings(Auth::user());
    }

    public function content(Schema $schema): Schema
    {
        return $schema->components([
            Grid::make(['default' => 1, 'lg' => 3])
                ->schema([
                    $this->infoSection('Brand', 'Josi red, dark charcoal, and soft neutral surfaces.'),
                    $this->infoSection('Critical Access', 'Restricted to super admins.'),
                    $this->infoSection('Audit Coverage', 'Approvals, rejections, payments, remittance, and admin changes.'),
                ]),
        ]);
    }

    private function infoSection(string $heading, string $copy): Section
    {
        return Section::make($heading)
            ->schema([
                Text::make($copy)
                    ->weight(FontWeight::Medium)
                    ->color('gray'),
            ]);
    }
}
