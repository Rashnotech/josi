<?php

namespace App\Services;

use App\Models\User;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

class EmailVerificationService
{
    private const CODE_EXPIRES_MINUTES = 15;
    private const RESEND_COOLDOWN_SECONDS = 60;
    private const MAX_CODE_ATTEMPTS = 5;

    public function __construct(
        private readonly NotificationService $notificationService,
        private readonly AuditLogService $auditLogService
    ) {
    }

    /**
     * Sends the first verification code right after registration. Silently
     * no-ops when already verified or still within the resend cooldown so
     * registration never fails because of this side effect.
     */
    public function sendVerificationCode(User $user): void
    {
        if ($user->hasVerifiedEmail() || $this->isInResendCooldown($user)) {
            return;
        }

        $this->issueCode($user);
    }

    /**
     * Explicit user-triggered resend. Unlike sendVerificationCode(), this
     * throws a clear, user-facing error instead of silently no-oping so the
     * mobile "Resend code" button can surface why nothing was sent.
     */
    public function resendVerificationCode(User $user): void
    {
        if ($user->hasVerifiedEmail()) {
            throw ValidationException::withMessages([
                'code' => ['Your email is already verified.'],
            ]);
        }

        if ($this->isInResendCooldown($user)) {
            throw ValidationException::withMessages([
                'code' => ['Please wait before requesting another code.'],
            ]);
        }

        $this->issueCode($user);
    }

    public function verifyCode(User $user, string $code): void
    {
        if ($user->hasVerifiedEmail()) {
            return;
        }

        if (! $this->hasUsableCode($user)) {
            throw $this->invalidCodeException();
        }

        if ((int) $user->email_verification_code_attempts >= self::MAX_CODE_ATTEMPTS) {
            throw $this->invalidCodeException();
        }

        if (! Hash::check($code, (string) $user->email_verification_code)) {
            $user->increment('email_verification_code_attempts');

            throw $this->invalidCodeException();
        }

        $user->forceFill([
            'email_verified_at' => now(),
            'email_verification_code' => null,
            'email_verification_code_expires_at' => null,
            'email_verification_code_attempts' => 0,
            'email_verification_sent_at' => null,
        ])->save();

        $this->auditLogService->log('auth.email_verified', null, $user, [], [
            'user_id' => $user->getKey(),
        ]);
    }

    private function issueCode(User $user): void
    {
        $code = str_pad((string) random_int(0, 999999), 6, '0', STR_PAD_LEFT);
        $expiresAt = now()->addMinutes(self::CODE_EXPIRES_MINUTES);

        $user->forceFill([
            'email_verification_code' => Hash::make($code),
            'email_verification_code_expires_at' => $expiresAt,
            'email_verification_code_attempts' => 0,
            'email_verification_sent_at' => now(),
        ])->save();

        $this->notificationService->sendEmailVerificationCode($user, $code, $expiresAt);
    }

    private function isInResendCooldown(User $user): bool
    {
        return $user->email_verification_sent_at
            && $user->email_verification_sent_at->greaterThan(now()->subSeconds(self::RESEND_COOLDOWN_SECONDS));
    }

    private function hasUsableCode(User $user): bool
    {
        return $user->email_verification_code
            && $user->email_verification_code_expires_at
            && $user->email_verification_code_expires_at->isFuture();
    }

    private function invalidCodeException(): ValidationException
    {
        return ValidationException::withMessages([
            'code' => ['Invalid or expired verification code.'],
        ]);
    }
}
