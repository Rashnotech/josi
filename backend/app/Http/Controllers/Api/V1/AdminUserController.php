<?php

namespace App\Http\Controllers\Api\V1;

use App\Enums\UserRole;
use App\Http\Controllers\Controller;
use App\Http\Requests\Api\V1\Admin\CreateAdminRequest;
use App\Http\Responses\ApiResponse;
use App\Models\Fleet;
use App\Models\FleetDocument;
use App\Models\RiderDocument;
use App\Models\RiderProfile;
use App\Models\User;
use App\Models\Vehicle;
use App\Models\VehicleDocument;
use App\Services\RbacService;
use App\Services\RegistrationService;

class AdminUserController extends Controller
{
    public function users(RbacService $rbacService)
    {
        return ApiResponse::success('Users fetched successfully', [
            'users' => User::query()
                ->latest()
                ->limit(50)
                ->get()
                ->map(fn (User $user) => $rbacService->userSummary($user))
                ->values(),
        ]);
    }

    public function createAdmin(CreateAdminRequest $request, RegistrationService $registrationService, RbacService $rbacService)
    {
        $admin = $registrationService->createAdmin($request->validated(), $request->user());

        return ApiResponse::success('Admin user created successfully', [
            'user' => $rbacService->userSummary($admin),
            'role' => UserRole::Admin->value,
            'permissions' => $rbacService->permissionsForUser($admin),
        ], 201);
    }

    public function drivers()
    {
        return ApiResponse::success('Drivers fetched successfully', [
            'drivers' => RiderProfile::query()->with('user')->latest()->limit(50)->get(),
        ]);
    }

    public function fleets()
    {
        return ApiResponse::success('Fleets fetched successfully', [
            'fleets' => Fleet::query()->with('user')->latest()->limit(50)->get(),
        ]);
    }

    public function vehicles()
    {
        return ApiResponse::success('Vehicles fetched successfully', [
            'vehicles' => Vehicle::query()->with(['fleet', 'riderProfile'])->latest()->limit(50)->get(),
        ]);
    }

    public function documents()
    {
        return ApiResponse::success('Documents fetched successfully', [
            'rider_documents' => RiderDocument::query()->latest()->limit(50)->get(),
            'fleet_documents' => FleetDocument::query()->latest()->limit(50)->get(),
            'vehicle_documents' => VehicleDocument::query()->latest()->limit(50)->get(),
        ]);
    }
}
