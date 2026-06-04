<?php

namespace Database\Seeders;

use App\Enums\ApplicationStatus;
use App\Enums\UserRole;
use App\Enums\UserStatus;
use App\Models\Fleet;
use App\Models\Role;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class SampleFleetSeeder extends Seeder
{
    public function run(): void
    {
        $user = User::query()->updateOrCreate(
            ['email' => env('SAMPLE_FLEET_EMAIL', 'fleet.owner@josi.local')],
            [
                'name' => env('SAMPLE_FLEET_NAME', 'Mainland Fleet Owner'),
                'phone' => env('SAMPLE_FLEET_PHONE', '08000000001'),
                'password' => Hash::make(env('JOSI_SAMPLE_PASSWORD', Str::random(32))),
                'role' => UserRole::FleetOwner,
                'status' => UserStatus::Active,
                'email_verified_at' => now(),
            ]
        );

        Fleet::query()->updateOrCreate(
            ['user_id' => $user->getKey()],
            [
                'business_name' => 'Mainland Express Pack',
                'business_email' => 'operations@mainlandexpress.local',
                'business_phone' => '08000000011',
                'business_address' => '12 Allen Avenue, Ikeja',
                'city' => 'Lagos',
                'state' => 'Lagos',
                'registration_number' => 'BN-1002003',
                'application_status' => ApplicationStatus::Pending,
            ]
        );

        $role = Role::query()
            ->where('name', UserRole::FleetOwner->value)
            ->where('guard_name', 'web')
            ->first();

        if ($role) {
            $user->roles()->sync([$role->getKey()]);
        }
    }
}
