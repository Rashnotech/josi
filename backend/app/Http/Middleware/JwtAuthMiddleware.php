<?php

namespace App\Http\Middleware;

use App\Http\Responses\ApiResponse;
use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class JwtAuthMiddleware
{
    public function handle(Request $request, Closure $next)
    {
        $user = $request->user('sanctum') ?? Auth::guard('sanctum')->user();

        if (! $user) {
            return ApiResponse::error('Unauthenticated.', [], 401);
        }

        $request->setUserResolver(fn () => $user);

        return $next($request);
    }
}
