<?php

namespace App\Services;

use App\Enums\UserStatus;
use App\Exceptions\LoginLockedException;
use App\Models\User;
use Illuminate\Auth\Access\AuthorizationException;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

class AuthService
{
    public function __construct(
        private readonly JwtTokenService $tokenService,
        private readonly LoginAttemptService $loginAttemptService,
        private readonly RbacService $rbacService
    ) {
    }

    public function login(string $identifier, string $password, string $ipAddress): array
    {
        if ($this->loginAttemptService->tooManyAttempts($identifier, $ipAddress)) {
            throw new LoginLockedException(
                $this->loginAttemptService->availableIn($identifier, $ipAddress)
            );
        }

        $user = $this->findUserByIdentifier($identifier);

        if (! $user || ! Hash::check($password, $user->password)) {
            $this->loginAttemptService->hit($identifier, $ipAddress);

            throw ValidationException::withMessages([
                'identifier' => ['Invalid login credentials.'],
            ]);
        }

        if ($this->enumValue($user->status) !== UserStatus::Active->value) {
            throw new AuthorizationException('Your account is not active.');
        }

        $this->loginAttemptService->clear($identifier, $ipAddress);

        return DB::transaction(function () use ($user) {
            $user->forceFill(['last_login_at' => now()])->save();

            return array_merge(
                $this->tokenService->issueToken($user->refresh()),
                $this->rbacService->authPayload($user)
            );
        });
    }

    public function logout(User $user): void
    {
        $this->tokenService->revokeCurrentToken($user);
    }

    public function refresh(User $user): array
    {
        return array_merge(
            $this->tokenService->refresh($user),
            $this->rbacService->authPayload($user->refresh())
        );
    }

    public function me(User $user): array
    {
        return $this->rbacService->authPayload($user);
    }

    public function findUserByIdentifier(string $identifier): ?User
    {
        return User::query()
            ->where('email', $identifier)
            ->orWhere('phone', $identifier)
            ->first();
    }

    private function enumValue(mixed $value): ?string
    {
        return $value instanceof \BackedEnum ? $value->value : $value;
    }
}
