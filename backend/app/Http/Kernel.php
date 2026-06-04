<?php

namespace App\Http;

use App\Http\Middleware\EnsureDriverIsApproved;
use App\Http\Middleware\EnsureFleetIsApproved;
use App\Http\Middleware\EnsureUserIsActive;
use App\Http\Middleware\JwtAuthMiddleware;
use App\Http\Middleware\PermissionMiddleware;
use App\Http\Middleware\RoleMiddleware;
use Illuminate\Foundation\Http\Kernel as HttpKernel;

class Kernel extends HttpKernel
{
    protected $middlewareAliases = [
        'jwt.auth' => JwtAuthMiddleware::class,
        'active' => EnsureUserIsActive::class,
        'role' => RoleMiddleware::class,
        'permission' => PermissionMiddleware::class,
        'approved.driver' => EnsureDriverIsApproved::class,
        'approved.fleet' => EnsureFleetIsApproved::class,
    ];
}
