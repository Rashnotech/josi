<?php

namespace Database\Factories;

use App\Models\Zone;
use App\Models\ZonePrice;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<ZonePrice>
 */
class ZonePriceFactory extends Factory
{
    protected $model = ZonePrice::class;

    public function definition(): array
    {
        return [
            'pickup_zone_id' => Zone::factory(),
            'destination_zone_id' => Zone::factory(),
            'base_price' => fake()->randomFloat(2, 1500, 12000),
            'cash_allowed' => true,
            'online_payment_allowed' => true,
            'is_active' => true,
        ];
    }
}
