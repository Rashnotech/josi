<?php

namespace App\Models;

use App\Enums\UserRole;
use App\Enums\UserStatus;
use App\Support\Filament\DashboardAccess;
use Filament\Models\Contracts\FilamentUser;
use Filament\Panel;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;
use Spatie\Permission\Traits\HasRoles;

class User extends Authenticatable implements FilamentUser
{
    use HasApiTokens;
    use HasFactory;
    use HasRoles;
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
            'password_reset_code_expires_at' => 'datetime',
            'password_reset_verified_at' => 'datetime',
            'password_reset_sent_at' => 'datetime',
        ];
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
