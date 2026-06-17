<?php

namespace App\Http\Controllers\Api\V1;

use App\Enums\VehicleType;
use App\Enums\RiderDocumentType;
use App\Http\Controllers\Controller;
use App\Http\Responses\ApiResponse;
use App\Models\RiderDocument;
use App\Services\DriverOnboardingService;
use App\Services\RbacService;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class DriverProfileController extends Controller
{
    public function profile(Request $request, RbacService $rbacService)
    {
        return ApiResponse::success('Driver profile fetched successfully', [
            'profile' => $rbacService->profileSummary($request->user()),
        ]);
    }

    public function update(Request $request, RbacService $rbacService)
    {
        $data = $request->validate([
            'first_name' => ['sometimes', 'string', 'max:100'],
            'last_name' => ['sometimes', 'string', 'max:100'],
            'gender' => ['sometimes', 'nullable', 'string', 'max:50'],
            'date_of_birth' => ['sometimes', 'nullable', 'date'],
            'address' => ['sometimes', 'string', 'max:1000'],
            'city' => ['sometimes', 'string', 'max:100'],
            'state' => ['sometimes', 'string', 'max:100'],
            'profile_photo' => ['sometimes', 'nullable', 'string', 'max:2048'],
            'bank_name' => ['sometimes', 'nullable', 'string', 'max:100'],
            'bank_account_name' => ['sometimes', 'nullable', 'string', 'max:150'],
            'bank_account_number' => ['sometimes', 'nullable', 'string', 'max:30'],
            'license_number' => ['sometimes', 'nullable', 'string', 'max:100'],
        ]);

        $request->user()->riderProfile?->update($data);

        return ApiResponse::success('Driver profile updated successfully', [
            'profile' => $rbacService->profileSummary($request->user()->refresh()),
        ]);
    }

    public function applicationStatus(Request $request)
    {
        $profile = $request->user()->riderProfile;

        return ApiResponse::success('Driver application status fetched successfully', [
            'application_status' => $profile?->application_status?->value,
            'rejection_reason' => $profile?->rejection_reason,
        ]);
    }

    public function onboarding(Request $request, DriverOnboardingService $onboardingService)
    {
        return ApiResponse::success('Driver onboarding fetched successfully', $onboardingService->snapshot($request->user()));
    }

    public function saveProfilePicture(Request $request, DriverOnboardingService $onboardingService)
    {
        $data = $request->validate([
            'profile_photo' => ['required', 'string', 'max:2048'],
        ]);

        return ApiResponse::success('Profile picture saved successfully', $onboardingService->saveProfilePicture($request->user(), $data));
    }

    public function saveBankAccount(Request $request, DriverOnboardingService $onboardingService)
    {
        $data = $request->validate([
            'bank_name' => ['required', 'string', 'max:100'],
            'account_name' => ['required', 'string', 'max:150'],
            'account_number' => ['required', 'string', 'max:30'],
        ]);

        return ApiResponse::success('Bank account details saved successfully', $onboardingService->saveBankAccount($request->user(), $data));
    }

    public function saveRidingDetails(Request $request, DriverOnboardingService $onboardingService)
    {
        $vehicleId = $request->user()->riderProfile?->vehicles()->oldest()->value('id');
        $data = $request->validate([
            'vehicle_type' => ['required', Rule::in(VehicleType::values())],
            'brand' => ['required', 'string', 'max:100'],
            'model' => ['required', 'string', 'max:100'],
            'color' => ['required', 'string', 'max:80'],
            'plate_number' => ['required', 'string', 'max:50', Rule::unique('vehicles', 'plate_number')->ignore($vehicleId)],
            'registration_number' => ['nullable', 'string', 'max:100'],
            'license_number' => ['nullable', 'string', 'max:100'],
            'city' => ['nullable', 'string', 'max:100'],
            'state' => ['nullable', 'string', 'max:100'],
        ]);

        return ApiResponse::success('Riding details saved successfully', $onboardingService->saveRidingDetails($request->user(), $data));
    }

    public function submitOnboarding(Request $request, DriverOnboardingService $onboardingService)
    {
        return ApiResponse::success('Rider account information submitted successfully', $onboardingService->submit($request->user()));
    }

    public function documents(Request $request)
    {
        return ApiResponse::success('Driver documents fetched successfully', [
            'documents' => $request->user()->riderProfile?->riderDocuments()->latest()->get() ?? [],
        ]);
    }

    public function uploadDocument(Request $request)
    {
        $data = $request->validate([
            'document_type' => ['required', Rule::in(RiderDocumentType::values())],
            'document' => ['required', 'file', 'max:10240'],
        ]);

        $file = $data['document'];
        $path = $file->store('kyc/riders', 'private');

        $document = RiderDocument::create([
            'driver_profile_id' => $request->user()->riderProfile->getKey(),
            'document_type' => $data['document_type'],
            'file_path' => $path,
            'original_file_name' => $file->getClientOriginalName(),
            'mime_type' => $file->getMimeType(),
            'file_size' => $file->getSize(),
        ]);

        return ApiResponse::success('Driver document uploaded successfully', [
            'document' => $document,
        ], 201);
    }
}
