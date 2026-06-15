<?php

namespace App\Policies;

use App\Models\User;
use App\Models\Vehicle;
use App\Policies\Concerns\ResolvesOwnership;

class VehiclePolicy
{
    use ResolvesOwnership;

    public function viewAny(User $user): bool
    {
        return $this->isStaff($user) || $this->isFleetOwner($user);
    }

    public function view(User $user, Vehicle $vehicle): bool
    {
        return $this->isStaff($user) || $this->ownsVehicle($user, $vehicle);
    }

    public function create(User $user): bool
    {
        return $this->isStaff($user) || $this->isFleetOwner($user);
    }

    public function update(User $user, Vehicle $vehicle): bool
    {
        return $this->isStaff($user) || $this->ownsVehicle($user, $vehicle);
    }

    public function delete(User $user, Vehicle $vehicle): bool
    {
        return $this->isSuperAdmin($user);
    }
}
