<?php

namespace App\Notifications;

use App\Models\User;
use Illuminate\Bus\Queueable;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Notifications\Notification;

class ApplicationStatusChangedNotification extends Notification
{
    use Queueable;

    public function __construct(
        private readonly string $status,
        private readonly ?string $reason = null
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
        $mail = (new MailMessage())
            ->subject('Your Josi application status changed')
            ->greeting("Hello {$notifiable->name},")
            ->line('Your application status is now: '.$this->status);

        if ($this->reason) {
            $mail->line('Reason: '.$this->reason);
        }

        return $mail;
    }
}
