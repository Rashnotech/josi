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

        $data = $request->validate([
            'name' => ['sometimes', 'string', 'max:150'],
            'email' => ['sometimes', 'email', 'max:255', Rule::unique('users', 'email')->ignore($user->getKey())],
            'phone' => ['sometimes', 'string', 'max:30', Rule::unique('users', 'phone')->ignore($user->getKey())],
            'gender' => ['sometimes', 'nullable', 'string', 'max:50'],
        ]);

        $user->update($data);

        return ApiResponse::success('Customer profile updated successfully', [
            'user' => $rbacService->userSummary($user->refresh()),
        ]);
    }
}
