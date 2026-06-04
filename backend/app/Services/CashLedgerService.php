<?php

namespace App\Services;

use App\Enums\PaymentMethod;
use App\Enums\RemittanceStatus;
use App\Enums\TripStatus;
use App\Models\RiderCashLedger;
use App\Models\Trip;
use App\Models\User;
use Illuminate\Support\Facades\DB;
use InvalidArgumentException;

class CashLedgerService
{
    public function __construct(private readonly AuditLogService $auditLogService)
    {
    }

    public function createForCashTrip(Trip $trip, float $riderSharePercentage = 0.70): RiderCashLedger
    {
        if ($trip->payment_method !== PaymentMethod::Cash) {
            throw new InvalidArgumentException('Only cash trips create rider cash ledger entries.');
        }

        if ($trip->trip_status !== TripStatus::Completed) {
            throw new InvalidArgumentException('Cash ledger entries are created only after trip completion.');
        }

        if (! $trip->driver_profile_id) {
            throw new InvalidArgumentException('A cash ledger entry requires an assigned rider profile.');
        }

        $amountCollected = round((float) $trip->amount, 2);
        $riderShare = round($amountCollected * $riderSharePercentage, 2);
        $companyShare = round($amountCollected - $riderShare, 2);

        return RiderCashLedger::firstOrCreate(
            ['trip_id' => $trip->getKey()],
            [
                'driver_profile_id' => $trip->driver_profile_id,
                'amount_collected' => $amountCollected,
                'rider_share' => $riderShare,
                'company_share' => $companyShare,
                'amount_to_remit' => $companyShare,
                'amount_remitted' => 0,
                'remittance_status' => RemittanceStatus::Pending,
            ]
        );
    }

    public function recordRemittance(
        RiderCashLedger $ledger,
        User $actor,
        float $amount,
        ?string $notes = null
    ): RiderCashLedger {
        if ($amount <= 0) {
            throw new InvalidArgumentException('Remittance amount must be greater than zero.');
        }

        return DB::transaction(function () use ($ledger, $actor, $amount, $notes) {
            $oldValues = $ledger->only([
                'amount_remitted',
                'remittance_status',
                'remitted_at',
                'notes',
            ]);

            $amountRemitted = round((float) $ledger->amount_remitted + $amount, 2);
            $amountToRemit = round((float) $ledger->amount_to_remit, 2);

            $status = $amountRemitted >= $amountToRemit
                ? RemittanceStatus::Remitted
                : RemittanceStatus::PartiallyRemitted;

            $ledger->forceFill([
                'amount_remitted' => min($amountRemitted, $amountToRemit),
                'remittance_status' => $status,
                'remitted_at' => $status === RemittanceStatus::Remitted ? now() : $ledger->remitted_at,
                'notes' => $notes ?? $ledger->notes,
            ])->save();

            $this->auditLogService->log(
                'cash_ledger.remittance_updated',
                $actor,
                $ledger,
                $oldValues,
                $ledger->only(array_keys($oldValues))
            );

            return $ledger->refresh();
        });
    }

    public function waive(RiderCashLedger $ledger, User $actor, ?string $notes = null): RiderCashLedger
    {
        return DB::transaction(function () use ($ledger, $actor, $notes) {
            $oldValues = $ledger->only([
                'remittance_status',
                'notes',
            ]);

            $ledger->forceFill([
                'remittance_status' => RemittanceStatus::Waived,
                'notes' => $notes ?? $ledger->notes,
            ])->save();

            $this->auditLogService->log(
                'cash_ledger.waived',
                $actor,
                $ledger,
                $oldValues,
                $ledger->only(array_keys($oldValues))
            );

            return $ledger->refresh();
        });
    }
}
