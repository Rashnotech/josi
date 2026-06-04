<?php

namespace App\Services;

use App\Models\User;
use App\Notifications\AccountCreatedNotification;
use App\Notifications\PasswordResetCodeNotification;
use App\Notifications\PasswordResetSuccessfulNotification;
use Carbon\CarbonInterface;

class NotificationService
{
    public function sendAccountCreated(User $user, ?string $applicationStatus = null): void
    {
        $user->notify(new AccountCreatedNotification($applicationStatus));
    }

    public function sendPasswordResetCode(User $user, string $code, CarbonInterface $expiresAt): void
    {
        $user->notify(new PasswordResetCodeNotification($code, $expiresAt));
    }

    public function sendPasswordResetSuccessful(User $user): void
    {
        $user->notify(new PasswordResetSuccessfulNotification());
    }
}
