<?php

namespace App\Http\Controllers\Api\V1;

use App\Enums\PaymentMethod;
use App\Enums\ApplicationStatus;
use App\Enums\AvailabilityStatus;
use App\Enums\TripStatus;
use App\Enums\VehicleStatus;
use App\Enums\VerificationStatus;
use App\Exceptions\ActiveZonePriceNotFoundException;
use App\Http\Controllers\Controller;
use App\Http\Responses\ApiResponse;
use App\Models\RiderProfile;
use App\Models\Trip;
use App\Models\TripReview;
use App\Models\Vehicle;
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
            ->with(['pickupZone', 'destinationZone', 'riderProfile.user', 'vehicle', 'review'])
            ->latest('requested_at')
            ->limit(30)
            ->get()
            ->map(fn (Trip $trip): array => self::tripPayload($trip))
            ->all();

        return ApiResponse::success('Customer trips fetched successfully', [
            'trips' => $trips,
        ]);
    }

    public function show(Request $request, Trip $trip)
    {
        if ((int) $trip->customer_id !== (int) $request->user()->getKey()) {
            return ApiResponse::error('Trip was not found for this customer.', [], 404);
        }

        return ApiResponse::success('Customer trip fetched successfully', [
            'trip' => self::tripPayload($trip->load([
                'pickupZone',
                'destinationZone',
                'riderProfile.user',
                'vehicle',
                'review',
            ])),
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
            'trip' => self::tripPayload($trip),
        ], 201);
    }

    public function availableRiders(Request $request, Trip $trip)
    {
        if ((int) $trip->customer_id !== (int) $request->user()->getKey()) {
            return ApiResponse::error('Trip was not found for this customer.', [], 404);
        }

        if (! in_array(self::enumValue($trip->trip_status), [TripStatus::Requested->value, TripStatus::Assigned->value], true)) {
            return ApiResponse::error('Rider search is only available for requested trips.', [], 422);
        }

        $busyStatuses = [
            TripStatus::Assigned->value,
            TripStatus::Accepted->value,
            TripStatus::Ongoing->value,
        ];

        $riders = RiderProfile::query()
            ->with(['user', 'vehicles' => function ($query): void {
                $query
                    ->where('vehicle_status', VehicleStatus::Active->value)
                    ->where('verification_status', VerificationStatus::Verified->value)
                    ->oldest();
            }])
            ->where('application_status', ApplicationStatus::Approved->value)
            ->whereNotIn('availability_status', [
                AvailabilityStatus::Busy->value,
                AvailabilityStatus::Unavailable->value,
            ])
            ->whereHas('vehicles', function ($query): void {
                $query
                    ->where('vehicle_status', VehicleStatus::Active->value)
                    ->where('verification_status', VerificationStatus::Verified->value);
            })
            ->whereDoesntHave('trips', function ($query) use ($busyStatuses): void {
                $query->whereIn('trip_status', $busyStatuses);
            })
            ->limit(10)
            ->get()
            ->map(fn (RiderProfile $profile): array => self::riderPayload($profile, $profile->vehicles->first()))
            ->values()
            ->all();

        return ApiResponse::success('Available riders fetched successfully', [
            'riders' => $riders,
        ]);
    }

    public function requestRider(Request $request, Trip $trip, TripService $tripService)
    {
        if ((int) $trip->customer_id !== (int) $request->user()->getKey()) {
            return ApiResponse::error('Trip was not found for this customer.', [], 404);
        }

        $data = $request->validate([
            'rider_profile_id' => ['required', 'integer', 'exists:rider_profiles,id'],
        ]);

        $rider = RiderProfile::query()->with(['user', 'vehicles'])->findOrFail($data['rider_profile_id']);
        if (self::enumValue($rider->application_status) !== ApplicationStatus::Approved->value) {
            return ApiResponse::error('This rider is not approved for trip requests yet.', [], 422);
        }

        if (in_array(self::enumValue($rider->availability_status), [AvailabilityStatus::Busy->value, AvailabilityStatus::Unavailable->value], true)) {
            return ApiResponse::error('This rider is not available right now.', [], 422);
        }

        $busyStatuses = [
            TripStatus::Assigned->value,
            TripStatus::Accepted->value,
            TripStatus::Ongoing->value,
        ];

        if ($rider->trips()->whereIn('trip_status', $busyStatuses)->exists()) {
            return ApiResponse::error('This rider already has an active trip.', [], 422);
        }

        $vehicle = $rider->vehicles
            ->first(fn (Vehicle $vehicle): bool => self::enumValue($vehicle->vehicle_status) === VehicleStatus::Active->value
                && self::enumValue($vehicle->verification_status) === VerificationStatus::Verified->value);

        if (! $vehicle) {
            return ApiResponse::error('This rider does not have an active verified bike yet.', [], 422);
        }

        try {
            $trip = $tripService->assignToRider($trip, $rider, $vehicle, $request->user());
        } catch (InvalidArgumentException $exception) {
            return ApiResponse::error($exception->getMessage(), [], 422);
        }

        $rider->forceFill([
            'availability_status' => AvailabilityStatus::Busy,
        ])->save();

        return ApiResponse::success('Rider requested and notified successfully', [
            'rider_notified' => true,
            'trip' => self::tripPayload($trip->load([
                'pickupZone',
                'destinationZone',
                'riderProfile.user',
                'vehicle',
                'review',
            ])),
        ]);
    }

    public function review(Request $request, Trip $trip)
    {
        if ((int) $trip->customer_id !== (int) $request->user()->getKey()) {
            return ApiResponse::error('Trip was not found for this customer.', [], 404);
        }

        if (! $trip->driver_profile_id) {
            return ApiResponse::error('A rider must be assigned before a review can be submitted.', [], 422);
        }

        if (self::enumValue($trip->trip_status) === TripStatus::Cancelled->value) {
            return ApiResponse::error('Cancelled trips cannot be reviewed.', [], 422);
        }

        $data = $request->validate([
            'rating' => ['required', 'integer', 'min:1', 'max:5'],
            'review' => ['sometimes', 'nullable', 'string', 'max:2000'],
        ]);

        $review = TripReview::query()->updateOrCreate(
            ['trip_id' => $trip->getKey()],
            [
                'customer_id' => $request->user()->getKey(),
                'driver_profile_id' => $trip->driver_profile_id,
                'rating' => $data['rating'],
                'review' => $data['review'] ?? null,
            ]
        );

        return ApiResponse::success('Rider review submitted successfully', [
            'review' => [
                'id' => $review->getKey(),
                'rating' => $review->rating,
                'review' => $review->review,
            ],
        ]);
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

    public static function tripPayload(Trip $trip): array
    {
        $trip->loadMissing(['pickupZone', 'destinationZone', 'riderProfile.user', 'vehicle', 'review']);

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
            'payment_method' => self::enumValue($trip->payment_method),
            'payment_status' => self::enumValue($trip->payment_status),
            'trip_status' => self::enumValue($trip->trip_status),
            'is_arrived_at_pickup' => $trip->started_at !== null || self::enumValue($trip->trip_status) === TripStatus::Ongoing->value,
            'pickup_zone' => $trip->pickupZone?->name,
            'destination_zone' => $trip->destinationZone?->name,
            'rider' => $trip->riderProfile ? self::riderPayload($trip->riderProfile, $trip->vehicle) : null,
            'rider_name' => $trip->riderProfile?->user?->name,
            'rider_phone' => $trip->riderProfile?->phone ?? $trip->riderProfile?->user?->phone,
            'vehicle_label' => self::vehicleLabel($trip->vehicle),
            'plate_number' => $trip->vehicle?->plate_number,
            'requested_at' => $trip->requested_at?->toISOString(),
            'accepted_at' => $trip->accepted_at?->toISOString(),
            'arrived_at_pickup' => $trip->started_at?->toISOString(),
            'completed_at' => $trip->completed_at?->toISOString(),
            'review' => $trip->review ? [
                'rating' => $trip->review->rating,
                'review' => $trip->review->review,
            ] : null,
        ];
    }

    public static function riderPayload(RiderProfile $profile, ?Vehicle $vehicle = null): array
    {
        $profile->loadMissing('user');
        $vehicle ??= $profile->relationLoaded('vehicles') ? $profile->vehicles->first() : $profile->vehicles()->oldest()->first();

        return [
            'id' => $profile->getKey(),
            'name' => trim(($profile->first_name ?? '').' '.($profile->last_name ?? '')) ?: $profile->user?->name,
            'phone' => $profile->phone ?: $profile->user?->phone,
            'city' => $profile->city,
            'state' => $profile->state,
            'profile_photo' => $profile->profile_photo,
            'availability_status' => self::enumValue($profile->availability_status),
            'vehicle' => $vehicle ? [
                'id' => $vehicle->getKey(),
                'vehicle_type' => self::enumValue($vehicle->vehicle_type),
                'brand' => $vehicle->brand,
                'model' => $vehicle->model,
                'color' => $vehicle->color,
                'plate_number' => $vehicle->plate_number,
                'label' => self::vehicleLabel($vehicle),
            ] : null,
        ];
    }

    private static function vehicleLabel(?Vehicle $vehicle): ?string
    {
        if (! $vehicle) {
            return null;
        }

        return trim(collect([$vehicle->color, $vehicle->brand, $vehicle->model])
            ->filter(fn ($value): bool => trim((string) $value) !== '')
            ->join(' ')) ?: self::enumValue($vehicle->vehicle_type);
    }

    private static function enumValue(mixed $value): mixed
    {
        return $value instanceof \BackedEnum ? $value->value : $value;
    }
}
