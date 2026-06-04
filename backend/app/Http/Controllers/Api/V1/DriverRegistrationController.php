<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\Api\V1\Auth\RegisterDriverRequest;
use App\Http\Responses\ApiResponse;
use App\Services\RegistrationService;

class DriverRegistrationController extends Controller
{
    public function __invoke(RegisterDriverRequest $request, RegistrationService $registrationService)
    {
        return ApiResponse::success(
            'Driver registration successful',
            $registrationService->registerDriver($request->validated()),
            201
        );
    }
}
