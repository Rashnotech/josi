<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Responses\ApiResponse;
use App\Services\RbacService;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class CustomerProfileController extends Controller
{
    public function profile(Request $request, RbacService $rbacService)
    {
        return ApiResponse::success('Customer profile fetched successfully', [
            'user' => $rbacService->userSummary($request->user()),
        ]);
    }

    public function update(Request $request, RbacService $rbacService)
    {
        $user = $request->user();

        // Email is intentionally not accepted here: it's the account
        // identifier tied to OTP verification, so it can't be changed from
        // this endpoint. Any 'email' field in the request body is ignored.
        $data = $request->validate([
            'name' => ['sometimes', 'string', 'max:150'],
            'phone' => ['sometimes', 'string', 'max:30', Rule::unique('users', 'phone')->ignore($user->getKey())],
            'gender' => ['sometimes', 'nullable', 'string', 'max:50'],
        ]);

        $user->update($data);

        return ApiResponse::success('Customer profile updated successfully', [
            'user' => $rbacService->userSummary($user->refresh()),
        ]);
    }
}
