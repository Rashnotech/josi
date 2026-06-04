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
}
