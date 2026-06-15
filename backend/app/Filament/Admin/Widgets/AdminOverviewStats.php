<?php

namespace App\Filament\Admin\Widgets;

use App\Enums\ApplicationStatus;
use App\Enums\PaymentStatus;
use App\Enums\RemittanceStatus;
use App\Enums\TripStatus;
use App\Enums\UserRole;
use App\Enums\VerificationStatus;
use App\Models\Fleet;
use App\Models\FleetDocument;
use App\Models\Payment;
use App\Models\RiderCashLedger;
use App\Models\RiderDocument;
use App\Models\RiderProfile;
use App\Models\Trip;
use App\Models\User;
use App\Models\Vehicle;
use App\Models\VehicleDocument;
use App\Support\Filament\Display;
use Filament\Widgets\StatsOverviewWidget;
use Filament\Widgets\StatsOverviewWidget\Stat;

class AdminOverviewStats extends StatsOverviewWidget
{
    protected static ?int $sort = -10;

    protected function getStats(): array
    {
        $pendingDocuments = RiderDocument::query()->where('verification_status', VerificationStatus::Pending->value)->count()
            + FleetDocument::query()->where('verification_status', VerificationStatus::Pending->value)->count()
            + VehicleDocument::query()->where('verification_status', VerificationStatus::Pending->value)->count();

        return [
            Stat::make('Total users', number_format(User::query()->count()))->icon('heroicon-o-users')->color('gray'),
            Stat::make('Total riders', number_format(User::query()->whereIn('role', [UserRole::Rider->value, UserRole::Driver->value])->count()))->icon('heroicon-o-user-group')->color('info'),
            Stat::make('Total couriers', number_format(User::query()->where('role', UserRole::Courier->value)->count()))->icon('heroicon-o-truck')->color('info'),
            Stat::make('Pack owners', number_format(Fleet::query()->count()))->icon('heroicon-o-building-office-2')->color('gray'),
            Stat::make('Pending applications', number_format(RiderProfile::query()->where('application_status', ApplicationStatus::Pending->value)->count() + Fleet::query()->where('application_status', ApplicationStatus::Pending->value)->count()))->color('warning')->icon('heroicon-o-clock'),
            Stat::make('Approved applications', number_format(RiderProfile::query()->where('application_status', ApplicationStatus::Approved->value)->count() + Fleet::query()->where('application_status', ApplicationStatus::Approved->value)->count()))->color('success')->icon('heroicon-o-check-circle'),
            Stat::make('Rejected applications', number_format(RiderProfile::query()->where('application_status', ApplicationStatus::Rejected->value)->count() + Fleet::query()->where('application_status', ApplicationStatus::Rejected->value)->count()))->color('danger')->icon('heroicon-o-x-circle'),
            Stat::make('Total vehicles', number_format(Vehicle::query()->count()))->icon('heroicon-o-truck')->color('gray'),
            Stat::make('Pending documents', number_format($pendingDocuments))->color('warning')->icon('heroicon-o-document-magnifying-glass'),
            Stat::make('Total trips', number_format(Trip::query()->count()))->icon('heroicon-o-map')->color('gray'),
            Stat::make('Completed trips', number_format(Trip::query()->where('trip_status', TripStatus::Completed->value)->count()))->color('success')->icon('heroicon-o-check-badge'),
            Stat::make('Cancelled trips', number_format(Trip::query()->where('trip_status', TripStatus::Cancelled->value)->count()))->color('danger')->icon('heroicon-o-no-symbol'),
            Stat::make('Total revenue', Display::money(Payment::query()->whereIn('payment_status', [PaymentStatus::Paid->value, PaymentStatus::CashCollected->value, PaymentStatus::Remitted->value])->sum('amount')))->icon('heroicon-o-credit-card')->color('success'),
            Stat::make('Cash collected', Display::money(Payment::query()->where('payment_status', PaymentStatus::CashCollected->value)->sum('amount')))->icon('heroicon-o-banknotes')->color('warning'),
            Stat::make('Pending remittance', Display::money(RiderCashLedger::query()->whereIn('remittance_status', [RemittanceStatus::Pending->value, RemittanceStatus::PartiallyRemitted->value])->sum('amount_to_remit')))->icon('heroicon-o-wallet')->color('danger'),
        ];
    }
}
