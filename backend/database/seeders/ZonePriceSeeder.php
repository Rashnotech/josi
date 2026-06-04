<?php

namespace Database\Seeders;

use App\Models\Zone;
use App\Models\ZonePrice;
use Illuminate\Database\Seeder;

class ZonePriceSeeder extends Seeder
{
    public function run(): void
    {
        foreach ($this->prices() as $price) {
            $pickupZone = Zone::query()->where('name', $price['pickup'])->firstOrFail();
            $destinationZone = Zone::query()->where('name', $price['destination'])->firstOrFail();

            ZonePrice::query()->updateOrCreate(
                [
                    'pickup_zone_id' => $pickupZone->getKey(),
                    'destination_zone_id' => $destinationZone->getKey(),
                ],
                [
                    'base_price' => $price['base_price'],
                    'cash_allowed' => true,
                    'online_payment_allowed' => true,
                    'is_active' => true,
                ]
            );
        }
    }

    private function prices(): array
    {
        return [
            ['pickup' => 'Ikeja', 'destination' => 'Ikeja', 'base_price' => 1800],
            ['pickup' => 'Ikeja', 'destination' => 'Yaba', 'base_price' => 3500],
            ['pickup' => 'Yaba', 'destination' => 'Lekki', 'base_price' => 5200],
            ['pickup' => 'Lekki', 'destination' => 'Ikeja', 'base_price' => 6500],
        ];
    }
}
