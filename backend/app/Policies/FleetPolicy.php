<?php

namespace App\Policies;

use App\Models\Fleet;
use App\Models\User;
use App\Policies\Concerns\ResolvesOwnership;

class FleetPolicy
{
    use ResolvesOwnership;

    public function viewAny(User $user): bool
    {
        return $this->isStaff($user) || $this->isFleetOwner($user);
    }

    public function view(User $user, Fleet $fleet): bool
    {
        return $this->isStaff($user) || $this->ownsFleet($user, $fleet);
    }

    public function create(User $user): bool
    {
        return $this->isStaff($user);
    }

    public function update(User $user, Fleet $fleet): bool
    {
        return $this->isStaff($user) || $this->ownsFleet($user, $fleet);
    }

    public function delete(User $user, Fleet $fleet): bool
    {
        return $this->isSuperAdmin($user);
    }
}
