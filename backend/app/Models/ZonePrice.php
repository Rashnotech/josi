<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ZonePrice extends Model
{
    use HasFactory;

    protected $fillable = [
        'pickup_zone_id',
        'destination_zone_id',
        'base_price',
        'cash_allowed',
        'online_payment_allowed',
        'is_active',
    ];

    protected function casts(): array
    {
        return [
            'base_price' => 'decimal:2',
            'cash_allowed' => 'boolean',
            'online_payment_allowed' => 'boolean',
            'is_active' => 'boolean',
        ];
    }

    public function pickupZone(): BelongsTo
    {
        return $this->belongsTo(Zone::class, 'pickup_zone_id');
    }

    public function destinationZone(): BelongsTo
    {
        return $this->belongsTo(Zone::class, 'destination_zone_id');
    }
}
