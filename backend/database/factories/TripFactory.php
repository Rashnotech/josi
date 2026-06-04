<?php

namespace Database\Factories;

use App\Enums\PaymentMethod;
use App\Enums\PaymentStatus;
use App\Enums\TripStatus;
use App\Models\RiderProfile;
use App\Models\Trip;
use App\Models\User;
use App\Models\Vehicle;
use App\Models\Zone;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<Trip>
 */
class TripFactory extends Factory
{
    protected $model = Trip::class;

    public function definition(): array
    {
        return [
            'customer_id' => User::factory()->customer(),
            'driver_profile_id' => null,
            'vehicle_id' => null,
            'pickup_zone_id' => Zone::factory(),
            'destination_zone_id' => Zone::factory(),
            'pickup_address' => fake()->streetAddress(),
            'pickup_latitude' => fake()->randomFloat(8, 6.40000000, 6.70000000),
            'pickup_longitude' => fake()->randomFloat(8, 3.20000000, 3.70000000),
            'destination_address' => fake()->streetAddress(),
            'destination_latitude' => fake()->randomFloat(8, 6.40000000, 6.70000000),
            'destination_longitude' => fake()->randomFloat(8, 3.20000000, 3.70000000),
            'amount' => fake()->randomFloat(2, 1500, 12000),
            'payment_method' => PaymentMethod::Cash,
            'payment_status' => PaymentStatus::Pending,
            'trip_status' => TripStatus::Requested,
            'requested_at' => now(),
            'accepted_at' => null,
            'started_at' => null,
            'completed_at' => null,
            'cancelled_at' => null,
            'cancellation_reason' => null,
        ];
    }

    public function assigned(): static
    {
        return $this->state(fn () => [
            'driver_profile_id' => RiderProfile::factory()->approved(),
            'vehicle_id' => Vehicle::factory()->activeVerified(),
            'trip_status' => TripStatus::Assigned,
        ]);
    }

    public function completedCash(): static
    {
        return $this->state(fn () => [
            'driver_profile_id' => RiderProfile::factory()->approved(),
            'vehicle_id' => Vehicle::factory()->activeVerified(),
            'payment_method' => PaymentMethod::Cash,
            'payment_status' => PaymentStatus::CashCollected,
            'trip_status' => TripStatus::Completed,
            'accepted_at' => now()->subMinutes(30),
            'started_at' => now()->subMinutes(25),
            'completed_at' => now(),
        ]);
    }
}
