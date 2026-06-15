<?php

namespace App\Policies;

use App\Models\RiderCashLedger;
use App\Models\User;
use App\Policies\Concerns\ResolvesOwnership;

class RiderCashLedgerPolicy
{
    use ResolvesOwnership;

    public function viewAny(User $user): bool
    {
        return $this->isStaff($user) || $this->isFleetOwner($user);
    }

    public function view(User $user, RiderCashLedger $ledger): bool
    {
        return $this->isStaff($user) || $this->ownsLedger($user, $ledger);
    }

    public function create(User $user): bool
    {
        return $this->isStaff($user);
    }

    public function update(User $user, RiderCashLedger $ledger): bool
    {
        return $this->isStaff($user);
    }

    public function delete(User $user, RiderCashLedger $ledger): bool
    {
        return $this->isSuperAdmin($user);
    }
}
