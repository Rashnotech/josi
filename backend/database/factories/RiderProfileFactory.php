<?php

namespace Database\Factories;

use App\Enums\ApplicationStatus;
use App\Enums\AvailabilityStatus;
use App\Models\RiderProfile;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<RiderProfile>
 */
class RiderProfileFactory extends Factory
{
    protected $model = RiderProfile::class;

    public function definition(): array
    {
        return [
            'user_id' => User::factory()->driver(),
            'fleet_id' => null,
            'first_name' => fake()->firstName(),
            'last_name' => fake()->lastName(),
            'phone' => fake()->unique()->phoneNumber(),
            'gender' => fake()->randomElement(['male', 'female']),
            'date_of_birth' => fake()->dateTimeBetween('-45 years', '-20 years')->format('Y-m-d'),
            'address' => fake()->streetAddress(),
            'city' => 'Lagos',
            'state' => 'Lagos',
            'profile_photo' => null,
            'license_number' => strtoupper(fake()->bothify('DL-########')),
            'application_status' => ApplicationStatus::Pending,
            'approved_at' => null,
            'rejected_at' => null,
            'rejection_reason' => null,
            'availability_status' => AvailabilityStatus::Offline,
            'current_latitude' => null,
            'current_longitude' => null,
            'last_location_updated_at' => null,
        ];
    }

    public function approved(): static
    {
        return $this->state(fn () => [
            'application_status' => ApplicationStatus::Approved,
            'approved_at' => now(),
            'rejected_at' => null,
            'rejection_reason' => null,
        ]);
    }

    public function online(): static
    {
        return $this->state(fn () => [
            'availability_status' => AvailabilityStatus::Online,
            'current_latitude' => 6.5244,
            'current_longitude' => 3.3792,
            'last_location_updated_at' => now(),
        ]);
    }
}
