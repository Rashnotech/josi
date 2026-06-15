<?php

namespace App\Services;

use App\Enums\VehicleStatus;
use App\Enums\VerificationStatus;
use App\Models\User;
use App\Models\Vehicle;
use Illuminate\Support\Facades\DB;

class VehicleVerificationService
{
    public function __construct(private readonly AuditLogService $auditLogService)
    {
    }

    public function verify(Vehicle $vehicle, User $actor): Vehicle
    {
        return DB::transaction(function () use ($vehicle, $actor) {
            $oldValues = $vehicle->only([
                'vehicle_status',
                'verification_status',
            ]);

            $vehicle->forceFill([
                'vehicle_status' => VehicleStatus::Active,
                'verification_status' => VerificationStatus::Verified,
            ])->save();

            $this->auditLogService->log(
                'vehicle.verified',
                $actor,
                $vehicle,
                $oldValues,
                $vehicle->only(array_keys($oldValues))
            );

            return $vehicle->refresh();
        });
    }

    public function reject(Vehicle $vehicle, User $actor, string $reason): Vehicle
    {
        return DB::transaction(function () use ($vehicle, $actor, $reason) {
            $oldValues = $vehicle->only([
                'vehicle_status',
                'verification_status',
            ]);

            $vehicle->forceFill([
                'vehicle_status' => VehicleStatus::Inactive,
                'verification_status' => VerificationStatus::Rejected,
            ])->save();

            $this->auditLogService->log(
                'vehicle.rejected',
                $actor,
                $vehicle,
                $oldValues,
                [
                    ...$vehicle->only(array_keys($oldValues)),
                    'rejection_reason' => $reason,
                ]
            );

            return $vehicle->refresh();
        });
    }

    public function suspend(Vehicle $vehicle, User $actor, string $reason): Vehicle
    {
        return $this->setStatus($vehicle, $actor, VehicleStatus::Suspended, 'vehicle.suspended', $reason);
    }

    public function markActive(Vehicle $vehicle, User $actor): Vehicle
    {
        return $this->setStatus($vehicle, $actor, VehicleStatus::Active, 'vehicle.activated');
    }

    private function setStatus(Vehicle $vehicle, User $actor, VehicleStatus $status, string $action, ?string $reason = null): Vehicle
    {
        return DB::transaction(function () use ($vehicle, $actor, $status, $action, $reason) {
            $oldValues = $vehicle->only(['vehicle_status']);

            $vehicle->forceFill([
                'vehicle_status' => $status,
            ])->save();

            $this->auditLogService->log(
                $action,
                $actor,
                $vehicle,
                $oldValues,
                [
                    ...$vehicle->only(array_keys($oldValues)),
                    'reason' => $reason,
                ]
            );

            return $vehicle->refresh();
        });
    }
}
