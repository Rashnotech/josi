<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Zone extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'city',
        'state',
        'description',
        'latitude',
        'longitude',
        'radius_km',
        'is_active',
    ];

    protected function casts(): array
    {
        return [
            'latitude' => 'decimal:8',
            'longitude' => 'decimal:8',
            'radius_km' => 'decimal:2',
            'is_active' => 'boolean',
        ];
    }

    public function pickupZonePrices(): HasMany
    {
        return $this->hasMany(ZonePrice::class, 'pickup_zone_id');
    }

    public function destinationZonePrices(): HasMany
    {
        return $this->hasMany(ZonePrice::class, 'destination_zone_id');
    }
}
