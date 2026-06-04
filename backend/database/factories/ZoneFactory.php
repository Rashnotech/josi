<?php

namespace Database\Factories;

use App\Models\Zone;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<Zone>
 */
class ZoneFactory extends Factory
{
    protected $model = Zone::class;

    public function definition(): array
    {
        return [
            'name' => fake()->unique()->randomElement(['Ikeja', 'Lekki', 'Yaba', 'Surulere', 'Victoria Island', 'Ajah']),
            'city' => 'Lagos',
            'state' => 'Lagos',
            'description' => fake()->optional()->sentence(),
            'latitude' => fake()->randomFloat(8, 6.40000000, 6.70000000),
            'longitude' => fake()->randomFloat(8, 3.20000000, 3.70000000),
            'radius_km' => fake()->randomFloat(2, 2, 12),
            'is_active' => true,
        ];
    }
}
