<?php

namespace App\Notifications;

use App\Models\User;
use Carbon\CarbonInterface;
use Illuminate\Bus\Queueable;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Notifications\Notification;

class PasswordResetCodeNotification extends Notification
{
    use Queueable;

    public function __construct(
        private readonly string $code,
        private readonly CarbonInterface $expiresAt
    ) {
    }

    /**
     * @return array<int, string>
     */
    public function via(User $notifiable): array
    {
        return ['mail'];
    }

    public function toMail(User $notifiable): MailMessage
    {
        return (new MailMessage())
            ->subject('Your Josi password reset code')
            ->greeting("Hello {$notifiable->name},")
            ->line('Use this 6-digit code to reset your password:')
            ->line($this->code)
            ->line('This code expires in 10 minutes.')
            ->line('Expiry time: '.$this->expiresAt->toDateTimeString())
            ->line('If you did not request this code, ignore this email and keep your account secure.');
    }
}
