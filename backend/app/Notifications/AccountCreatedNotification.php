<?php

namespace App\Notifications;

use App\Models\User;
use Illuminate\Bus\Queueable;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Notifications\Notification;

class AccountCreatedNotification extends Notification
{
    use Queueable;

    public function __construct(private readonly ?string $applicationStatus = null)
    {
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
            ->subject('Your Josi account has been created')
            ->greeting("Hello {$notifiable->name},")
            ->line('Your Josi account was created successfully.')
            ->line('Account role: '.$this->roleValue($notifiable));

        if ($this->applicationStatus) {
            $mail->line('Application status: '.$this->applicationStatus)
                ->line('Next step: upload the required KYC documents and wait for admin review.');
        } else {
            $mail->line('Next step: sign in and complete your profile.');
        }

        return $mail->line('If you did not create this account, contact Josi support immediately.');
    }

    private function roleValue(User $user): string
    {
        return $user->role instanceof \BackedEnum ? $user->role->value : (string) $user->role;
    }
}
