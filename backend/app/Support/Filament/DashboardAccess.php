<?php

namespace App\Support\Filament;

use App\Enums\UserRole;
use App\Enums\UserStatus;
use App\Models\Fleet;
use App\Models\User;
use Illuminate\Database\Eloquent\Builder;

class DashboardAccess
{
    public const ADMIN_PANEL = 'admin';
    public const FLEET_PANEL = 'fleet';

    public static function roleValue(?User $user): ?string
    {
        if (! $user) {
            return null;
        }

        return $user->role instanceof UserRole ? $user->role->value : (string) $user->role;
    }

    public static function statusValue(?User $user): ?string
    {
        if (! $user) {
            return null;
        }

        return $user->status instanceof UserStatus ? $user->status->value : (string) $user->status;
    }

    public static function isActive(?User $user): bool
    {
        return self::statusValue($user) === UserStatus::Active->value;
    }

    public static function isSuperAdmin(?User $user): bool
    {
        return self::roleValue($user) === UserRole::SuperAdmin->value;
    }

    public static function isAdmin(?User $user): bool
    {
        return self::roleValue($user) === UserRole::Admin->value;
    }

    public static function isStaff(?User $user): bool
    {
        return self::isActive($user) && in_array(self::roleValue($user), [
            UserRole::SuperAdmin->value,
            UserRole::Admin->value,
        ], true);
    }

    public static function isFleetOwner(?User $user): bool
    {
        return self::isActive($user) && in_array(self::roleValue($user), [
            UserRole::PackOwner->value,
            UserRole::FleetOwner->value,
        ], true);
    }

    public static function canAccessPanel(User $user, string $panelId): bool
    {
        return match ($panelId) {
            self::ADMIN_PANEL => self::isStaff($user),
            self::FLEET_PANEL => self::isFleetOwner($user),
            default => false,
        };
    }

    public static function canManageAdmins(?User $user): bool
    {
        return self::isSuperAdmin($user);
    }

    public static function canManageSystemSettings(?User $user): bool
    {
        return self::isSuperAdmin($user);
    }

    public static function fleetFor(?User $user): ?Fleet
    {
        if (! self::isFleetOwner($user)) {
            return null;
        }

        return $user->fleet()->first();
    }

    public static function fleetIdFor(?User $user): ?int
    {
        return self::fleetFor($user)?->getKey();
    }

    public static function scopeToCurrentFleet(Builder $query, ?User $user, string $column = 'fleet_id'): Builder
    {
        $fleetId = self::fleetIdFor($user);

        return $fleetId
            ? $query->where($column, $fleetId)
            : $query->whereRaw('1 = 0');
    }
}
