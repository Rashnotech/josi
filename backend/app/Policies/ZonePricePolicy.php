<?php

namespace App\Policies;

use App\Models\User;
use App\Models\ZonePrice;
use App\Policies\Concerns\ResolvesOwnership;

class ZonePricePolicy
{
    use ResolvesOwnership;

    public function viewAny(User $user): bool
    {
        return $this->isStaff($user);
    }

    public function view(User $user, ZonePrice $zonePrice): bool
    {
        return $this->isStaff($user);
    }

    public function create(User $user): bool
    {
        return $this->isStaff($user);
    }

    public function update(User $user, ZonePrice $zonePrice): bool
    {
        return $this->isStaff($user);
    }

    public function delete(User $user, ZonePrice $zonePrice): bool
    {
        return $this->isSuperAdmin($user);
    }
}
