<?php

namespace App\Http;

use App\Http\Middleware\EnsureDriverIsApproved;
use App\Http\Middleware\EnsureFleetIsApproved;
use App\Http\Middleware\EnsureUserIsActive;
use App\Http\Middleware\JwtAuthMiddleware;
use App\Http\Middleware\PermissionMiddleware;
use App\Http\Middleware\RoleMiddleware;
use Illuminate\Auth\Middleware\Authenticate;
use Illuminate\Auth\Middleware\AuthenticateWithBasicAuth;
use Illuminate\Auth\Middleware\Authorize;
use Illuminate\Foundation\Http\Kernel as HttpKernel;
use Illuminate\Foundation\Http\Middleware\ConvertEmptyStringsToNull;
use Illuminate\Foundation\Http\Middleware\InvokeDeferredCallbacks;
use Illuminate\Foundation\Http\Middleware\PreventRequestsDuringMaintenance;
use Illuminate\Foundation\Http\Middleware\TrimStrings;
use Illuminate\Foundation\Http\Middleware\ValidatePostSize;
use Illuminate\Http\Middleware\HandleCors;
use Illuminate\Routing\Middleware\SubstituteBindings;
use Illuminate\Routing\Middleware\ThrottleRequests;
use Illuminate\Session\Middleware\AuthenticateSession;
use Illuminate\View\Middleware\ShareErrorsFromSession;
use Illuminate\Cookie\Middleware\AddQueuedCookiesToResponse;
use Illuminate\Cookie\Middleware\EncryptCookies;
use Illuminate\Foundation\Http\Middleware\VerifyCsrfToken;
use Illuminate\Routing\Middleware\ValidateSignature;
use Illuminate\Auth\Middleware\EnsureEmailIsVerified;

class Kernel extends HttpKernel
{
    protected $middleware = [
        HandleCors::class,
        PreventRequestsDuringMaintenance::class,
        ValidatePostSize::class,
        TrimStrings::class,
        ConvertEmptyStringsToNull::class,
        // Invokes defer()'d callbacks after the response is sent. Without this,
        // every NotificationService::sendAfterResponse() call (account created,
        // password reset code, email verification code) silently never fires,
        // because Laravel only runs a deferred callback's owning middleware's
        // terminate() hook, and this app defines its own Kernel middleware
        // list instead of the framework's default bootstrap/app.php stack.
        InvokeDeferredCallbacks::class,
    ];

    protected $middlewareGroups = [
        'web' => [
            EncryptCookies::class,
            AddQueuedCookiesToResponse::class,
            \Illuminate\Session\Middleware\StartSession::class,
            AuthenticateSession::class,
            ShareErrorsFromSession::class,
            VerifyCsrfToken::class,
            SubstituteBindings::class,
        ],

        'api' => [
            'throttle:api',
            SubstituteBindings::class,
        ],
    ];

    protected $middlewareAliases = [
        'auth' => Authenticate::class,
        'auth.basic' => AuthenticateWithBasicAuth::class,
        'auth.session' => AuthenticateSession::class,
        'can' => Authorize::class,
        'signed' => ValidateSignature::class,
        'throttle' => ThrottleRequests::class,
        'verified' => EnsureEmailIsVerified::class,
        'jwt.auth' => JwtAuthMiddleware::class,
        'active' => EnsureUserIsActive::class,
        'role' => RoleMiddleware::class,
        'permission' => PermissionMiddleware::class,
        'approved.driver' => EnsureDriverIsApproved::class,
        'approved.fleet' => EnsureFleetIsApproved::class,
    ];
}
