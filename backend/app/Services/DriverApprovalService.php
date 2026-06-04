<?php

namespace App\Services;

use App\Enums\ApplicationStatus;
use App\Enums\AvailabilityStatus;
use App\Models\RiderProfile;
use App\Models\User;
use Illuminate\Support\Facades\DB;

class DriverApprovalService
{
    public function __construct(private readonly AuditLogService $auditLogService)
    {
    }

    public function approve(RiderProfile $riderProfile, User $actor): RiderProfile
    {
        return DB::transaction(function () use ($riderProfile, $actor) {
            $oldValues = $riderProfile->only([
                'application_status',
                'approved_at',
                'rejected_at',
                'rejection_reason',
            ]);

            $riderProfile->forceFill([
                'application_status' => ApplicationStatus::Approved,
                'availability_status' => AvailabilityStatus::Offline,
                'approved_at' => now(),
                'rejected_at' => null,
                'rejection_reason' => null,
            ])->save();

            $this->auditLogService->log(
                'driver.approved',
                $actor,
                $riderProfile,
                $oldValues,
                $riderProfile->only(array_keys($oldValues))
            );

            return $riderProfile->refresh();
        });
    }

    public function reject(RiderProfile $riderProfile, User $actor, string $reason): RiderProfile
    {
        return DB::transaction(function () use ($riderProfile, $actor, $reason) {
            $oldValues = $riderProfile->only([
                'application_status',
                'approved_at',
                'rejected_at',
                'rejection_reason',
            ]);

            $riderProfile->forceFill([
                'application_status' => ApplicationStatus::Rejected,
                'approved_at' => null,
                'rejected_at' => now(),
                'rejection_reason' => $reason,
            ])->save();

            $this->auditLogService->log(
                'driver.rejected',
                $actor,
                $riderProfile,
                $oldValues,
                $riderProfile->only(array_keys($oldValues))
            );

            return $riderProfile->refresh();
        });
    }

    public function suspend(RiderProfile $riderProfile, User $actor, string $reason): RiderProfile
    {
        return DB::transaction(function () use ($riderProfile, $actor, $reason) {
            $oldValues = $riderProfile->only([
                'application_status',
                'availability_status',
                'rejection_reason',
            ]);

            $riderProfile->forceFill([
                'application_status' => ApplicationStatus::Suspended,
                'availability_status' => AvailabilityStatus::Unavailable,
                'rejection_reason' => $reason,
            ])->save();

            $this->auditLogService->log(
                'driver.suspended',
                $actor,
                $riderProfile,
                $oldValues,
                $riderProfile->only(array_keys($oldValues))
            );

            return $riderProfile->refresh();
        });
    }
}
