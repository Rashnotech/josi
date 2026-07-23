<?php

namespace App\Notifications;

use App\Models\User;
use Carbon\CarbonInterface;
use Illuminate\Bus\Queueable;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Notifications\Notification;

class EmailVerificationCodeNotification extends Notification
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
            ->subject('Verify your Josi email address')
            ->view('emails.email-verification-code', [
                'name' => $notifiable->name,
                'code' => $this->code,
                'expiryNotice' => 'This code expires in 15 minutes.',
                'expiresAt' => $this->expiresAt->toDateTimeString(),
            ]);
    }
}
