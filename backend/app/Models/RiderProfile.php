<?php

namespace App\Models;

use App\Enums\ApplicationStatus;
use App\Enums\AvailabilityStatus;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class RiderProfile extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'fleet_id',
        'first_name',
        'last_name',
        'phone',
        'gender',
        'date_of_birth',
        'address',
        'city',
        'state',
        'profile_photo',
        'license_number',
        'application_status',
        'approved_at',
        'rejected_at',
        'rejection_reason',
        'availability_status',
        'current_latitude',
        'current_longitude',
        'last_location_updated_at',
    ];

    protected function casts(): array
    {
        return [
            'date_of_birth' => 'date',
            'approved_at' => 'datetime',
            'rejected_at' => 'datetime',
            'last_location_updated_at' => 'datetime',
            'current_latitude' => 'decimal:8',
            'current_longitude' => 'decimal:8',
            'application_status' => ApplicationStatus::class,
            'availability_status' => AvailabilityStatus::class,
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function fleet(): BelongsTo
    {
        return $this->belongsTo(Fleet::class);
    }

    public function vehicles(): HasMany
    {
        return $this->hasMany(Vehicle::class, 'driver_profile_id');
    }

    public function riderDocuments(): HasMany
    {
        return $this->hasMany(RiderDocument::class, 'driver_profile_id');
    }

    public function driverDocuments(): HasMany
    {
        return $this->riderDocuments();
    }

    public function trips(): HasMany
    {
        return $this->hasMany(Trip::class, 'driver_profile_id');
    }

    public function riderCashLedgers(): HasMany
    {
        return $this->hasMany(RiderCashLedger::class, 'driver_profile_id');
    }
}
