<?php

namespace App\Services;

use App\Enums\PaymentMethod;
use App\Exceptions\ActiveZonePriceNotFoundException;
use App\Models\Zone;
use App\Models\ZonePrice;
use InvalidArgumentException;

class PricingService
{
    public function quote(int|Zone $pickupZone, int|Zone $destinationZone): ZonePrice
    {
        $pickupZoneId = $pickupZone instanceof Zone ? $pickupZone->getKey() : $pickupZone;
        $destinationZoneId = $destinationZone instanceof Zone ? $destinationZone->getKey() : $destinationZone;

        $zonePrice = ZonePrice::query()
            ->where('pickup_zone_id', $pickupZoneId)
            ->where('destination_zone_id', $destinationZoneId)
            ->where('is_active', true)
            ->latest('id')
            ->first();

        if (! $zonePrice) {
            throw ActiveZonePriceNotFoundException::forZones($pickupZoneId, $destinationZoneId);
        }

        return $zonePrice->load(['pickupZone', 'destinationZone']);
    }

    public function assertPaymentMethodAllowed(ZonePrice $zonePrice, PaymentMethod $paymentMethod): void
    {
        if ($paymentMethod === PaymentMethod::Cash && ! $zonePrice->cash_allowed) {
            throw new InvalidArgumentException('Cash payment is not allowed for this zone price.');
        }

        if ($paymentMethod !== PaymentMethod::Cash && ! $zonePrice->online_payment_allowed) {
            throw new InvalidArgumentException('Online payment is not allowed for this zone price.');
        }
    }
}
