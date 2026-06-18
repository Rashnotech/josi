<?php

namespace App\Services;

use App\Enums\PaymentMethod;
use App\Enums\PaymentStatus;
use App\Enums\TripStatus;
use App\Models\RiderProfile;
use App\Models\Trip;
use App\Models\User;
use App\Models\Vehicle;
use App\Models\Zone;
use Illuminate\Support\Arr;
use Illuminate\Support\Facades\DB;
use InvalidArgumentException;

class TripService
{
    public function __construct(
        private readonly PricingService $pricingService,
        private readonly PaymentService $paymentService,
        private readonly CashLedgerService $cashLedgerService,
        private readonly AuditLogService $auditLogService
    ) {
    }

    public function requestTrip(
        ?User $customer,
        int|Zone $pickupZone,
        int|Zone $destinationZone,
        array $attributes,
        PaymentMethod $paymentMethod = PaymentMethod::Cash
    ): Trip {
        $this->assertRequiredTripAddresses($attributes);

        $zonePrice = $this->pricingService->quote($pickupZone, $destinationZone);
        $this->pricingService->assertPaymentMethodAllowed($zonePrice, $paymentMethod);

        return DB::transaction(function () use ($customer, $attributes, $paymentMethod, $zonePrice) {
            $trip = Trip::create(array_merge(
                Arr::only($attributes, [
                    'pickup_address',
                    'pickup_latitude',
                    'pickup_longitude',
                    'destination_address',
                    'destination_latitude',
                    'destination_longitude',
                    'service_type',
                ]),
                [
                    'customer_id' => $customer?->getKey(),
                    'pickup_zone_id' => $zonePrice->pickup_zone_id,
                    'destination_zone_id' => $zonePrice->destination_zone_id,
                    'amount' => $zonePrice->base_price,
                    'payment_method' => $paymentMethod,
                    'payment_status' => PaymentStatus::Pending,
                    'trip_status' => TripStatus::Requested,
                    'requested_at' => now(),
                ]
            ));

            $this->paymentService->createPendingPayment($trip, $customer);

            return $trip->load(['payment', 'pickupZone', 'destinationZone']);
        });
    }

    public function assignToRider(
        Trip $trip,
        RiderProfile $riderProfile,
        ?Vehicle $vehicle = null,
        ?User $actor = null
    ): Trip {
        if (! in_array($trip->trip_status, [TripStatus::Requested, TripStatus::Assigned], true)) {
            throw new InvalidArgumentException('Only requested or assigned trips can be assigned to a rider.');
        }

        if ($vehicle && $vehicle->driver_profile_id && (int) $vehicle->driver_profile_id !== (int) $riderProfile->getKey()) {
            throw new InvalidArgumentException('The selected vehicle is already attached to another rider profile.');
        }

        return DB::transaction(function () use ($trip, $riderProfile, $vehicle, $actor) {
            $oldValues = $trip->only([
                'driver_profile_id',
                'vehicle_id',
                'trip_status',
            ]);

            $trip->forceFill([
                'driver_profile_id' => $riderProfile->getKey(),
                'vehicle_id' => $vehicle?->getKey(),
                'trip_status' => TripStatus::Assigned,
            ])->save();

            $this->auditLogService->log(
                'trip.assigned',
                $actor,
                $trip,
                $oldValues,
                $trip->only(array_keys($oldValues))
            );

            return $trip->refresh();
        });
    }

    public function acceptTrip(Trip $trip, RiderProfile $riderProfile): Trip
    {
        if ($trip->trip_status !== TripStatus::Assigned) {
            throw new InvalidArgumentException('Only assigned trips can be accepted.');
        }

        if ((int) $trip->driver_profile_id !== (int) $riderProfile->getKey()) {
            throw new InvalidArgumentException('Only the assigned rider can accept this trip.');
        }

        $trip->forceFill([
            'trip_status' => TripStatus::Accepted,
            'accepted_at' => now(),
        ])->save();

        return $trip->refresh();
    }

    public function startTrip(Trip $trip, RiderProfile $riderProfile): Trip
    {
        if ($trip->trip_status !== TripStatus::Accepted) {
            throw new InvalidArgumentException('Only accepted trips can be started.');
        }

        if ((int) $trip->driver_profile_id !== (int) $riderProfile->getKey()) {
            throw new InvalidArgumentException('Only the assigned rider can start this trip.');
        }

        $trip->forceFill([
            'trip_status' => TripStatus::Ongoing,
            'started_at' => now(),
        ])->save();

        return $trip->refresh();
    }

    public function completeTrip(Trip $trip, ?User $actor = null): Trip
    {
        if (! in_array($trip->trip_status, [TripStatus::Accepted, TripStatus::Ongoing], true)) {
            throw new InvalidArgumentException('Only accepted or ongoing trips can be completed.');
        }

        return DB::transaction(function () use ($trip, $actor) {
            $oldValues = $trip->only([
                'payment_status',
                'trip_status',
                'completed_at',
            ]);

            $trip->forceFill([
                'trip_status' => TripStatus::Completed,
                'completed_at' => now(),
            ])->save();

            if ($trip->payment_method === PaymentMethod::Cash) {
                $this->paymentService->markCashCollected($trip, $actor);
                $this->cashLedgerService->createForCashTrip($trip->refresh());
            }

            $this->auditLogService->log(
                'trip.completed',
                $actor,
                $trip,
                $oldValues,
                $trip->only(array_keys($oldValues))
            );

            return $trip->refresh();
        });
    }

    public function cancelTrip(Trip $trip, string $reason, ?User $actor = null): Trip
    {
        if (in_array($trip->trip_status, [TripStatus::Completed, TripStatus::Cancelled], true)) {
            throw new InvalidArgumentException('Completed or cancelled trips cannot be cancelled again.');
        }

        return DB::transaction(function () use ($trip, $reason, $actor) {
            $oldValues = $trip->only([
                'payment_status',
                'trip_status',
                'cancelled_at',
                'cancellation_reason',
            ]);

            $trip->forceFill([
                'payment_status' => PaymentStatus::Cancelled,
                'trip_status' => TripStatus::Cancelled,
                'cancelled_at' => now(),
                'cancellation_reason' => $reason,
            ])->save();

            $trip->payment?->forceFill([
                'payment_status' => PaymentStatus::Cancelled,
            ])->save();

            $this->auditLogService->log(
                'trip.cancelled',
                $actor,
                $trip,
                $oldValues,
                $trip->only(array_keys($oldValues))
            );

            return $trip->refresh();
        });
    }

    private function assertRequiredTripAddresses(array $attributes): void
    {
        foreach (['pickup_address', 'destination_address'] as $field) {
            if (! isset($attributes[$field]) || trim((string) $attributes[$field]) === '') {
                throw new InvalidArgumentException("{$field} is required to request a trip.");
            }
        }
    }
}
