<?php

namespace App\Policies\Concerns;

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
use App\Support\Filament\DashboardAccess;

trait ResolvesOwnership
{
    protected function isStaff(User $user): bool
    {
        return DashboardAccess::isStaff($user);
    }

    protected function isSuperAdmin(User $user): bool
    {
        return DashboardAccess::isSuperAdmin($user);
    }

    protected function isFleetOwner(User $user): bool
    {
        return DashboardAccess::isFleetOwner($user);
    }

    protected function fleetId(User $user): ?int
    {
        return DashboardAccess::fleetIdFor($user);
    }

    protected function ownsFleet(User $user, Fleet $fleet): bool
    {
        return $this->isFleetOwner($user) && $fleet->user_id === $user->getKey();
    }

    protected function ownsRiderProfile(User $user, RiderProfile $profile): bool
    {
        $fleetId = $this->fleetId($user);

        return $fleetId !== null && (int) $profile->fleet_id === $fleetId;
    }

    protected function ownsVehicle(User $user, Vehicle $vehicle): bool
    {
        $fleetId = $this->fleetId($user);

        return $fleetId !== null && (int) $vehicle->fleet_id === $fleetId;
    }

    protected function ownsFleetDocument(User $user, FleetDocument $document): bool
    {
        $fleetId = $this->fleetId($user);

        return $fleetId !== null && (int) $document->fleet_id === $fleetId;
    }

    protected function ownsRiderDocument(User $user, RiderDocument $document): bool
    {
        return $document->riderProfile && $this->ownsRiderProfile($user, $document->riderProfile);
    }

    protected function ownsVehicleDocument(User $user, VehicleDocument $document): bool
    {
        return $document->vehicle && $this->ownsVehicle($user, $document->vehicle);
    }

    protected function ownsTrip(User $user, Trip $trip): bool
    {
        return $trip->riderProfile && $this->ownsRiderProfile($user, $trip->riderProfile);
    }

    protected function ownsPayment(User $user, Payment $payment): bool
    {
        return $payment->trip && $this->ownsTrip($user, $payment->trip);
    }

    protected function ownsLedger(User $user, RiderCashLedger $ledger): bool
    {
        return $ledger->riderProfile && $this->ownsRiderProfile($user, $ledger->riderProfile);
    }
}
