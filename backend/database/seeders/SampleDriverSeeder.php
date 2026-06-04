<?php

namespace Database\Seeders;

use App\Enums\ApplicationStatus;
use App\Enums\AvailabilityStatus;
use App\Enums\UserRole;
use App\Enums\UserStatus;
use App\Enums\VehicleStatus;
use App\Enums\VehicleType;
use App\Enums\VerificationStatus;
use App\Models\Fleet;
use App\Models\RiderProfile;
use App\Models\Role;
use App\Models\User;
use App\Models\Vehicle;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class SampleDriverSeeder extends Seeder
{
    public function run(): void
    {
        $fleet = Fleet::query()->first();

        $user = User::query()->updateOrCreate(
            ['email' => env('SAMPLE_DRIVER_EMAIL', 'driver@josi.local')],
            [
                'name' => env('SAMPLE_DRIVER_NAME', 'Ayo Driver'),
                'phone' => env('SAMPLE_DRIVER_PHONE', '08000000002'),
                'password' => Hash::make(env('JOSI_SAMPLE_PASSWORD', Str::random(32))),
                'role' => UserRole::Driver,
                'status' => UserStatus::Active,
                'email_verified_at' => now(),
            ]
        );

        $profile = RiderProfile::query()->updateOrCreate(
            ['user_id' => $user->getKey()],
            [
                'fleet_id' => $fleet?->getKey(),
                'first_name' => 'Ayo',
                'last_name' => 'Balogun',
                'phone' => $user->phone,
                'address' => '9 Toyin Street, Ikeja',
                'city' => 'Lagos',
                'state' => 'Lagos',
                'license_number' => 'DL-00998877',
                'application_status' => ApplicationStatus::Pending,
                'availability_status' => AvailabilityStatus::Offline,
            ]
        );

        Vehicle::query()->updateOrCreate(
            ['plate_number' => 'JOS-123AB'],
            [
                'fleet_id' => $fleet?->getKey(),
                'driver_profile_id' => $profile->getKey(),
                'vehicle_type' => VehicleType::Motorcycle,
                'brand' => 'Bajaj',
                'model' => 'Boxer',
                'color' => 'Black',
                'chassis_number' => 'CHS100200300',
                'engine_number' => 'ENG100200300',
                'vehicle_status' => VehicleStatus::Inactive,
                'verification_status' => VerificationStatus::Pending,
            ]
        );

        $role = Role::query()
            ->where('name', UserRole::Driver->value)
            ->where('guard_name', 'web')
            ->first();

        if ($role) {
            $user->roles()->sync([$role->getKey()]);
        }
    }
}
