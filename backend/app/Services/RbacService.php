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
        'pack_owner' => [
            'view_own_fleet',
            'update_own_fleet',
            'manage_own_vehicles',
            'view_own_drivers',
            'upload_fleet_documents',
            'view_fleet_application_status',
        ],
        'fleet_owner' => [
            'view_own_fleet',
            'update_own_fleet',
            'manage_own_vehicles',
            'view_own_drivers',
            'upload_fleet_documents',
            'view_fleet_application_status',
        ],
        'courier' => [
            'view_profile',
            'update_profile',
            'upload_documents',
            'view_application_status',
            'view_assigned_trips',
            'update_location',
            'view_cash_ledger',
        ],
        'rider' => [
            'view_profile',
            'update_profile',
            'upload_documents',
            'view_application_status',
            'view_assigned_trips',
            'update_location',
            'view_cash_ledger',
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
                        ['name' => $permission, 'guard_name' => 'web'],
                        ['display_name' => $this->displayName($permission)]
                    ),
                ];
            });

        foreach (UserRole::cases() as $roleEnum) {
            $role = Role::query()->updateOrCreate(
                ['name' => $roleEnum->value, 'guard_name' => 'web'],
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
            'redirect_to' => $this->redirectPathForUser($user),
            'dashboard_url' => $this->dashboardUrlForUser($user),
            'requires_dashboard' => $this->requiresDashboard($user),
        ];
    }

    public function userSummary(User $user): array
    {
        return [
            'id' => $user->getKey(),
            'name' => $user->name,
            'email' => $user->email,
            'phone' => $user->phone,
            'gender' => $user->gender,
            'role' => $this->roleValue($user),
            'status' => $this->enumValue($user->status),
            'last_login_at' => $user->last_login_at?->toISOString(),
            'created_at' => $user->created_at?->toISOString(),
        ];
    }

    public function profileSummary(User $user): array
    {
        return match ($this->roleValue($user)) {
            UserRole::Rider->value,
            UserRole::Courier->value,
            UserRole::Driver->value => $this->driverProfileSummary($user),
            UserRole::PackOwner->value,
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

    public function redirectPathForUser(User $user): string
    {
        $role = $user->role instanceof UserRole
            ? $user->role
            : UserRole::tryFrom((string) $user->role);

        return $role?->dashboardRedirect() ?? '/';
    }

    public function requiresDashboard(User $user): bool
    {
        $role = $user->role instanceof UserRole
            ? $user->role
            : UserRole::tryFrom((string) $user->role);

        return $role?->requiresDashboard() ?? false;
    }

    public function dashboardUrlForUser(User $user): ?string
    {
        if (! $this->requiresDashboard($user)) {
            return null;
        }

        return url($this->redirectPathForUser($user));
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
            'gender' => $profile->gender,
            'date_of_birth' => $profile->date_of_birth?->toDateString(),
            'address' => $profile->address,
            'city' => $profile->city,
            'state' => $profile->state,
            'profile_photo' => $profile->profile_photo,
            'bank_name' => $profile->bank_name,
            'bank_account_name' => $profile->bank_account_name,
            'bank_account_number' => $profile->bank_account_number,
            'license_number' => $profile->license_number,
            'application_status' => $this->enumValue($profile->application_status),
            'availability_status' => $this->enumValue($profile->availability_status),
            'approved_at' => $profile->approved_at?->toISOString(),
            'rejected_at' => $profile->rejected_at?->toISOString(),
            'rejection_reason' => $profile->rejection_reason,
            'onboarding_submitted_at' => $profile->onboarding_submitted_at?->toISOString(),
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
            'vehicle_count' => $fleet->vehicle_count,
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
