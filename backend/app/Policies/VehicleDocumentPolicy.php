<?php

namespace App\Policies;

use App\Models\User;
use App\Models\VehicleDocument;
use App\Policies\Concerns\ResolvesOwnership;

class VehicleDocumentPolicy
{
    use ResolvesOwnership;

    public function viewAny(User $user): bool
    {
        return $this->isStaff($user) || $this->isFleetOwner($user);
    }

    public function view(User $user, VehicleDocument $document): bool
    {
        return $this->isStaff($user) || $this->ownsVehicleDocument($user, $document);
    }

    public function create(User $user): bool
    {
        return $this->isStaff($user) || $this->isFleetOwner($user);
    }

    public function update(User $user, VehicleDocument $document): bool
    {
        return $this->isStaff($user) || $this->ownsVehicleDocument($user, $document);
    }

    public function delete(User $user, VehicleDocument $document): bool
    {
        return $this->isSuperAdmin($user);
    }
}
