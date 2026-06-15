<?php

namespace App\Policies;

use App\Models\RiderProfile;
use App\Models\User;
use App\Policies\Concerns\ResolvesOwnership;

class RiderProfilePolicy
{
    use ResolvesOwnership;

    public function viewAny(User $user): bool
    {
        return $this->isStaff($user) || $this->isFleetOwner($user);
    }

    public function view(User $user, RiderProfile $profile): bool
    {
        return $this->isStaff($user) || $this->ownsRiderProfile($user, $profile);
    }

    public function create(User $user): bool
    {
        return $this->isStaff($user);
    }

    public function update(User $user, RiderProfile $profile): bool
    {
        return $this->isStaff($user);
    }

    public function delete(User $user, RiderProfile $profile): bool
    {
        return $this->isSuperAdmin($user);
    }
}
