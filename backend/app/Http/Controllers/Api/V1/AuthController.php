<?php

namespace App\Http\Controllers\Api\V1;

use App\Exceptions\LoginLockedException;
use App\Http\Controllers\Controller;
use App\Http\Requests\Api\V1\Auth\LoginRequest;
use App\Http\Requests\Api\V1\Auth\RegisterRequest;
use App\Http\Responses\ApiResponse;
use App\Services\AuthService;
use App\Services\RegistrationService;
use Illuminate\Auth\Access\AuthorizationException;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;
use Illuminate\Validation\Rules\Password;

class AuthController extends Controller
{
    public function register(RegisterRequest $request, RegistrationService $registrationService)
    {
        $payload = $registrationService->registerPublicAccount($request->validated());
        $message = $payload['message'];
        unset($payload['message']);

        return ApiResponse::success($message, $payload, 201);
    }

    public function login(LoginRequest $request, AuthService $authService)
    {
        try {
            return ApiResponse::success(
                'Login successful',
                $authService->login(
                    $request->validated('identifier'),
                    $request->validated('password'),
                    $request->ip()
                )
            );
        } catch (LoginLockedException $exception) {
            return ApiResponse::error($exception->getMessage(), [], 429);
        } catch (AuthorizationException $exception) {
            return ApiResponse::error($exception->getMessage(), [], 403);
        } catch (ValidationException $exception) {
            return ApiResponse::error('Invalid login credentials.', $exception->errors(), 401);
        }
    }

    public function logout(Request $request, AuthService $authService)
    {
        $authService->logout($request->user());

        return ApiResponse::success('Logout successful');
    }

    public function refresh(Request $request, AuthService $authService)
    {
        return ApiResponse::success(
            'Token refreshed successfully',
            $authService->refresh($request->user())
        );
    }

    public function me(Request $request, AuthService $authService)
    {
        return ApiResponse::success(
            'Authenticated user fetched successfully',
            $authService->me($request->user())
        );
    }

    public function changePassword(Request $request)
    {
        $data = $request->validate([
            'current_password' => ['required', 'string'],
            'password' => ['required', 'confirmed', Password::min(8)],
        ]);

        if (! Hash::check($data['current_password'], $request->user()->password)) {
            return ApiResponse::error('Current password is incorrect.', [
                'current_password' => ['Current password is incorrect.'],
            ], 422);
        }

        $request->user()->forceFill([
            'password' => Hash::make($data['password']),
        ])->save();

        return ApiResponse::success('Password updated successfully');
    }
}
