<?php

namespace App\Http\Controllers\Api\V1;

use App\Enums\PaymentMethod;
use App\Exceptions\ActiveZonePriceNotFoundException;
use App\Http\Controllers\Controller;
use App\Http\Responses\ApiResponse;
use App\Models\Trip;
use App\Models\Zone;
use App\Models\ZonePrice;
use App\Services\TripService;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;
use InvalidArgumentException;

class CustomerTripController extends Controller
{
    public function index(Request $request)
    {
        $trips = $request->user()
            ->trips()
            ->with(['pickupZone', 'destinationZone', 'riderProfile.user'])
            ->latest('requested_at')
            ->limit(30)
            ->get()
            ->map(fn (Trip $trip): array => $this->tripPayload($trip))
            ->all();

        return ApiResponse::success('Customer trips fetched successfully', [
            'trips' => $trips,
        ]);
    }

    public function store(Request $request, TripService $tripService)
    {
        $data = $request->validate([
            'pickup_address' => ['required', 'string', 'max:1000'],
            'pickup_latitude' => ['sometimes', 'nullable', 'numeric', 'between:-90,90'],
            'pickup_longitude' => ['sometimes', 'nullable', 'numeric', 'between:-180,180'],
            'destination_address' => ['required', 'string', 'max:1000'],
            'destination_latitude' => ['sometimes', 'nullable', 'numeric', 'between:-90,90'],
            'destination_longitude' => ['sometimes', 'nullable', 'numeric', 'between:-180,180'],
            'pickup_zone_id' => ['sometimes', 'nullable', 'integer', 'exists:zones,id'],
            'destination_zone_id' => ['sometimes', 'nullable', 'integer', 'exists:zones,id'],
            'payment_method' => ['sometimes', 'string', Rule::in(PaymentMethod::values())],
            'service_type' => ['sometimes', 'string', Rule::in(['ride', 'courier'])],
        ]);

        try {
            [$pickupZone, $destinationZone] = $this->resolveZonePair($data);
            $trip = $tripService->requestTrip(
                $request->user(),
                $pickupZone,
                $destinationZone,
                [
                    'pickup_address' => $data['pickup_address'],
                    'pickup_latitude' => $data['pickup_latitude'] ?? null,
                    'pickup_longitude' => $data['pickup_longitude'] ?? null,
                    'destination_address' => $data['destination_address'],
                    'destination_latitude' => $data['destination_latitude'] ?? null,
                    'destination_longitude' => $data['destination_longitude'] ?? null,
                    'service_type' => $data['service_type'] ?? 'ride',
                ],
                PaymentMethod::from($data['payment_method'] ?? PaymentMethod::Cash->value)
            );
        } catch (ActiveZonePriceNotFoundException|InvalidArgumentException $exception) {
            return ApiResponse::error($exception->getMessage(), [], 422);
        }

        return ApiResponse::success('Customer trip requested successfully', [
            'trip' => $this->tripPayload($trip),
        ], 201);
    }

    private function resolveZonePair(array $data): array
    {
        if (! empty($data['pickup_zone_id']) && ! empty($data['destination_zone_id'])) {
            return [
                Zone::query()->findOrFail($data['pickup_zone_id']),
                Zone::query()->findOrFail($data['destination_zone_id']),
            ];
        }

        $prices = ZonePrice::query()
            ->where('is_active', true)
            ->with(['pickupZone', 'destinationZone'])
            ->get()
            ->filter(fn (ZonePrice $price): bool => $price->pickupZone !== null && $price->destinationZone !== null);

        if ($prices->isEmpty()) {
            throw new InvalidArgumentException('No active customer route pricing is available yet.');
        }

        $pickupLatitude = $data['pickup_latitude'] ?? null;
        $pickupLongitude = $data['pickup_longitude'] ?? null;
        $destinationLatitude = $data['destination_latitude'] ?? null;
        $destinationLongitude = $data['destination_longitude'] ?? null;

        $price = $prices
            ->sortBy(function (ZonePrice $price) use ($pickupLatitude, $pickupLongitude, $destinationLatitude, $destinationLongitude): float {
                return $this->distanceScore($price->pickupZone, $pickupLatitude, $pickupLongitude)
                    + $this->distanceScore($price->destinationZone, $destinationLatitude, $destinationLongitude);
            })
            ->first();

        return [$price->pickupZone, $price->destinationZone];
    }

    private function distanceScore(?Zone $zone, mixed $latitude, mixed $longitude): float
    {
        if ($zone === null || $zone->latitude === null || $zone->longitude === null || $latitude === null || $longitude === null) {
            return 0;
        }

        return abs((float) $zone->latitude - (float) $latitude)
            + abs((float) $zone->longitude - (float) $longitude);
    }

    private function tripPayload(Trip $trip): array
    {
        return [
            'id' => $trip->getKey(),
            'service_type' => $trip->service_type,
            'pickup_address' => $trip->pickup_address,
            'destination_address' => $trip->destination_address,
            'pickup_latitude' => $trip->pickup_latitude,
            'pickup_longitude' => $trip->pickup_longitude,
            'destination_latitude' => $trip->destination_latitude,
            'destination_longitude' => $trip->destination_longitude,
            'amount' => $trip->amount,
            'payment_method' => $this->enumValue($trip->payment_method),
            'payment_status' => $this->enumValue($trip->payment_status),
            'trip_status' => $this->enumValue($trip->trip_status),
            'pickup_zone' => $trip->pickupZone?->name,
            'destination_zone' => $trip->destinationZone?->name,
            'rider_name' => $trip->riderProfile?->user?->name,
            'requested_at' => $trip->requested_at?->toISOString(),
        ];
    }

    private function enumValue(mixed $value): mixed
    {
        return $value instanceof \BackedEnum ? $value->value : $value;
    }
}
