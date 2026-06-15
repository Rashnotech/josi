<?php

namespace App\Filament\Admin\Widgets;

use App\Enums\ApplicationStatus;
use App\Models\Fleet;
use App\Models\RiderProfile;
use App\Support\Filament\Display;
use Filament\Widgets\ChartWidget;

class ApplicationStatusChart extends ChartWidget
{
    protected ?string $heading = 'Application Status Breakdown';

    protected static ?int $sort = 10;

    protected function getData(): array
    {
        $labels = [];
        $values = [];

        foreach (ApplicationStatus::cases() as $status) {
            $labels[] = Display::label($status);
            $values[] = RiderProfile::query()->where('application_status', $status->value)->count()
                + Fleet::query()->where('application_status', $status->value)->count();
        }

        return [
            'datasets' => [
                [
                    'label' => 'Applications',
                    'data' => $values,
                    'backgroundColor' => ['#f59e0b', '#3b82f6', '#16a34a', '#dc2626', '#991b1b'],
                ],
            ],
            'labels' => $labels,
        ];
    }

    protected function getType(): string
    {
        return 'doughnut';
    }
}
