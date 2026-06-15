<?php

namespace App\Policies;

use App\Enums\UserRole;
use App\Models\User;
use App\Policies\Concerns\ResolvesOwnership;
use App\Support\Filament\DashboardAccess;

class UserPolicy
{
    use ResolvesOwnership;

    public function viewAny(User $user): bool
    {
        return $this->isStaff($user);
    }

    public function view(User $user, User $model): bool
    {
        return $this->isStaff($user);
    }

    public function create(User $user): bool
    {
        return DashboardAccess::canManageAdmins($user);
    }

    public function update(User $user, User $model): bool
    {
        if (! $this->isStaff($user)) {
            return false;
        }

        if (DashboardAccess::roleValue($model) === UserRole::SuperAdmin->value && ! $this->isSuperAdmin($user)) {
            return false;
        }

        return true;
    }

    public function delete(User $user, User $model): bool
    {
        return $this->isSuperAdmin($user)
            && ! $model->is($user)
            && DashboardAccess::roleValue($model) !== UserRole::SuperAdmin->value;
    }
}
