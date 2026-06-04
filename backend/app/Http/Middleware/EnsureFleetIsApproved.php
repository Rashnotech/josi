<?php

namespace App\Http\Middleware;

use App\Enums\ApplicationStatus;
use App\Http\Responses\ApiResponse;
use Closure;
use Illuminate\Http\Request;

class EnsureFleetIsApproved
{
    public function handle(Request $request, Closure $next)
    {
        $status = $request->user()?->fleet?->application_status;
        $status = $status instanceof \BackedEnum ? $status->value : $status;

        if ($status !== ApplicationStatus::Approved->value) {
            return ApiResponse::error('Fleet account is not approved.', [], 403);
        }

        return $next($request);
    }
}
