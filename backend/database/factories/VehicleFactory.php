<?php

namespace Database\Factories;

use App\Enums\VehicleStatus;
use App\Enums\VehicleType;
use App\Enums\VerificationStatus;
use App\Models\RiderProfile;
use App\Models\Vehicle;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<Vehicle>
 */
class VehicleFactory extends Factory
{
    protected $model = Vehicle::class;

    public function definition(): array
    {
        return [
            'fleet_id' => null,
            'driver_profile_id' => RiderProfile::factory(),
            'vehicle_type' => VehicleType::Motorcycle,
            'brand' => fake()->randomElement(['Honda', 'Bajaj', 'Suzuki', 'TVS']),
            'model' => fake()->randomElement(['CG 125', 'Boxer', 'GN 125', 'Apache']),
            'color' => fake()->safeColorName(),
            'plate_number' => strtoupper(fake()->unique()->bothify('JOS-###??')),
            'chassis_number' => strtoupper(fake()->unique()->bothify('CHS##########')),
            'engine_number' => strtoupper(fake()->unique()->bothify('ENG##########')),
            'vehicle_status' => VehicleStatus::Inactive,
            'verification_status' => VerificationStatus::Pending,
        ];
    }

    public function activeVerified(): static
    {
        return $this->state(fn () => [
            'vehicle_status' => VehicleStatus::Active,
            'verification_status' => VerificationStatus::Verified,
        ]);
    }
}
