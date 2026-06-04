<?php

namespace Database\Seeders;

use App\Enums\UserRole;
use App\Enums\UserStatus;
use App\Models\Role;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;
use RuntimeException;

class SuperAdminSeeder extends Seeder
{
    public function run(): void
    {
        $password = env('SUPER_ADMIN_PASSWORD');

        if (! $password) {
            throw new RuntimeException('SUPER_ADMIN_PASSWORD must be set before running SuperAdminSeeder.');
        }

        $user = User::query()->updateOrCreate(
            ['email' => env('SUPER_ADMIN_EMAIL', 'admin@josi.local')],
            [
                'name' => env('SUPER_ADMIN_NAME', 'Josi Super Admin'),
                'phone' => env('SUPER_ADMIN_PHONE', '08000000000'),
                'password' => Hash::make($password),
                'role' => UserRole::SuperAdmin,
                'status' => UserStatus::Active,
                'email_verified_at' => now(),
            ]
        );

        $role = Role::query()
            ->where('name', UserRole::SuperAdmin->value)
            ->where('guard_name', 'web')
            ->first();

        if ($role) {
            $user->roles()->sync([$role->getKey()]);
        }
    }
}
