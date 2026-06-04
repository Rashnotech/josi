<?php

namespace App\Http\Controllers\Api\V1;

use App\Enums\RiderDocumentType;
use App\Http\Controllers\Controller;
use App\Http\Responses\ApiResponse;
use App\Models\RiderDocument;
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
