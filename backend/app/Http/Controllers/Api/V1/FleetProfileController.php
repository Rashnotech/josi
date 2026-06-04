<?php

namespace App\Http\Controllers\Api\V1;

use App\Enums\FleetDocumentType;
use App\Enums\VehicleStatus;
use App\Enums\VehicleType;
use App\Enums\VerificationStatus;
use App\Http\Controllers\Controller;
use App\Http\Responses\ApiResponse;
use App\Models\FleetDocument;
use App\Models\Vehicle;
use App\Services\RbacService;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class FleetProfileController extends Controller
{
    public function profile(Request $request, RbacService $rbacService)
    {
        return ApiResponse::success('Fleet profile fetched successfully', [
            'profile' => $rbacService->profileSummary($request->user()),
        ]);
    }

    public function update(Request $request, RbacService $rbacService)
    {
        $data = $request->validate([
            'business_name' => ['sometimes', 'string', 'max:255'],
            'business_email' => ['sometimes', 'nullable', 'email', 'max:255'],
            'business_phone' => ['sometimes', 'string', 'max:30'],
            'business_address' => ['sometimes', 'string', 'max:1000'],
            'city' => ['sometimes', 'string', 'max:100'],
            'state' => ['sometimes', 'string', 'max:100'],
            'registration_number' => ['sometimes', 'nullable', 'string', 'max:100'],
        ]);

        $request->user()->fleet?->update($data);

        return ApiResponse::success('Fleet profile updated successfully', [
            'profile' => $rbacService->profileSummary($request->user()->refresh()),
        ]);
    }

    public function applicationStatus(Request $request)
    {
        $fleet = $request->user()->fleet;

        return ApiResponse::success('Fleet application status fetched successfully', [
            'application_status' => $fleet?->application_status?->value,
            'rejection_reason' => $fleet?->rejection_reason,
        ]);
    }

    public function vehicles(Request $request)
    {
        return ApiResponse::success('Fleet vehicles fetched successfully', [
            'vehicles' => $request->user()->fleet?->vehicles()->latest()->get() ?? [],
        ]);
    }

    public function storeVehicle(Request $request)
    {
        $data = $request->validate([
            'vehicle_type' => ['required', Rule::in(VehicleType::values())],
            'brand' => ['nullable', 'string', 'max:100'],
            'model' => ['nullable', 'string', 'max:100'],
            'color' => ['nullable', 'string', 'max:50'],
            'plate_number' => ['required', 'string', 'max:50', 'unique:vehicles,plate_number'],
            'chassis_number' => ['nullable', 'string', 'max:100'],
            'engine_number' => ['nullable', 'string', 'max:100'],
        ]);

        $vehicle = Vehicle::create(array_merge($data, [
            'fleet_id' => $request->user()->fleet->getKey(),
            'vehicle_status' => VehicleStatus::Inactive,
            'verification_status' => VerificationStatus::Pending,
        ]));

        return ApiResponse::success('Fleet vehicle created successfully', [
            'vehicle' => $vehicle,
        ], 201);
    }

    public function documents(Request $request)
    {
        return ApiResponse::success('Fleet documents fetched successfully', [
            'documents' => $request->user()->fleet?->fleetDocuments()->latest()->get() ?? [],
        ]);
    }

    public function uploadDocument(Request $request)
    {
        $data = $request->validate([
            'document_type' => ['required', Rule::in(FleetDocumentType::values())],
            'document' => ['required', 'file', 'max:10240'],
        ]);

        $file = $data['document'];
        $path = $file->store('kyc/fleets', 'private');

        $document = FleetDocument::create([
            'fleet_id' => $request->user()->fleet->getKey(),
            'document_type' => $data['document_type'],
            'file_path' => $path,
            'original_file_name' => $file->getClientOriginalName(),
            'mime_type' => $file->getMimeType(),
            'file_size' => $file->getSize(),
        ]);

        return ApiResponse::success('Fleet document uploaded successfully', [
            'document' => $document,
        ], 201);
    }
}
