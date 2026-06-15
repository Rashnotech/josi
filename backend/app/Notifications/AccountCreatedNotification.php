<?php

namespace App\Notifications;

use App\Enums\UserRole;
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
        $role = $this->role($notifiable);
        $accountType = $role?->accountTypeLabel() ?? $this->roleValue($notifiable);
        $nextStep = match ($role) {
            UserRole::PackOwner, UserRole::FleetOwner => 'Your account has been created successfully. You can now access your dashboard.',
            UserRole::Rider, UserRole::Courier, UserRole::Driver => 'Your account has been created successfully. We will notify you when the next step is available.',
            default => 'Your account has been created successfully. Sign in to continue.',
        };

        $mail = (new MailMessage())
            ->subject('Your Josi account has been created')
            ->greeting("Hello {$notifiable->name},")
            ->line('Your Josi account was created successfully.')
            ->line('Account role: '.$accountType)
            ->line($nextStep);

        if ($this->applicationStatus) {
            $mail->line('Application status: '.$this->applicationStatus);
        }

        return $mail->line('If you did not create this account, contact Josi support immediately.');
    }

    private function role(User $user): ?UserRole
    {
        if ($user->role instanceof UserRole) {
            return $user->role;
        }

        return UserRole::tryFrom((string) $user->role);
    }

    private function roleValue(User $user): string
    {
        return $user->role instanceof \BackedEnum ? $user->role->value : (string) $user->role;
    }
}
