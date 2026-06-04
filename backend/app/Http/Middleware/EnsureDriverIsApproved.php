<?php

namespace App\Http\Middleware;

use App\Enums\ApplicationStatus;
use App\Http\Responses\ApiResponse;
use Closure;
use Illuminate\Http\Request;

class EnsureDriverIsApproved
{
    public function handle(Request $request, Closure $next)
    {
        $status = $request->user()?->riderProfile?->application_status;
        $status = $status instanceof \BackedEnum ? $status->value : $status;

        if ($status !== ApplicationStatus::Approved->value) {
            return ApiResponse::error('Driver account is not approved.', [], 403);
        }

        return $next($request);
    }
}
