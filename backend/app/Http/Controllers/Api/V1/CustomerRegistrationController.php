<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\Api\V1\Auth\RegisterCustomerRequest;
use App\Http\Responses\ApiResponse;
use App\Services\RegistrationService;

class CustomerRegistrationController extends Controller
{
    public function __invoke(RegisterCustomerRequest $request, RegistrationService $registrationService)
    {
        return ApiResponse::success(
            'Customer registration successful',
            $registrationService->registerCustomer($request->validated()),
            201
        );
    }
}
