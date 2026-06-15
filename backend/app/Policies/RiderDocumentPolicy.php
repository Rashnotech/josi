<?php

namespace App\Policies;

use App\Models\RiderDocument;
use App\Models\User;
use App\Policies\Concerns\ResolvesOwnership;

class RiderDocumentPolicy
{
    use ResolvesOwnership;

    public function viewAny(User $user): bool
    {
        return $this->isStaff($user) || $this->isFleetOwner($user);
    }

    public function view(User $user, RiderDocument $document): bool
    {
        return $this->isStaff($user) || $this->ownsRiderDocument($user, $document);
    }

    public function create(User $user): bool
    {
        return $this->isStaff($user);
    }

    public function update(User $user, RiderDocument $document): bool
    {
        return $this->isStaff($user);
    }

    public function delete(User $user, RiderDocument $document): bool
    {
        return $this->isSuperAdmin($user);
    }
}
