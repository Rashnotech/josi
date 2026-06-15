<?php

namespace App\Policies;

use App\Models\Payment;
use App\Models\User;
use App\Policies\Concerns\ResolvesOwnership;

class PaymentPolicy
{
    use ResolvesOwnership;

    public function viewAny(User $user): bool
    {
        return $this->isStaff($user) || $this->isFleetOwner($user);
    }

    public function view(User $user, Payment $payment): bool
    {
        return $this->isStaff($user) || $this->ownsPayment($user, $payment);
    }

    public function create(User $user): bool
    {
        return $this->isStaff($user);
    }

    public function update(User $user, Payment $payment): bool
    {
        return $this->isStaff($user);
    }

    public function delete(User $user, Payment $payment): bool
    {
        return $this->isSuperAdmin($user);
    }
}
