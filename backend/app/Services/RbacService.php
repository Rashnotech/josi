<?php

namespace App\Services;

use App\Enums\UserRole;
use App\Models\Permission;
use App\Models\Role;
use App\Models\User;
use Illuminate\Support\Str;

class RbacService
{
    /**
     * @var array<string, array<int, string>>
     */
    public const ROLE_PERMISSIONS = [
        'super_admin' => [
            'manage_all_users',
            'manage_admins',
            'manage_drivers',
            'manage_fleets',
            'manage_vehicles',
            'manage_documents',
            'manage_pricing',
            'manage_trips',
            'manage_payments',
            'manage_cash_ledger',
            'view_reports',
            'manage_system_settings',
        ],
        'admin' => [
            'manage_drivers',
            'manage_fleets',
            'manage_vehicles',
            'manage_documents',
            'manage_pricing',
            'manage_trips',
            'manage_payments',
            'manage_cash_ledger',
            'view_reports',
        ],
        'fleet_owner' => [
            'view_own_fleet',
            'update_own_fleet',
            'manage_own_vehicles',
            'view_own_drivers',
            'upload_fleet_documents',
            'view_fleet_application_status',
        ],
        'driver' => [
            'view_profile',
            'update_profile',
            'upload_documents',
            'view_application_status',
            'view_assigned_trips',
            'update_location',
            'view_cash_ledger',
        ],
        'customer' => [
            'view_profile',
            'update_profile',
            'create_trip',
            'view_own_trips',
            'make_payment',
        ],
    ];

    public function permissionsForRole(UserRole|string $role): array
    {
        $roleValue = $role instanceof UserRole ? $role->value : $role;

        return self::ROLE_PERMISSIONS[$roleValue] ?? [];
    }

    public function permissionsForUser(User $user): array
    {
        return $this->permissionsForRole($this->roleValue($user));
    }

    public function userHasRole(User $user, string $role): bool
    {
        return $this->roleValue($user) === $role;
    }

    public function userHasAnyRole(User $user, array $roles): bool
    {
        return in_array($this->roleValue($user), $roles, true);
    }

    public function userHasPermission(User $user, string $permission): bool
    {
        return in_array($permission, $this->permissionsForUser($user), true);
    }

    public function syncUserRole(User $user): void
    {
        $role = Role::query()->where('name', $this->roleValue($user))->first();

        if ($role) {
            $user->roles()->sync([$role->getKey()]);
        }
    }

    public function ensureRolesAndPermissionsExist(): void
    {
        $permissions = collect(self::ROLE_PERMISSIONS)
            ->flatten()
            ->unique()
            ->mapWithKeys(function (string $permission) {
                return [
                    $permission => Permission::query()->updateOrCreate(
                        ['name' => $permission],
                        ['display_name' => $this->displayName($permission)]
                    ),
                ];
            });

        foreach (UserRole::cases() as $roleEnum) {
            $role = Role::query()->updateOrCreate(
                ['name' => $roleEnum->value],
                ['display_name' => $this->displayName($roleEnum->value)]
            );

            $role->permissions()->sync(
                collect($this->permissionsForRole($roleEnum))
                    ->map(fn (string $permission) => $permissions[$permission]->getKey())
                    ->all()
            );
        }
    }

    public function authPayload(User $user): array
    {
        $user->loadMissing(['riderProfile', 'fleet']);

        return [
            'user' => $this->userSummary($user),
            'role' => $this->roleValue($user),
            'permissions' => $this->permissionsForUser($user),
            'profile' => $this->profileSummary($user),
        ];
    }

    public function userSummary(User $user): array
    {
        return [
            'id' => $user->getKey(),
            'name' => $user->name,
            'email' => $user->email,
            'phone' => $user->phone,
            'role' => $this->roleValue($user),
            'status' => $this->enumValue($user->status),
            'last_login_at' => $user->last_login_at?->toISOString(),
        ];
    }

    public function profileSummary(User $user): array
    {
        return match ($this->roleValue($user)) {
            UserRole::Driver->value => $this->driverProfileSummary($user),
            UserRole::FleetOwner->value => $this->fleetSummary($user),
            UserRole::Admin->value,
            UserRole::SuperAdmin->value => [
                'type' => 'admin',
                'can_create_admins' => $this->userHasPermission($user, 'manage_admins'),
            ],
            default => [
                'type' => 'customer',
                'id' => $user->getKey(),
            ],
        };
    }

    public function roleValue(User $user): string
    {
        return $this->enumValue($user->role);
    }

    private function driverProfileSummary(User $user): ?array
    {
        $profile = $user->riderProfile;

        if (! $profile) {
            return null;
        }

        return [
            'id' => $profile->getKey(),
            'first_name' => $profile->first_name,
            'last_name' => $profile->last_name,
            'phone' => $profile->phone,
            'city' => $profile->city,
            'state' => $profile->state,
            'application_status' => $this->enumValue($profile->application_status),
            'availability_status' => $this->enumValue($profile->availability_status),
            'approved_at' => $profile->approved_at?->toISOString(),
            'rejected_at' => $profile->rejected_at?->toISOString(),
            'rejection_reason' => $profile->rejection_reason,
        ];
    }

    private function fleetSummary(User $user): ?array
    {
        $fleet = $user->fleet;

        if (! $fleet) {
            return null;
        }

        return [
            'id' => $fleet->getKey(),
            'business_name' => $fleet->business_name,
            'business_phone' => $fleet->business_phone,
            'business_email' => $fleet->business_email,
            'city' => $fleet->city,
            'state' => $fleet->state,
            'application_status' => $this->enumValue($fleet->application_status),
            'approved_at' => $fleet->approved_at?->toISOString(),
            'rejected_at' => $fleet->rejected_at?->toISOString(),
            'rejection_reason' => $fleet->rejection_reason,
        ];
    }

    private function enumValue(mixed $value): ?string
    {
        return $value instanceof \BackedEnum ? $value->value : $value;
    }

    private function displayName(string $value): string
    {
        return Str::headline(str_replace('_', ' ', $value));
    }
}
