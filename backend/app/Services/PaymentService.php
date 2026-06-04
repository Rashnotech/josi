<?php

namespace App\Services;

use App\Enums\PaymentMethod;
use App\Enums\PaymentStatus;
use App\Models\Payment;
use App\Models\Trip;
use App\Models\User;
use Illuminate\Support\Facades\DB;
use InvalidArgumentException;

class PaymentService
{
    public function __construct(private readonly AuditLogService $auditLogService)
    {
    }

    public function createPendingPayment(Trip $trip, ?User $payer = null): Payment
    {
        return Payment::create([
            'trip_id' => $trip->getKey(),
            'user_id' => $payer?->getKey() ?? $trip->customer_id,
            'amount' => $trip->amount,
            'payment_method' => $trip->payment_method,
            'payment_status' => PaymentStatus::Pending,
        ]);
    }

    public function markVerifiedPaid(
        Payment $payment,
        User $actor,
        string $paymentReference,
        ?string $gateway = null,
        array $gatewayResponse = []
    ): Payment {
        if ($payment->payment_method === PaymentMethod::Cash) {
            throw new InvalidArgumentException('Cash payments must be collected from completed trips, not marked as online paid.');
        }

        return DB::transaction(function () use ($payment, $actor, $paymentReference, $gateway, $gatewayResponse) {
            $oldValues = $payment->only([
                'payment_status',
                'payment_reference',
                'gateway',
                'gateway_response',
                'paid_at',
                'failed_at',
            ]);

            $payment->forceFill([
                'payment_status' => PaymentStatus::Paid,
                'payment_reference' => $paymentReference,
                'gateway' => $gateway,
                'gateway_response' => $gatewayResponse ?: null,
                'paid_at' => now(),
                'failed_at' => null,
            ])->save();

            $payment->trip()->update([
                'payment_status' => PaymentStatus::Paid->value,
            ]);

            $this->auditLogService->log(
                'payment.verified',
                $actor,
                $payment,
                $oldValues,
                $payment->only(array_keys($oldValues))
            );

            return $payment->refresh();
        });
    }

    public function markCashCollected(Trip $trip, ?User $actor = null): Payment
    {
        if ($trip->payment_method !== PaymentMethod::Cash) {
            throw new InvalidArgumentException('Only cash trips can be marked as cash collected.');
        }

        return DB::transaction(function () use ($trip, $actor) {
            $payment = $trip->payment ?: $this->createPendingPayment($trip, $trip->customer);

            $oldValues = $payment->only([
                'payment_status',
                'paid_at',
                'failed_at',
            ]);

            $payment->forceFill([
                'payment_status' => PaymentStatus::CashCollected,
                'paid_at' => now(),
                'failed_at' => null,
            ])->save();

            $trip->forceFill([
                'payment_status' => PaymentStatus::CashCollected,
            ])->save();

            $this->auditLogService->log(
                'payment.cash_collected',
                $actor,
                $payment,
                $oldValues,
                $payment->only(array_keys($oldValues))
            );

            return $payment->refresh();
        });
    }

    public function recordFailedPayment(Payment $payment, ?User $actor = null, array $gatewayResponse = []): Payment
    {
        return DB::transaction(function () use ($payment, $actor, $gatewayResponse) {
            $oldValues = $payment->only([
                'payment_status',
                'gateway_response',
                'failed_at',
            ]);

            $payment->forceFill([
                'payment_status' => PaymentStatus::Failed,
                'gateway_response' => $gatewayResponse ?: null,
                'failed_at' => now(),
            ])->save();

            $payment->trip()->update([
                'payment_status' => PaymentStatus::Failed->value,
            ]);

            $this->auditLogService->log(
                'payment.failed',
                $actor,
                $payment,
                $oldValues,
                $payment->only(array_keys($oldValues))
            );

            return $payment->refresh();
        });
    }
}
