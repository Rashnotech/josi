<?php

namespace App\Http\Middleware;

use App\Http\Responses\ApiResponse;
use App\Services\RbacService;
use Closure;
use Illuminate\Http\Request;

class PermissionMiddleware
{
    public function __construct(private readonly RbacService $rbacService)
    {
    }

    public function handle(Request $request, Closure $next, string ...$permissions)
    {
        $user = $request->user();

        foreach ($permissions as $permission) {
            if (! $user || ! $this->rbacService->userHasPermission($user, $permission)) {
                return ApiResponse::error('Forbidden.', [], 403);
            }
        }

        return $next($request);
    }
}
