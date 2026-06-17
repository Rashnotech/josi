<?php

namespace App\Services;

use App\Enums\ApplicationStatus;
use App\Enums\VehicleStatus;
use App\Enums\VerificationStatus;
use App\Models\RiderProfile;
use App\Models\User;
use App\Models\Vehicle;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

class DriverOnboardingService
{
    public function snapshot(User $user): array
    {
        $profile = $this->requireProfile($user);
        $vehicle = $profile->vehicles()->oldest()->first();

        $profilePictureComplete = $this->filled($profile->profile_photo);
        $bankAccountComplete = $this->filled($profile->bank_name)
            && $this->filled($profile->bank_account_name)
            && $this->filled($profile->bank_account_number);
        $ridingDetailsComplete = $vehicle instanceof Vehicle
            && $this->filled($vehicle->vehicle_type)
            && $this->filled($vehicle->brand)
            && $this->filled($vehicle->model)
            && $this->filled($vehicle->color)
            && $this->filled($vehicle->plate_number);

        $missingSteps = [];
        if (! $profilePictureComplete) {
            $missingSteps[] = 'profile_picture';
        }
        if (! $bankAccountComplete) {
            $missingSteps[] = 'bank_account_details';
        }
        if (! $ridingDetailsComplete) {
            $missingSteps[] = 'riding_details';
        }

        return [
            'profile' => $this->profilePayload($profile),
            'bank_account' => $this->bankPayload($profile),
            'riding_details' => $this->vehiclePayload($vehicle),
            'onboarding' => [
                'profile_picture_complete' => $profilePictureComplete,
                'bank_account_complete' => $bankAccountComplete,
                'riding_details_complete' => $ridingDetailsComplete,
                'is_complete' => $profilePictureComplete && $bankAccountComplete && $ridingDetailsComplete,
                'is_submitted' => $profile->onboarding_submitted_at !== null,
                'submitted_at' => $profile->onboarding_submitted_at?->toISOString(),
                'missing_steps' => $missingSteps,
            ],
        ];
    }

    public function saveProfilePicture(User $user, array $data): array
    {
        $profile = $this->requireProfile($user);
        $profile->forceFill([
            'profile_photo' => $data['profile_photo'],
        ])->save();

        return $this->snapshot($user->refresh());
    }

    public function saveBankAccount(User $user, array $data): array
    {
        $profile = $this->requireProfile($user);
        $profile->forceFill([
            'bank_name' => $data['bank_name'],
            'bank_account_name' => $data['account_name'],
            'bank_account_number' => $data['account_number'],
        ])->save();

        return $this->snapshot($user->refresh());
    }

    public function saveRidingDetails(User $user, array $data): array
    {
        $profile = $this->requireProfile($user);

        return DB::transaction(function () use ($profile, $user, $data) {
            $profile->forceFill([
                'city' => $data['city'] ?? $profile->city,
                'state' => $data['state'] ?? $profile->state,
                'license_number' => $data['license_number'] ?? $profile->license_number,
            ])->save();

            $vehicle = $profile->vehicles()->oldest()->first();
            $attributes = [
                'fleet_id' => $profile->fleet_id,
                'vehicle_type' => $data['vehicle_type'],
                'brand' => $data['brand'],
                'model' => $data['model'],
                'color' => $data['color'],
                'plate_number' => $data['plate_number'],
                'registration_number' => $data['registration_number'] ?? null,
                'vehicle_status' => $vehicle?->vehicle_status ?? VehicleStatus::Inactive,
                'verification_status' => $vehicle?->verification_status ?? VerificationStatus::Pending,
            ];

            if ($vehicle) {
                $vehicle->forceFill($attributes)->save();
            } else {
                Vehicle::create(array_merge($attributes, [
                    'driver_profile_id' => $profile->getKey(),
                ]));
            }

            return $this->snapshot($user->refresh());
        });
    }

    public function submit(User $user): array
    {
        $profile = $this->requireProfile($user);
        $snapshot = $this->snapshot($user);
        $missingSteps = $snapshot['onboarding']['missing_steps'];

        if ($missingSteps !== []) {
            throw ValidationException::withMessages([
                'onboarding' => ['Complete all required rider account sections before submitting.'],
                'missing_steps' => $missingSteps,
            ]);
        }

        $profile->forceFill([
            'application_status' => ApplicationStatus::UnderReview,
            'onboarding_submitted_at' => now(),
            'rejected_at' => null,
            'rejection_reason' => null,
        ])->save();

        return $this->snapshot($user->refresh());
    }

    private function requireProfile(User $user): RiderProfile
    {
        $user->loadMissing('riderProfile');

        if (! $user->riderProfile) {
            throw ValidationException::withMessages([
                'profile' => ['Rider profile was not found for this account.'],
            ]);
        }

        return $user->riderProfile;
    }

    private function profilePayload(RiderProfile $profile): array
    {
        return [
            'id' => $profile->getKey(),
            'first_name' => $profile->first_name,
            'last_name' => $profile->last_name,
            'phone' => $profile->phone,
            'gender' => $profile->gender,
            'date_of_birth' => $profile->date_of_birth?->toDateString(),
            'address' => $profile->address,
            'city' => $profile->city,
            'state' => $profile->state,
            'profile_photo' => $profile->profile_photo,
            'license_number' => $profile->license_number,
            'application_status' => $this->enumValue($profile->application_status),
            'availability_status' => $this->enumValue($profile->availability_status),
            'approved_at' => $profile->approved_at?->toISOString(),
            'rejected_at' => $profile->rejected_at?->toISOString(),
            'rejection_reason' => $profile->rejection_reason,
        ];
    }

    private function bankPayload(RiderProfile $profile): array
    {
        return [
            'bank_name' => $profile->bank_name,
            'account_name' => $profile->bank_account_name,
            'account_number' => $profile->bank_account_number,
        ];
    }

    private function vehiclePayload(?Vehicle $vehicle): ?array
    {
        if (! $vehicle) {
            return null;
        }

        return [
            'id' => $vehicle->getKey(),
            'vehicle_type' => $this->enumValue($vehicle->vehicle_type),
            'brand' => $vehicle->brand,
            'model' => $vehicle->model,
            'color' => $vehicle->color,
            'plate_number' => $vehicle->plate_number,
            'registration_number' => $vehicle->registration_number,
            'vehicle_status' => $this->enumValue($vehicle->vehicle_status),
            'verification_status' => $this->enumValue($vehicle->verification_status),
        ];
    }

    private function enumValue(mixed $value): ?string
    {
        return $value instanceof \BackedEnum ? $value->value : $value;
    }

    private function filled(mixed $value): bool
    {
        if ($value instanceof \BackedEnum) {
            return trim((string) $value->value) !== '';
        }

        return trim((string) $value) !== '';
    }
}
