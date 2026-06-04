<?php

namespace Database\Factories;

use App\Enums\ApplicationStatus;
use App\Models\Fleet;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<Fleet>
 */
class FleetFactory extends Factory
{
    protected $model = Fleet::class;

    public function definition(): array
    {
        return [
            'user_id' => User::factory()->packOwner(),
            'business_name' => fake()->company(),
            'business_email' => fake()->companyEmail(),
            'business_phone' => fake()->unique()->phoneNumber(),
            'business_address' => fake()->streetAddress(),
            'city' => 'Lagos',
            'state' => 'Lagos',
            'registration_number' => strtoupper(fake()->bothify('BN-#######')),
            'application_status' => ApplicationStatus::Pending,
            'approved_at' => null,
            'rejected_at' => null,
            'rejection_reason' => null,
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
}
