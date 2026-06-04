<?php

namespace App\Services;

use App\Enums\VerificationStatus;
use App\Models\FleetDocument;
use App\Models\RiderDocument;
use App\Models\User;
use App\Models\VehicleDocument;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\DB;
use InvalidArgumentException;

class DocumentVerificationService
{
    public function __construct(private readonly AuditLogService $auditLogService)
    {
    }

    public function verify(
        RiderDocument|FleetDocument|VehicleDocument $document,
        User $actor
    ): RiderDocument|FleetDocument|VehicleDocument {
        return DB::transaction(function () use ($document, $actor) {
            $oldValues = $document->only([
                'verification_status',
                'verified_by',
                'verified_at',
                'rejection_reason',
            ]);

            $document->forceFill([
                'verification_status' => VerificationStatus::Verified,
                'verified_by' => $actor->getKey(),
                'verified_at' => now(),
                'rejection_reason' => null,
            ])->save();

            $this->auditLogService->log(
                'document.verified',
                $actor,
                $document,
                $oldValues,
                $document->only(array_keys($oldValues))
            );

            return $document->refresh();
        });
    }

    public function reject(
        RiderDocument|FleetDocument|VehicleDocument $document,
        User $actor,
        string $reason
    ): RiderDocument|FleetDocument|VehicleDocument {
        return DB::transaction(function () use ($document, $actor, $reason) {
            $oldValues = $document->only([
                'verification_status',
                'verified_by',
                'verified_at',
                'rejection_reason',
            ]);

            $document->forceFill([
                'verification_status' => VerificationStatus::Rejected,
                'verified_by' => $actor->getKey(),
                'verified_at' => now(),
                'rejection_reason' => $reason,
            ])->save();

            $this->auditLogService->log(
                'document.rejected',
                $actor,
                $document,
                $oldValues,
                $document->only(array_keys($oldValues))
            );

            return $document->refresh();
        });
    }

    public function assertSupportedDocument(Model $document): void
    {
        if (! $document instanceof RiderDocument
            && ! $document instanceof FleetDocument
            && ! $document instanceof VehicleDocument
        ) {
            throw new InvalidArgumentException('Document verification supports rider, fleet, and vehicle documents only.');
        }
    }
}
