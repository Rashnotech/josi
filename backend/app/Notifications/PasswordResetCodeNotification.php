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
            ->view('emails.password-reset-code', [
                'name' => $notifiable->name,
                'code' => $this->code,
                'expiryNotice' => 'This code expires in 10 minutes.',
                'expiresAt' => $this->expiresAt->toDateTimeString(),
            ]);
    }
}
