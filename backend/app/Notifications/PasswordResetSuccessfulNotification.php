<?php

namespace App\Notifications;

use App\Models\User;
use Illuminate\Bus\Queueable;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Notifications\Notification;

class PasswordResetSuccessfulNotification extends Notification
{
    use Queueable;

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
            ->subject('Your Josi password was changed')
            ->greeting("Hello {$notifiable->name},")
            ->line('Your Josi account password was changed successfully.')
            ->line('If you did not make this change, contact Josi support immediately.');
    }
}
