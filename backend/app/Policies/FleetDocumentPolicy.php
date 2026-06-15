<?php

namespace App\Policies;

use App\Models\FleetDocument;
use App\Models\User;
use App\Policies\Concerns\ResolvesOwnership;

class FleetDocumentPolicy
{
    use ResolvesOwnership;

    public function viewAny(User $user): bool
    {
        return $this->isStaff($user) || $this->isFleetOwner($user);
    }

    public function view(User $user, FleetDocument $document): bool
    {
        return $this->isStaff($user) || $this->ownsFleetDocument($user, $document);
    }

    public function create(User $user): bool
    {
        return $this->isStaff($user) || $this->isFleetOwner($user);
    }

    public function update(User $user, FleetDocument $document): bool
    {
        return $this->isStaff($user) || $this->ownsFleetDocument($user, $document);
    }

    public function delete(User $user, FleetDocument $document): bool
    {
        return $this->isSuperAdmin($user);
    }
}
