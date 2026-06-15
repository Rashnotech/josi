<?php

namespace App\Providers;

use App\Models\AuditLog;
use App\Models\Fleet;
use App\Models\FleetDocument;
use App\Models\Payment;
use App\Models\Permission;
use App\Models\RiderCashLedger;
use App\Models\RiderDocument;
use App\Models\RiderProfile;
use App\Models\Role;
use App\Models\Trip;
use App\Models\User;
use App\Models\Vehicle;
use App\Models\VehicleDocument;
use App\Models\Zone;
use App\Models\ZonePrice;
use App\Policies\AuditLogPolicy;
use App\Policies\FleetDocumentPolicy;
use App\Policies\FleetPolicy;
use App\Policies\PaymentPolicy;
use App\Policies\RiderCashLedgerPolicy;
use App\Policies\RiderDocumentPolicy;
use App\Policies\RiderProfilePolicy;
use App\Policies\RolePolicy;
use App\Policies\TripPolicy;
use App\Policies\UserPolicy;
use App\Policies\VehicleDocumentPolicy;
use App\Policies\VehiclePolicy;
use App\Policies\ZonePolicy;
use App\Policies\ZonePricePolicy;
use Illuminate\Foundation\Support\Providers\AuthServiceProvider as ServiceProvider;

class AuthServiceProvider extends ServiceProvider
{
    protected $policies = [
        AuditLog::class => AuditLogPolicy::class,
        Fleet::class => FleetPolicy::class,
        FleetDocument::class => FleetDocumentPolicy::class,
        Payment::class => PaymentPolicy::class,
        Permission::class => RolePolicy::class,
        RiderCashLedger::class => RiderCashLedgerPolicy::class,
        RiderDocument::class => RiderDocumentPolicy::class,
        RiderProfile::class => RiderProfilePolicy::class,
        Role::class => RolePolicy::class,
        Trip::class => TripPolicy::class,
        User::class => UserPolicy::class,
        Vehicle::class => VehiclePolicy::class,
        VehicleDocument::class => VehicleDocumentPolicy::class,
        Zone::class => ZonePolicy::class,
        ZonePrice::class => ZonePricePolicy::class,
    ];
}
