<?php

namespace App\Models;

use App\Enums\VehicleStatus;
use App\Enums\VehicleType;
use App\Enums\VerificationStatus;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Vehicle extends Model
{
    use HasFactory;

    protected $fillable = [
        'fleet_id',
        'driver_profile_id',
        'vehicle_type',
        'brand',
        'model',
        'color',
        'plate_number',
        'chassis_number',
        'engine_number',
        'vehicle_status',
        'verification_status',
    ];

    protected function casts(): array
    {
        return [
            'vehicle_type' => VehicleType::class,
            'vehicle_status' => VehicleStatus::class,
            'verification_status' => VerificationStatus::class,
        ];
    }

    public function fleet(): BelongsTo
    {
        return $this->belongsTo(Fleet::class);
    }

    public function riderProfile(): BelongsTo
    {
        return $this->belongsTo(RiderProfile::class, 'driver_profile_id');
    }

    public function driverProfile(): BelongsTo
    {
        return $this->riderProfile();
    }

    public function vehicleDocuments(): HasMany
    {
        return $this->hasMany(VehicleDocument::class);
    }

    public function trips(): HasMany
    {
        return $this->hasMany(Trip::class);
    }
}
