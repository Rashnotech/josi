<?php

namespace App\Policies;

use App\Models\User;
use App\Models\Zone;
use App\Policies\Concerns\ResolvesOwnership;

class ZonePolicy
{
    use ResolvesOwnership;

    public function viewAny(User $user): bool
    {
        return $this->isStaff($user);
    }

    public function view(User $user, Zone $zone): bool
    {
        return $this->isStaff($user);
    }

    public function create(User $user): bool
    {
        return $this->isStaff($user);
    }

    public function update(User $user, Zone $zone): bool
    {
        return $this->isStaff($user);
    }

    public function delete(User $user, Zone $zone): bool
    {
        return $this->isSuperAdmin($user);
    }
}
