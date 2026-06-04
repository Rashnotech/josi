<?php

namespace App\Models;

use App\Enums\RiderDocumentType;
use App\Enums\VerificationStatus;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class RiderDocument extends Model
{
    use HasFactory;

    protected $fillable = [
        'driver_profile_id',
        'document_type',
        'file_path',
        'original_file_name',
        'mime_type',
        'file_size',
        'verification_status',
        'verified_by',
        'verified_at',
        'rejection_reason',
    ];

    protected function casts(): array
    {
        return [
            'document_type' => RiderDocumentType::class,
            'verification_status' => VerificationStatus::class,
            'verified_at' => 'datetime',
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

    public function verifier(): BelongsTo
    {
        return $this->belongsTo(User::class, 'verified_by');
    }
}
