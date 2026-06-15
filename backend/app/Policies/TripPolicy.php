<?php

namespace App\Policies;

use App\Models\Trip;
use App\Models\User;
use App\Policies\Concerns\ResolvesOwnership;

class TripPolicy
{
    use ResolvesOwnership;

    public function viewAny(User $user): bool
    {
        return $this->isStaff($user) || $this->isFleetOwner($user);
    }

    public function view(User $user, Trip $trip): bool
    {
        return $this->isStaff($user) || $this->ownsTrip($user, $trip);
    }

    public function create(User $user): bool
    {
        return $this->isStaff($user);
    }

    public function update(User $user, Trip $trip): bool
    {
        return $this->isStaff($user);
    }

    public function delete(User $user, Trip $trip): bool
    {
        return $this->isSuperAdmin($user);
    }
}
