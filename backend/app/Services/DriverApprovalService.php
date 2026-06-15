<?php

namespace App\Services;

use App\Enums\ApplicationStatus;
use App\Enums\AvailabilityStatus;
use App\Enums\UserRole;
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
                $this->auditAction($riderProfile, 'approved'),
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
                $this->auditAction($riderProfile, 'rejected'),
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
                $this->auditAction($riderProfile, 'suspended'),
                $actor,
                $riderProfile,
                $oldValues,
                $riderProfile->only(array_keys($oldValues))
            );

            return $riderProfile->refresh();
        });
    }

    public function markUnderReview(RiderProfile $riderProfile, User $actor): RiderProfile
    {
        return DB::transaction(function () use ($riderProfile, $actor) {
            $oldValues = $riderProfile->only(['application_status']);

            $riderProfile->forceFill([
                'application_status' => ApplicationStatus::UnderReview,
            ])->save();

            $this->auditLogService->log(
                $this->auditAction($riderProfile, 'under_review'),
                $actor,
                $riderProfile,
                $oldValues,
                $riderProfile->only(array_keys($oldValues))
            );

            return $riderProfile->refresh();
        });
    }

    public function reactivate(RiderProfile $riderProfile, User $actor): RiderProfile
    {
        return DB::transaction(function () use ($riderProfile, $actor) {
            $oldValues = $riderProfile->only([
                'application_status',
                'availability_status',
                'rejection_reason',
            ]);

            $riderProfile->forceFill([
                'application_status' => ApplicationStatus::Approved,
                'availability_status' => AvailabilityStatus::Offline,
                'rejection_reason' => null,
            ])->save();

            $this->auditLogService->log(
                $this->auditAction($riderProfile, 'reactivated'),
                $actor,
                $riderProfile,
                $oldValues,
                $riderProfile->only(array_keys($oldValues))
            );

            return $riderProfile->refresh();
        });
    }

    private function auditAction(RiderProfile $riderProfile, string $action): string
    {
        $role = $riderProfile->user?->role;
        $roleValue = $role instanceof UserRole ? $role->value : (string) $role;

        if ($roleValue === UserRole::Driver->value && $action === 'approved') {
            return 'driver.approved';
        }

        return match ($roleValue) {
            UserRole::Courier->value => "courier.{$action}",
            UserRole::Rider->value => "rider.{$action}",
            UserRole::Driver->value => "driver.{$action}",
            default => "driver.{$action}",
        };
    }
}
