<?php

namespace App\Http\Controllers\Api\V1;

use App\Enums\AvailabilityStatus;
use App\Enums\TripStatus;
use App\Http\Controllers\Controller;
use App\Http\Responses\ApiResponse;
use App\Models\Trip;
use App\Services\TripService;
use Illuminate\Http\Request;
use InvalidArgumentException;

class DriverTripController extends Controller
{
    public function index(Request $request)
    {
        $profile = $request->user()->riderProfile;
        if (! $profile) {
            return ApiResponse::error('Rider profile was not found for this account.', [], 404);
        }

        $trips = $profile
            ->trips()
            ->with(['customer', 'vehicle', 'pickupZone', 'destinationZone', 'review'])
            ->whereIn('trip_status', [
                TripStatus::Assigned->value,
                TripStatus::Accepted->value,
                TripStatus::Ongoing->value,
            ])
            ->latest('requested_at')
            ->limit(30)
            ->get()
            ->map(fn (Trip $trip): array => CustomerTripController::tripPayload($trip))
            ->all();

        return ApiResponse::success('Driver trips fetched successfully', [
            'trips' => $trips,
        ]);
    }

    public function show(Request $request, Trip $trip)
    {
        $profile = $request->user()->riderProfile;
        if (! $profile || (int) $trip->driver_profile_id !== (int) $profile->getKey()) {
            return ApiResponse::error('Trip was not found for this rider.', [], 404);
        }

        return ApiResponse::success('Driver trip fetched successfully', [
            'trip' => CustomerTripController::tripPayload($trip->load([
                'customer',
                'riderProfile.user',
                'vehicle',
                'pickupZone',
                'destinationZone',
                'review',
            ])),
        ]);
    }

    public function accept(Request $request, Trip $trip, TripService $tripService)
    {
        $profile = $request->user()->riderProfile;
        if (! $profile) {
            return ApiResponse::error('Rider profile was not found for this account.', [], 404);
        }

        try {
            $trip = $tripService->acceptTrip($trip, $profile);
        } catch (InvalidArgumentException $exception) {
            return ApiResponse::error($exception->getMessage(), [], 422);
        }

        $profile->forceFill([
            'availability_status' => AvailabilityStatus::Busy,
        ])->save();

        return ApiResponse::success('Trip accepted successfully', [
            'trip' => CustomerTripController::tripPayload($trip->load([
                'customer',
                'riderProfile.user',
                'vehicle',
                'pickupZone',
                'destinationZone',
                'review',
            ])),
        ]);
    }

    public function arrived(Request $request, Trip $trip, TripService $tripService)
    {
        $profile = $request->user()->riderProfile;
        if (! $profile) {
            return ApiResponse::error('Rider profile was not found for this account.', [], 404);
        }

        try {
            $trip = $tripService->startTrip($trip, $profile);
        } catch (InvalidArgumentException $exception) {
            return ApiResponse::error($exception->getMessage(), [], 422);
        }

        return ApiResponse::success('Rider arrival recorded successfully', [
            'trip' => CustomerTripController::tripPayload($trip->load([
                'customer',
                'riderProfile.user',
                'vehicle',
                'pickupZone',
                'destinationZone',
                'review',
            ])),
        ]);
    }
}
