<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\Api\V1\Auth\VerifyEmailCodeRequest;
use App\Http\Responses\ApiResponse;
use App\Services\EmailVerificationService;
use Illuminate\Http\Request;
use Illuminate\Validation\ValidationException;

class EmailVerificationController extends Controller
{
    public function verify(VerifyEmailCodeRequest $request, EmailVerificationService $emailVerificationService)
    {
        try {
            $emailVerificationService->verifyCode($request->user(), $request->validated('code'));

            return ApiResponse::success('Email verified successfully', [
                'email_verified' => true,
            ]);
        } catch (ValidationException $exception) {
            return ApiResponse::error('Invalid or expired verification code.', $exception->errors(), 422);
        }
    }

    public function resend(Request $request, EmailVerificationService $emailVerificationService)
    {
        try {
            $emailVerificationService->resendVerificationCode($request->user());

            return ApiResponse::success('Verification code sent.');
        } catch (ValidationException $exception) {
            return ApiResponse::error(
                collect($exception->errors())->collapse()->first() ?? 'Unable to send verification code.',
                $exception->errors(),
                422
            );
        }
    }
}
