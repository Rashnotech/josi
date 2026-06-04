<?php

use App\Http\Controllers\Api\V1\AdminUserController;
use App\Http\Controllers\Api\V1\AuthController;
use App\Http\Controllers\Api\V1\CustomerProfileController;
use App\Http\Controllers\Api\V1\CustomerRegistrationController;
use App\Http\Controllers\Api\V1\DriverProfileController;
use App\Http\Controllers\Api\V1\DriverRegistrationController;
use App\Http\Controllers\Api\V1\FleetProfileController;
use App\Http\Controllers\Api\V1\FleetRegistrationController;
use App\Http\Controllers\Api\V1\ForgotPasswordController;
use Illuminate\Support\Facades\Route;

Route::prefix('v1')->group(function () {
    Route::prefix('auth')->group(function () {
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
        });
    });

    Route::prefix('driver')->middleware(['jwt.auth', 'active', 'role:driver'])->group(function () {
        Route::get('/profile', [DriverProfileController::class, 'profile']);
        Route::put('/profile', [DriverProfileController::class, 'update'])->middleware('permission:update_profile');
        Route::get('/application-status', [DriverProfileController::class, 'applicationStatus'])->middleware('permission:view_application_status');
        Route::post('/documents', [DriverProfileController::class, 'uploadDocument'])->middleware('permission:upload_documents');
        Route::get('/documents', [DriverProfileController::class, 'documents'])->middleware('permission:upload_documents');
    });

    Route::prefix('fleet')->middleware(['jwt.auth', 'active', 'role:fleet_owner'])->group(function () {
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
