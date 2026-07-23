<?php

namespace App\Services;

use App\Models\User;
use App\Notifications\AccountCreatedNotification;
use App\Notifications\EmailVerificationCodeNotification;
use App\Notifications\PasswordResetCodeNotification;
use App\Notifications\PasswordResetSuccessfulNotification;
use Carbon\CarbonInterface;
use Illuminate\Notifications\Notification;
use Illuminate\Support\Facades\Log;
use Throwable;

class NotificationService
{
    public function sendAccountCreated(User $user, ?string $applicationStatus = null): void
    {
        $this->sendAfterResponse(
            $user,
            new AccountCreatedNotification($applicationStatus),
            'account_created'
        );
    }

    public function sendPasswordResetCode(User $user, string $code, CarbonInterface $expiresAt): void
    {
        $this->sendAfterResponse(
            $user,
            new PasswordResetCodeNotification($code, $expiresAt),
            'password_reset_code'
        );
    }

    public function sendPasswordResetSuccessful(User $user): void
    {
        $this->sendAfterResponse(
            $user,
            new PasswordResetSuccessfulNotification(),
            'password_reset_successful'
        );
    }

    public function sendEmailVerificationCode(User $user, string $code, CarbonInterface $expiresAt): void
    {
        $this->sendAfterResponse(
            $user,
            new EmailVerificationCodeNotification($code, $expiresAt),
            'email_verification_code'
        );
    }

    private function sendAfterResponse(User $user, Notification $notification, string $event): void
    {
        defer(function () use ($user, $notification, $event): void {
            try {
                $user->notify($notification);
            } catch (Throwable $exception) {
                Log::warning('Auth notification delivery failed.', [
                    'event' => $event,
                    'user_id' => $user->getKey(),
                    'exception' => $exception::class,
                    'message' => $exception->getMessage(),
                ]);
            }
        }, "josi.auth_notification.{$event}.{$user->getKey()}");
    }
}
