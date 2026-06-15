<?php

namespace App\Http\Controllers;

use App\Enums\UserRole;
use App\Models\User;
use App\Services\RbacService;
use Illuminate\Http\Request;
use Laravel\Sanctum\PersonalAccessToken;

class DashboardController extends Controller
{
    public function __construct(private readonly RbacService $rbacService)
    {
    }

    public function __invoke(Request $request)
    {
        $user = $this->resolveUser($request);

        if (! $user) {
            return response()->view('dashboard.index', [
                'status' => 'unauthenticated',
                'title' => 'Dashboard sign in required',
                'user' => null,
                'cards' => [],
                'loginUrl' => config('app.web_login_url', '/login'),
            ], 401);
        }

        if (! $this->canViewDashboard($user)) {
            return response()->view('dashboard.index', [
                'status' => 'forbidden',
                'title' => 'Unauthorized dashboard',
                'user' => $user,
                'cards' => [],
                'loginUrl' => config('app.web_login_url', '/login'),
            ], 403);
        }

        return view('dashboard.index', [
            'status' => 'ready',
            'title' => $this->titleFor($user),
            'user' => $user,
            'cards' => $this->cardsFor($user),
            'loginUrl' => config('app.web_login_url', '/login'),
        ]);
    }

    private function resolveUser(Request $request): ?User
    {
        $token = $request->bearerToken() ?: $request->cookie('josi_auth_token');

        if (! $token) {
            return null;
        }

        $accessToken = PersonalAccessToken::findToken($token);

        if (! $accessToken || ! ($accessToken->tokenable instanceof User)) {
            return null;
        }

        return $accessToken->tokenable->refresh()->load('fleet');
    }

    private function canViewDashboard(User $user): bool
    {
        return $this->rbacService->userHasAnyRole($user, [
            UserRole::SuperAdmin->value,
            UserRole::Admin->value,
            UserRole::PackOwner->value,
            UserRole::FleetOwner->value,
        ]);
    }

    private function titleFor(User $user): string
    {
        return match ($this->rbacService->roleValue($user)) {
            UserRole::SuperAdmin->value => 'Super admin dashboard',
            UserRole::Admin->value => 'Admin dashboard',
            UserRole::PackOwner->value,
            UserRole::FleetOwner->value => 'Pack owner dashboard',
            default => 'Josi dashboard',
        };
    }

    /**
     * @return array<int, array{label: string, value: string, description: string}>
     */
    private function cardsFor(User $user): array
    {
        return match ($this->rbacService->roleValue($user)) {
            UserRole::SuperAdmin->value => [
                ['label' => 'Users', 'value' => 'All roles', 'description' => 'Manage super admins, admins, riders, couriers, customers, and pack owners.'],
                ['label' => 'Operations', 'value' => 'Platform wide', 'description' => 'Review fleets, vehicles, trips, pricing, documents, and payments.'],
                ['label' => 'System', 'value' => 'Settings', 'description' => 'Future Filament resources for configuration, audit logs, and reports.'],
            ],
            UserRole::Admin->value => [
                ['label' => 'Applications', 'value' => 'Review queue', 'description' => 'Review rider, courier, vehicle, and pack owner submissions.'],
                ['label' => 'Trips', 'value' => 'Operations', 'description' => 'Monitor trips, payments, and cash-ledger activity.'],
                ['label' => 'Documents', 'value' => 'Verification', 'description' => 'Approve or reject uploaded documents with audit trails.'],
            ],
            UserRole::PackOwner->value,
            UserRole::FleetOwner->value => [
                ['label' => 'Pack vehicles', 'value' => (string) ($user->fleet?->vehicle_count ?? 'Pending'), 'description' => 'Add bikes, cars, vans, and other pack vehicles.'],
                ['label' => 'Pack riders', 'value' => 'Coming soon', 'description' => 'Invite riders and review their onboarding status.'],
                ['label' => 'Reports', 'value' => 'Coming soon', 'description' => 'Track pack trips, earnings, payouts, and performance.'],
            ],
            default => [],
        };
    }
}
