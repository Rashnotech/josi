<?php

namespace App\Services;

use App\Enums\ApplicationStatus;
use App\Models\Fleet;
use App\Models\User;
use Illuminate\Support\Facades\DB;

class FleetApprovalService
{
    public function __construct(private readonly AuditLogService $auditLogService)
    {
    }

    public function approve(Fleet $fleet, User $actor): Fleet
    {
        return DB::transaction(function () use ($fleet, $actor) {
            $oldValues = $fleet->only([
                'application_status',
                'approved_at',
                'rejected_at',
                'rejection_reason',
            ]);

            $fleet->forceFill([
                'application_status' => ApplicationStatus::Approved,
                'approved_at' => now(),
                'rejected_at' => null,
                'rejection_reason' => null,
            ])->save();

            $this->auditLogService->log(
                'fleet.approved',
                $actor,
                $fleet,
                $oldValues,
                $fleet->only(array_keys($oldValues))
            );

            return $fleet->refresh();
        });
    }

    public function reject(Fleet $fleet, User $actor, string $reason): Fleet
    {
        return DB::transaction(function () use ($fleet, $actor, $reason) {
            $oldValues = $fleet->only([
                'application_status',
                'approved_at',
                'rejected_at',
                'rejection_reason',
            ]);

            $fleet->forceFill([
                'application_status' => ApplicationStatus::Rejected,
                'approved_at' => null,
                'rejected_at' => now(),
                'rejection_reason' => $reason,
            ])->save();

            $this->auditLogService->log(
                'fleet.rejected',
                $actor,
                $fleet,
                $oldValues,
                $fleet->only(array_keys($oldValues))
            );

            return $fleet->refresh();
        });
    }
}
