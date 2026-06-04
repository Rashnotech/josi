<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\Api\V1\Auth\RegisterFleetRequest;
use App\Http\Responses\ApiResponse;
use App\Services\RegistrationService;

class FleetRegistrationController extends Controller
{
    public function __invoke(RegisterFleetRequest $request, RegistrationService $registrationService)
    {
        return ApiResponse::success(
            'Fleet registration successful',
            $registrationService->registerFleet($request->validated()),
            201
        );
    }
}
