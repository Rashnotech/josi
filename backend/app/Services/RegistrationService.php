<?php

namespace App\Services;

use App\Enums\ApplicationStatus;
use App\Enums\UserRole;
use App\Enums\UserStatus;
use App\Models\Fleet;
use App\Models\RiderProfile;
use App\Models\User;
use Illuminate\Auth\Access\AuthorizationException;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;

class RegistrationService
{
    public function __construct(
        private readonly JwtTokenService $tokenService,
        private readonly RbacService $rbacService,
        private readonly NotificationService $notificationService,
        private readonly AuditLogService $auditLogService
    ) {
    }

    public function registerPublicAccount(array $data): array
    {
        $role = UserRole::from($data['role']);

        return DB::transaction(function () use ($data, $role) {
            $user = User::create([
                'name' => $data['name'],
                'email' => $data['email'],
                'phone' => $data['phone'],
                'password' => Hash::make($data['password']),
                'role' => $role,
                'status' => UserStatus::Active,
            ]);

            $profile = match ($role) {
                UserRole::Rider,
                UserRole::Courier => $this->createRiderOrCourierProfile($user, $data),
                UserRole::PackOwner => $this->createPackOwnerFleet($user, $data),
                default => null,
            };

            $this->rbacService->syncUserRole($user);
            $this->notificationService->sendAccountCreated(
                $user,
                $role->requiresDashboard() ? null : ApplicationStatus::Pending->value
            );
            $this->auditLogService->log('auth.public_registered', null, $profile ?? $user, [], [
                'user_id' => $user->getKey(),
                'role' => $role->value,
                'application_status' => $role->requiresDashboard() ? null : ApplicationStatus::Pending->value,
            ]);

            $user = $user->refresh()->load(['riderProfile', 'fleet']);
            $payload = $role->requiresDashboard()
                ? [
                    'user' => $this->rbacService->userSummary($user),
                    'role' => $role->value,
                    'redirect_to' => '/login',
                    'requires_dashboard' => true,
                    'login_required' => true,
                    'approval_status' => null,
                ]
                : array_merge(
                    $this->authResponse($user),
                    [
                        'approval_status' => ApplicationStatus::Pending->value,
                        'login_required' => false,
                    ]
                );

            $payload['message'] = $role->requiresDashboard()
                ? 'Account created successfully. Please sign in to access your dashboard.'
                : 'Account created successfully. Continue your rider account setup.';

            return $payload;
        });
    }

    public function registerDriver(array $data): array
    {
        return DB::transaction(function () use ($data) {
            $user = User::create([
                'name' => $data['name'],
                'email' => $data['email'],
                'phone' => $data['phone'],
                'password' => Hash::make($data['password']),
                'role' => UserRole::Driver,
                'status' => UserStatus::Active,
            ]);

            $profile = RiderProfile::create([
                'user_id' => $user->getKey(),
                'first_name' => $data['first_name'],
                'last_name' => $data['last_name'],
                'phone' => $data['phone'],
                'address' => $data['address'],
                'city' => $data['city'],
                'state' => $data['state'],
                'application_status' => ApplicationStatus::Pending,
            ]);

            $this->rbacService->syncUserRole($user);
            $this->notificationService->sendAccountCreated($user, ApplicationStatus::Pending->value);
            $this->auditLogService->log('auth.driver_registered', null, $profile, [], [
                'user_id' => $user->getKey(),
                'application_status' => ApplicationStatus::Pending->value,
            ]);

            return $this->authResponse($user->refresh()->load('riderProfile'));
        });
    }

    public function registerFleet(array $data): array
    {
        return DB::transaction(function () use ($data) {
            $user = User::create([
                'name' => $data['name'],
                'email' => $data['email'],
                'phone' => $data['phone'],
                'password' => Hash::make($data['password']),
                'role' => UserRole::FleetOwner,
                'status' => UserStatus::Active,
            ]);

            $fleet = Fleet::create([
                'user_id' => $user->getKey(),
                'business_name' => $data['business_name'],
                'business_email' => $data['business_email'] ?? null,
                'business_phone' => $data['business_phone'],
                'business_address' => $data['business_address'],
                'city' => $data['city'],
                'state' => $data['state'],
                'registration_number' => $data['registration_number'] ?? null,
                'application_status' => ApplicationStatus::Pending,
            ]);

            $this->rbacService->syncUserRole($user);
            $this->notificationService->sendAccountCreated($user, ApplicationStatus::Pending->value);
            $this->auditLogService->log('auth.fleet_registered', null, $fleet, [], [
                'user_id' => $user->getKey(),
                'application_status' => ApplicationStatus::Pending->value,
            ]);

            return $this->authResponse($user->refresh()->load('fleet'));
        });
    }

    public function registerCustomer(array $data): array
    {
        return DB::transaction(function () use ($data) {
            $user = User::create([
                'name' => $data['name'],
                'email' => $data['email'],
                'phone' => $data['phone'],
                'password' => Hash::make($data['password']),
                'role' => UserRole::Customer,
                'status' => UserStatus::Active,
            ]);

            $this->rbacService->syncUserRole($user);
            $this->notificationService->sendAccountCreated($user);
            $this->auditLogService->log('auth.customer_registered', null, $user, [], [
                'user_id' => $user->getKey(),
            ]);

            return $this->authResponse($user->refresh());
        });
    }

    public function createAdmin(array $data, User $actor): User
    {
        if (! $this->rbacService->userHasPermission($actor, 'manage_admins')) {
            throw new AuthorizationException('Only a super admin can create admin users.');
        }

        return DB::transaction(function () use ($data, $actor) {
            $user = User::create([
                'name' => $data['name'],
                'email' => $data['email'],
                'phone' => $data['phone'],
                'password' => Hash::make($data['password']),
                'role' => UserRole::Admin,
                'status' => UserStatus::Active,
            ]);

            $this->rbacService->syncUserRole($user);
            $this->notificationService->sendAccountCreated($user);
            $this->auditLogService->log('admin.user_created', $actor, $user, [], [
                'created_user_id' => $user->getKey(),
                'role' => UserRole::Admin->value,
            ]);

            return $user->refresh();
        });
    }

    private function authResponse(User $user): array
    {
        return array_merge(
            $this->tokenService->issueToken($user),
            $this->rbacService->authPayload($user)
        );
    }

    private function createRiderOrCourierProfile(User $user, array $data): RiderProfile
    {
        return RiderProfile::create([
            'user_id' => $user->getKey(),
            'first_name' => $data['first_name'],
            'last_name' => $data['last_name'] ?? '',
            'phone' => $data['phone'],
            'address' => $data['address'] ?? 'Pending onboarding',
            'city' => $data['city'] ?? 'Pending onboarding',
            'state' => $data['state'] ?? 'Pending onboarding',
            'application_status' => ApplicationStatus::Pending,
        ]);
    }

    private function createPackOwnerFleet(User $user, array $data): Fleet
    {
        return Fleet::create([
            'user_id' => $user->getKey(),
            'business_name' => $data['business_name'] ?? $data['name']."'s pack",
            'business_email' => $data['business_email'] ?? $data['email'],
            'business_phone' => $data['business_phone'] ?? $data['phone'],
            'business_address' => $data['business_address'] ?? $data['address'] ?? 'Pending onboarding',
            'vehicle_count' => $data['vehicle_count'] ?? null,
            'city' => $data['city'] ?? 'Pending onboarding',
            'state' => $data['state'] ?? 'Pending onboarding',
            'registration_number' => $data['registration_number'] ?? null,
            'application_status' => ApplicationStatus::Pending,
        ]);
    }
}
