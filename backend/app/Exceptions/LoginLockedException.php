<?php

namespace App\Exceptions;

use RuntimeException;

class LoginLockedException extends RuntimeException
{
    public function __construct(private readonly int $secondsRemaining)
    {
        parent::__construct('Too many failed login attempts. Please try again in 5 minutes.');
    }

    public function secondsRemaining(): int
    {
        return $this->secondsRemaining;
    }
}
