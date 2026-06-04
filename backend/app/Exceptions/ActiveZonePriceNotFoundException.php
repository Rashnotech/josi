<?php

namespace App\Exceptions;

use RuntimeException;

class ActiveZonePriceNotFoundException extends RuntimeException
{
    public static function forZones(int $pickupZoneId, int $destinationZoneId): self
    {
        return new self("No active zone price exists for pickup zone {$pickupZoneId} and destination zone {$destinationZoneId}.");
    }
}
