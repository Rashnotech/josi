<?php

namespace App\Models;

use App\Enums\RemittanceStatus;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class RiderCashLedger extends Model
{
    use HasFactory;

    protected $fillable = [
        'driver_profile_id',
        'trip_id',
        'amount_collected',
        'rider_share',
        'company_share',
        'amount_to_remit',
        'amount_remitted',
        'remittance_status',
        'remitted_at',
        'notes',
    ];

    protected function casts(): array
    {
        return [
            'amount_collected' => 'decimal:2',
            'rider_share' => 'decimal:2',
            'company_share' => 'decimal:2',
            'amount_to_remit' => 'decimal:2',
            'amount_remitted' => 'decimal:2',
            'remittance_status' => RemittanceStatus::class,
            'remitted_at' => 'datetime',
        ];
    }

    public function riderProfile(): BelongsTo
    {
        return $this->belongsTo(RiderProfile::class, 'driver_profile_id');
    }

    public function driverProfile(): BelongsTo
    {
        return $this->riderProfile();
    }

    public function trip(): BelongsTo
    {
        return $this->belongsTo(Trip::class);
    }
}
