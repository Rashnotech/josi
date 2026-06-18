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
        $message = 'Your Josi account password was changed successfully.';

        return (new MailMessage())
            ->subject('Your Josi password was changed')
            ->view('emails.password-reset-successful', [
                'name' => $notifiable->name,
                'message' => $message,
            ]);
    }
}
