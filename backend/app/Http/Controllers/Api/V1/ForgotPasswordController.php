<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\Api\V1\Auth\ForgotPasswordRequest;
use App\Http\Requests\Api\V1\Auth\ResetPasswordRequest;
use App\Http\Requests\Api\V1\Auth\VerifyResetCodeRequest;
use App\Http\Responses\ApiResponse;
use App\Services\PasswordResetService;
use Illuminate\Validation\ValidationException;

class ForgotPasswordController extends Controller
{
    public function forgotPassword(ForgotPasswordRequest $request, PasswordResetService $passwordResetService)
    {
        $passwordResetService->requestReset($request->validated('identifier'));

        return ApiResponse::success('If this account exists, a password reset code has been sent.');
    }

    public function verifyResetCode(VerifyResetCodeRequest $request, PasswordResetService $passwordResetService)
    {
        try {
            $resetToken = $passwordResetService->verifyCode(
                $request->validated('identifier'),
                $request->validated('code')
            );

            return ApiResponse::success('Reset code verified successfully', [
                'reset_token' => $resetToken,
            ]);
        } catch (ValidationException $exception) {
            return ApiResponse::error('Invalid or expired reset code.', $exception->errors(), 422);
        }
    }

    public function resetPassword(ResetPasswordRequest $request, PasswordResetService $passwordResetService)
    {
        try {
            $passwordResetService->resetPassword(
                $request->validated('identifier'),
                $request->validated('reset_token'),
                $request->validated('password')
            );

            return ApiResponse::success('Password reset successful');
        } catch (ValidationException $exception) {
            return ApiResponse::error('Invalid or expired reset token.', $exception->errors(), 422);
        }
    }
}
