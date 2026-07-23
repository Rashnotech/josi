<?php

namespace App\Models;

use App\Enums\UserRole;
use App\Enums\UserStatus;
use App\Support\Filament\DashboardAccess;
use Filament\Models\Contracts\FilamentUser;
use Filament\Panel;
use Illuminate\Auth\MustVerifyEmail as MustVerifyEmailNotifications;
use Illuminate\Contracts\Auth\MustVerifyEmail;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;
use Spatie\Permission\Traits\HasRoles;

class User extends Authenticatable implements FilamentUser, MustVerifyEmail
{
    use HasApiTokens;
    use HasFactory;
    use HasRoles;
    use MustVerifyEmailNotifications;
    use Notifiable;

    protected $fillable = [
        'name',
        'email',
        'phone',
        'gender',
        'password',
        'role',
        'status',
        'email_verified_at',
        'phone_verified_at',
        'last_login_at',
        'email_verification_code',
        'email_verification_code_expires_at',
        'email_verification_code_attempts',
        'email_verification_sent_at',
        'password_reset_code',
        'password_reset_code_expires_at',
        'password_reset_verified_at',
        'password_reset_token',
        'password_reset_code_attempts',
        'password_reset_sent_at',
    ];

    protected $hidden = [
        'password',
        'remember_token',
        'email_verification_code',
        'password_reset_code',
        'password_reset_token',
    ];

    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'phone_verified_at' => 'datetime',
            'last_login_at' => 'datetime',
            'password' => 'hashed',
            'role' => UserRole::class,
            'status' => UserStatus::class,
            'email_verification_code_expires_at' => 'datetime',
            'email_verification_sent_at' => 'datetime',
            'password_reset_code_expires_at' => 'datetime',
            'password_reset_verified_at' => 'datetime',
            'password_reset_sent_at' => 'datetime',
        ];
    }

    /**
     * The app sends its own OTP-based verification code (EmailVerificationService)
     * right after registration and via /auth/email/resend. Laravel's default
     * signed-link notification is unused, so this is a deliberate no-op rather
     * than the inherited MustVerifyEmail behavior.
     */
    public function sendEmailVerificationNotification(): void
    {
        //
    }

    public function riderProfile(): HasOne
    {
        return $this->hasOne(RiderProfile::class);
    }

    public function driverProfile(): HasOne
    {
        return $this->riderProfile();
    }

    public function fleet(): HasOne
    {
        return $this->hasOne(Fleet::class);
    }

    public function trips(): HasMany
    {
        return $this->hasMany(Trip::class, 'customer_id');
    }

    public function savedAddresses(): HasMany
    {
        return $this->hasMany(CustomerSavedAddress::class);
    }

    public function auditLogs(): HasMany
    {
        return $this->hasMany(AuditLog::class);
    }

    public function canAccessPanel(Panel $panel): bool
    {
        return DashboardAccess::canAccessPanel($this, $panel->getId());
    }
}
