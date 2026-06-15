<?php

namespace App\Enums;

use App\Enums\Concerns\HasValues;

enum UserRole: string
{
    use HasValues;

    case SuperAdmin = 'super_admin';
    case Admin = 'admin';
    case PackOwner = 'pack_owner';
    case FleetOwner = 'fleet_owner';
    case Courier = 'courier';
    case Rider = 'rider';
    case Driver = 'driver';
    case Customer = 'customer';

    /**
     * @return array<int, string>
     */
    public static function publicRegistrationValues(): array
    {
        return [
            self::Rider->value,
            self::Courier->value,
            self::PackOwner->value,
        ];
    }

    public function dashboardRedirect(): string
    {
        return match ($this) {
            self::PackOwner, self::FleetOwner => '/dashboard',
            self::Rider, self::Driver => '/rider/application-status',
            self::Courier => '/courier/application-status',
            self::Customer => '/customer/home',
            self::Admin, self::SuperAdmin => '/admin',
        };
    }

    public function requiresDashboard(): bool
    {
        return in_array($this, [self::PackOwner, self::FleetOwner], true);
    }

    public function accountTypeLabel(): string
    {
        return match ($this) {
            self::PackOwner, self::FleetOwner => 'pack owner',
            self::Courier => 'courier',
            self::Rider, self::Driver => 'rider',
            self::Customer => 'customer',
            self::Admin => 'admin',
            self::SuperAdmin => 'super admin',
        };
    }
}
