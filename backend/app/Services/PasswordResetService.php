<?php

namespace App\Services;

use App\Models\User;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;
use Illuminate\Validation\ValidationException;

class PasswordResetService
{
    private const CODE_EXPIRES_MINUTES = 10;
    private const RESEND_COOLDOWN_SECONDS = 60;
    private const MAX_CODE_ATTEMPTS = 5;

    public function __construct(
        private readonly NotificationService $notificationService,
        private readonly AuditLogService $auditLogService
    ) {
    }

    public function requestReset(string $identifier): void
    {
        $user = $this->findUserByIdentifier($identifier);

        if (! $user || $this->isInResendCooldown($user)) {
            return;
        }

        $code = str_pad((string) random_int(0, 999999), 6, '0', STR_PAD_LEFT);
        $expiresAt = now()->addMinutes(self::CODE_EXPIRES_MINUTES);

        $user->forceFill([
            'password_reset_code' => Hash::make($code),
            'password_reset_code_expires_at' => $expiresAt,
            'password_reset_verified_at' => null,
            'password_reset_token' => null,
            'password_reset_code_attempts' => 0,
            'password_reset_sent_at' => now(),
        ])->save();

        $this->notificationService->sendPasswordResetCode($user, $code, $expiresAt);
    }

    public function verifyCode(string $identifier, string $code): string
    {
        $user = $this->findUserByIdentifier($identifier);

        if (! $user || ! $this->hasUsableResetCode($user)) {
            throw $this->invalidCodeException();
        }

        if ((int) $user->password_reset_code_attempts >= self::MAX_CODE_ATTEMPTS) {
            throw $this->invalidCodeException();
        }

        if (! Hash::check($code, (string) $user->password_reset_code)) {
            $user->increment('password_reset_code_attempts');

            throw $this->invalidCodeException();
        }

        $resetToken = Str::random(64);

        $user->forceFill([
            'password_reset_verified_at' => now(),
            'password_reset_token' => hash('sha256', $resetToken),
        ])->save();

        return $resetToken;
    }

    public function resetPassword(string $identifier, string $resetToken, string $password): void
    {
        $user = $this->findUserByIdentifier($identifier);

        if (! $user || ! $this->hasValidResetToken($user, $resetToken)) {
            throw ValidationException::withMessages([
                'reset_token' => ['Invalid or expired reset token.'],
            ]);
        }

        DB::transaction(function () use ($user, $password) {
            $user->forceFill([
                'password' => Hash::make($password),
                'password_reset_code' => null,
                'password_reset_code_expires_at' => null,
                'password_reset_verified_at' => null,
                'password_reset_token' => null,
                'password_reset_code_attempts' => 0,
                'password_reset_sent_at' => null,
            ])->save();

            $this->auditLogService->log('auth.password_reset', $user, $user);
            $this->notificationService->sendPasswordResetSuccessful($user);
        });
    }

    private function findUserByIdentifier(string $identifier): ?User
    {
        return User::query()
            ->where('email', $identifier)
            ->orWhere('phone', $identifier)
            ->first();
    }

    private function isInResendCooldown(User $user): bool
    {
        return $user->password_reset_sent_at
            && $user->password_reset_sent_at->greaterThan(now()->subSeconds(self::RESEND_COOLDOWN_SECONDS));
    }

    private function hasUsableResetCode(User $user): bool
    {
        return $user->password_reset_code
            && $user->password_reset_code_expires_at
            && $user->password_reset_code_expires_at->isFuture();
    }

    private function hasValidResetToken(User $user, string $resetToken): bool
    {
        return $user->password_reset_token
            && hash_equals((string) $user->password_reset_token, hash('sha256', $resetToken))
            && $user->password_reset_verified_at
            && $user->password_reset_code_expires_at
            && $user->password_reset_code_expires_at->isFuture();
    }

    private function invalidCodeException(): ValidationException
    {
        return ValidationException::withMessages([
            'code' => ['Invalid or expired reset code.'],
        ]);
    }
}
