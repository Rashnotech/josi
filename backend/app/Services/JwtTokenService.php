<?php

namespace App\Services;

use App\Models\User;

class JwtTokenService
{
    public function __construct(private readonly RbacService $rbacService)
    {
    }

    public function issueToken(User $user, string $tokenName = 'josi-api'): array
    {
        $expiresAt = now()->addSeconds($this->expiresIn());
        $token = $user->createToken(
            $tokenName,
            $this->rbacService->permissionsForUser($user),
            $expiresAt
        );

        return [
            'token' => $token->plainTextToken,
            'access_token' => $token->plainTextToken,
            'token_type' => 'bearer',
            'expires_in' => $this->expiresIn(),
            'expires_at' => $expiresAt->toISOString(),
        ];
    }

    public function refresh(User $user): array
    {
        $this->revokeCurrentToken($user);

        return $this->issueToken($user);
    }

    public function revokeCurrentToken(User $user): void
    {
        $token = $user->currentAccessToken();

        if ($token) {
            $token->delete();
        }
    }

    public function expiresIn(): int
    {
        $minutes = config('sanctum.expiration', 60);

        return $minutes ? (int) $minutes * 60 : 3600;
    }
}
