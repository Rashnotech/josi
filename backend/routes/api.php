<?php

use App\Http\Controllers\Api\V1\AdminUserController;
use App\Http\Controllers\Api\V1\AuthController;
use App\Http\Controllers\Api\V1\CustomerAddressController;
use App\Http\Controllers\Api\V1\CustomerProfileController;
use App\Http\Controllers\Api\V1\CustomerRegistrationController;
use App\Http\Controllers\Api\V1\CustomerTripController;
use App\Http\Controllers\Api\V1\DriverProfileController;
use App\Http\Controllers\Api\V1\DriverTripController;
use App\Http\Controllers\Api\V1\DriverRegistrationController;
use App\Http\Controllers\Api\V1\FleetProfileController;
use App\Http\Controllers\Api\V1\FleetRegistrationController;
use App\Http\Controllers\Api\V1\ForgotPasswordController;
use Illuminate\Support\Facades\Route;

Route::prefix('v1')->group(function () {
    Route::prefix('auth')->group(function () {
        Route::post('/register', [AuthController::class, 'register']);
        Route::post('/register/driver', DriverRegistrationController::class);
        Route::post('/register/fleet', FleetRegistrationController::class);
        Route::post('/register/customer', CustomerRegistrationController::class);

        Route::post('/login', [AuthController::class, 'login'])->middleware('throttle:10,1');

        Route::post('/forgot-password', [ForgotPasswordController::class, 'forgotPassword'])->middleware('throttle:5,1');
        Route::post('/verify-reset-code', [ForgotPasswordController::class, 'verifyResetCode'])->middleware('throttle:10,1');
        Route::post('/reset-password', [ForgotPasswordController::class, 'resetPassword'])->middleware('throttle:10,1');

        Route::middleware(['jwt.auth', 'active'])->group(function () {
            Route::post('/logout', [AuthController::class, 'logout']);
            Route::post('/refresh', [AuthController::class, 'refresh']);
            Route::get('/me', [AuthController::class, 'me']);
            Route::post('/change-password', [AuthController::class, 'changePassword']);
        });
    });

    Route::prefix('driver')->middleware(['jwt.auth', 'active', 'role:rider,courier,driver'])->group(function () {
        Route::get('/profile', [DriverProfileController::class, 'profile']);
        Route::put('/profile', [DriverProfileController::class, 'update'])->middleware('permission:update_profile');
        Route::get('/application-status', [DriverProfileController::class, 'applicationStatus'])->middleware('permission:view_application_status');
        Route::get('/trips', [DriverTripController::class, 'index'])->middleware('permission:view_assigned_trips');
        Route::get('/trips/{trip}', [DriverTripController::class, 'show'])->middleware('permission:view_assigned_trips');
        Route::post('/trips/{trip}/accept', [DriverTripController::class, 'accept'])->middleware('permission:view_assigned_trips');
        Route::post('/trips/{trip}/arrived', [DriverTripController::class, 'arrived'])->middleware('permission:view_assigned_trips');
        Route::get('/onboarding', [DriverProfileController::class, 'onboarding'])->middleware('permission:view_application_status');
        Route::post('/onboarding/profile-picture', [DriverProfileController::class, 'saveProfilePicture'])->middleware('permission:update_profile');
        Route::post('/onboarding/bank-account', [DriverProfileController::class, 'saveBankAccount'])->middleware('permission:update_profile');
        Route::post('/onboarding/riding-details', [DriverProfileController::class, 'saveRidingDetails'])->middleware('permission:update_profile');
        Route::post('/onboarding/submit', [DriverProfileController::class, 'submitOnboarding'])->middleware('permission:update_profile');
        Route::post('/documents', [DriverProfileController::class, 'uploadDocument'])->middleware('permission:upload_documents');
        Route::get('/documents', [DriverProfileController::class, 'documents'])->middleware('permission:upload_documents');
    });

    Route::prefix('fleet')->middleware(['jwt.auth', 'active', 'role:pack_owner,fleet_owner'])->group(function () {
        Route::get('/profile', [FleetProfileController::class, 'profile']);
        Route::put('/profile', [FleetProfileController::class, 'update'])->middleware('permission:update_own_fleet');
        Route::get('/application-status', [FleetProfileController::class, 'applicationStatus'])->middleware('permission:view_fleet_application_status');
        Route::post('/vehicles', [FleetProfileController::class, 'storeVehicle'])->middleware('permission:manage_own_vehicles');
        Route::get('/vehicles', [FleetProfileController::class, 'vehicles'])->middleware('permission:manage_own_vehicles');
        Route::post('/documents', [FleetProfileController::class, 'uploadDocument'])->middleware('permission:upload_fleet_documents');
        Route::get('/documents', [FleetProfileController::class, 'documents'])->middleware('permission:upload_fleet_documents');
    });

    Route::prefix('customer')->middleware(['jwt.auth', 'active', 'role:customer'])->group(function () {
        Route::get('/profile', [CustomerProfileController::class, 'profile']);
        Route::put('/profile', [CustomerProfileController::class, 'update'])->middleware('permission:update_profile');
        Route::get('/addresses', [CustomerAddressController::class, 'index'])->middleware('permission:view_profile');
        Route::post('/addresses', [CustomerAddressController::class, 'store'])->middleware('permission:update_profile');
        Route::get('/trips', [CustomerTripController::class, 'index'])->middleware('permission:view_own_trips');
        Route::post('/trips', [CustomerTripController::class, 'store'])->middleware('permission:create_trip');
        Route::get('/trips/{trip}', [CustomerTripController::class, 'show'])->middleware('permission:view_own_trips');
        Route::get('/trips/{trip}/available-riders', [CustomerTripController::class, 'availableRiders'])->middleware('permission:create_trip');
        Route::post('/trips/{trip}/request-rider', [CustomerTripController::class, 'requestRider'])->middleware('permission:create_trip');
        Route::post('/trips/{trip}/review', [CustomerTripController::class, 'review'])->middleware('permission:view_own_trips');
    });

    Route::prefix('admin')->middleware(['jwt.auth', 'active', 'role:admin,super_admin'])->group(function () {
        Route::get('/users', [AdminUserController::class, 'users'])->middleware('permission:manage_all_users');
        Route::post('/users/create-admin', [AdminUserController::class, 'createAdmin'])->middleware(['role:super_admin', 'permission:manage_admins']);
        Route::get('/drivers', [AdminUserController::class, 'drivers'])->middleware('permission:manage_drivers');
        Route::get('/fleets', [AdminUserController::class, 'fleets'])->middleware('permission:manage_fleets');
        Route::get('/vehicles', [AdminUserController::class, 'vehicles'])->middleware('permission:manage_vehicles');
        Route::get('/documents', [AdminUserController::class, 'documents'])->middleware('permission:manage_documents');
    });
});
