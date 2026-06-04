<?php

namespace App\Services;

use Illuminate\Support\Facades\RateLimiter;
use Illuminate\Support\Str;

class LoginAttemptService
{
    public const MAX_ATTEMPTS = 5;
    public const DECAY_SECONDS = 300;

    public function tooManyAttempts(string $identifier, string $ipAddress): bool
    {
        return RateLimiter::tooManyAttempts($this->key($identifier, $ipAddress), self::MAX_ATTEMPTS);
    }

    public function hit(string $identifier, string $ipAddress): void
    {
        RateLimiter::hit($this->key($identifier, $ipAddress), self::DECAY_SECONDS);
    }

    public function clear(string $identifier, string $ipAddress): void
    {
        RateLimiter::clear($this->key($identifier, $ipAddress));
    }

    public function availableIn(string $identifier, string $ipAddress): int
    {
        return RateLimiter::availableIn($this->key($identifier, $ipAddress));
    }

    private function key(string $identifier, string $ipAddress): string
    {
        return 'login:'.Str::lower(trim($identifier)).'|'.$ipAddress;
    }
}
