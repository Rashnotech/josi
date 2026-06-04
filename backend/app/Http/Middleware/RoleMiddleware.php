<?php

namespace App\Http\Middleware;

use App\Http\Responses\ApiResponse;
use App\Services\RbacService;
use Closure;
use Illuminate\Http\Request;

class RoleMiddleware
{
    public function __construct(private readonly RbacService $rbacService)
    {
    }

    public function handle(Request $request, Closure $next, string ...$roles)
    {
        if (! $request->user() || ! $this->rbacService->userHasAnyRole($request->user(), $roles)) {
            return ApiResponse::error('Forbidden.', [], 403);
        }

        return $next($request);
    }
}
