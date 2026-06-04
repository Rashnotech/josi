<?php

namespace Database\Seeders;

use App\Models\Zone;
use Illuminate\Database\Seeder;

class ZoneSeeder extends Seeder
{
    public function run(): void
    {
        foreach ($this->zones() as $zone) {
            Zone::query()->updateOrCreate(
                ['name' => $zone['name'], 'city' => $zone['city'], 'state' => $zone['state']],
                $zone
            );
        }
    }

    private function zones(): array
    {
        return [
            [
                'name' => 'Ikeja',
                'city' => 'Lagos',
                'state' => 'Lagos',
                'description' => 'Mainland commercial and residential zone.',
                'latitude' => 6.6018,
                'longitude' => 3.3515,
                'radius_km' => 7.5,
                'is_active' => true,
            ],
            [
                'name' => 'Yaba',
                'city' => 'Lagos',
                'state' => 'Lagos',
                'description' => 'Technology and education corridor.',
                'latitude' => 6.5158,
                'longitude' => 3.3899,
                'radius_km' => 7.5,
                'is_active' => true,
            ],
            [
                'name' => 'Lekki',
                'city' => 'Lagos',
                'state' => 'Lagos',
                'description' => 'Island residential and business zone.',
                'latitude' => 6.4698,
                'longitude' => 3.5852,
                'radius_km' => 8.5,
                'is_active' => true,
            ],
        ];
    }
}
