<?php

namespace App\Filament\Admin\Widgets;

use App\Enums\ApplicationStatus;
use App\Enums\PaymentStatus;
use App\Enums\TripStatus;
use App\Models\Fleet;
use App\Models\Payment;
use App\Models\RiderProfile;
use App\Models\Trip;
use App\Models\Vehicle;
use App\Support\Filament\Display;
use Filament\Widgets\Widget;

class AdminDashboardHero extends Widget
{
    protected string $view = 'filament.widgets.admin-dashboard-hero';

    protected int|string|array $columnSpan = 'full';

    protected static ?int $sort = -20;

    protected function getViewData(): array
    {
        $pendingApplications = RiderProfile::query()->where('application_status', ApplicationStatus::Pending->value)->count()
            + Fleet::query()->where('application_status', ApplicationStatus::Pending->value)->count();

        return [
            'pendingApplications' => number_format($pendingApplications),
            'activeVehicles' => number_format(Vehicle::query()->where('vehicle_status', 'active')->count()),
            'todayTrips' => number_format(Trip::query()->whereDate('created_at', today())->count()),
            'cashCollected' => Display::money(Payment::query()->where('payment_status', PaymentStatus::CashCollected->value)->sum('amount')),
            'completedTrips' => number_format(Trip::query()->where('trip_status', TripStatus::Completed->value)->count()),
        ];
    }
}
