<?php

namespace App\Filament\Admin\Pages;

use App\Enums\ApplicationStatus;
use App\Models\Fleet;
use App\Models\RiderProfile;
use App\Support\Filament\Display;
use BackedEnum;
use Filament\Pages\Page;
use Filament\Schemas\Components\Grid;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Components\Text;
use Filament\Schemas\Schema;
use Filament\Support\Enums\FontWeight;
use Filament\Support\Icons\Heroicon;

class ApplicationReport extends Page
{
    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedClipboardDocumentList;

    protected static string|\UnitEnum|null $navigationGroup = 'Reports';

    protected static ?string $navigationLabel = 'Application Report';

    protected static ?int $navigationSort = 20;

    public function content(Schema $schema): Schema
    {
        return $schema->components([
            Grid::make(['default' => 1, 'md' => 2, 'xl' => 5])
                ->schema(
                    collect(ApplicationStatus::cases())
                        ->map(fn (ApplicationStatus $status): Section => $this->statusSection($status))
                        ->all()
                ),
        ]);
    }

    private function statusSection(ApplicationStatus $status): Section
    {
        $riders = RiderProfile::query()->where('application_status', $status->value)->count();
        $fleets = Fleet::query()->where('application_status', $status->value)->count();

        return Section::make(Display::label($status))
            ->schema([
                Text::make('Riders: '.number_format($riders))
                    ->weight(FontWeight::SemiBold)
                    ->color(Display::statusColor($status)),
                Text::make('Pack owners: '.number_format($fleets))
                    ->weight(FontWeight::SemiBold)
                    ->color(Display::statusColor($status)),
            ]);
    }
}
