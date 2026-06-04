<?php

namespace App\Http\Middleware;

use App\Enums\UserStatus;
use App\Http\Responses\ApiResponse;
use Closure;
use Illuminate\Http\Request;

class EnsureUserIsActive
{
    public function handle(Request $request, Closure $next)
    {
        $status = $request->user()?->status;
        $status = $status instanceof \BackedEnum ? $status->value : $status;

        if ($status !== UserStatus::Active->value) {
            return ApiResponse::error('Your account is not active.', [], 403);
        }

        return $next($request);
    }
}
