<?php

namespace App\Policies;

use App\Models\User;
use App\Policies\Concerns\ResolvesOwnership;

class RolePolicy
{
    use ResolvesOwnership;

    public function viewAny(User $user): bool
    {
        return $this->isSuperAdmin($user);
    }

    public function view(User $user, mixed $role = null): bool
    {
        return $this->isSuperAdmin($user);
    }

    public function create(User $user): bool
    {
        return $this->isSuperAdmin($user);
    }

    public function update(User $user, mixed $role = null): bool
    {
        return $this->isSuperAdmin($user);
    }

    public function delete(User $user, mixed $role = null): bool
    {
        return $this->isSuperAdmin($user);
    }
}
