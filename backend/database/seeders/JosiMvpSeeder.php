<?php

namespace Database\Seeders;

use App\Enums\ApplicationStatus;
use App\Enums\AvailabilityStatus;
use App\Enums\FleetDocumentType;
use App\Enums\PaymentMethod;
use App\Enums\PaymentStatus;
use App\Enums\RemittanceStatus;
use App\Enums\RiderDocumentType;
use App\Enums\TripStatus;
use App\Enums\UserRole;
use App\Enums\UserStatus;
use App\Enums\VehicleDocumentType;
use App\Enums\VehicleStatus;
use App\Enums\VehicleType;
use App\Enums\VerificationStatus;
use App\Models\Fleet;
use App\Models\FleetDocument;
use App\Models\Payment;
use App\Models\RiderCashLedger;
use App\Models\RiderDocument;
use App\Models\RiderProfile;
use App\Models\Trip;
use App\Models\User;
use App\Models\Vehicle;
use App\Models\VehicleDocument;
use App\Models\Zone;
use App\Models\ZonePrice;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class JosiMvpSeeder extends Seeder
{
    public function run(): void
    {
        $password = Hash::make(env('JOSI_SEED_PASSWORD', 'password'));

        $superAdmin = $this->seedUser(
            'superadmin@josi.test',
            'Josi Super Admin',
            UserRole::SuperAdmin,
            $password,
            '+2348000000001'
        );

        $admin = $this->seedUser(
            'admin@josi.test',
            'Josi Admin',
            UserRole::Admin,
            $password,
            '+2348000000002'
        );

        $fleetOwner = $this->seedUser(
            'fleet.owner@josi.test',
            'Mainland Pack Owner',
            UserRole::PackOwner,
            $password,
            '+2348000000003'
        );

        $driverUser = $this->seedUser(
            'rider@josi.test',
            'Ayo Rider',
            UserRole::Rider,
            $password,
            '+2348000000004'
        );

        $customer = $this->seedUser(
            'customer@josi.test',
            'Josi Customer',
            UserRole::Customer,
            $password,
            '+2348000000005'
        );

        $fleet = Fleet::query()->updateOrCreate(
            ['user_id' => $fleetOwner->getKey()],
            [
                'business_name' => 'Mainland Express Pack',
                'business_email' => 'operations@mainlandexpress.test',
                'business_phone' => '+2348000001000',
                'business_address' => '12 Allen Avenue, Ikeja',
                'city' => 'Lagos',
                'state' => 'Lagos',
                'registration_number' => 'BN-1002003',
                'application_status' => ApplicationStatus::Approved,
                'approved_at' => now(),
                'rejected_at' => null,
                'rejection_reason' => null,
            ]
        );

        $riderProfile = RiderProfile::query()->updateOrCreate(
            ['user_id' => $driverUser->getKey()],
            [
                'fleet_id' => $fleet->getKey(),
                'first_name' => 'Ayo',
                'last_name' => 'Balogun',
                'phone' => '+2348000000004',
                'gender' => 'male',
                'date_of_birth' => '1994-04-16',
                'address' => '9 Toyin Street, Ikeja',
                'city' => 'Lagos',
                'state' => 'Lagos',
                'profile_photo' => null,
                'license_number' => 'DL-00998877',
                'application_status' => ApplicationStatus::Approved,
                'approved_at' => now(),
                'rejected_at' => null,
                'rejection_reason' => null,
                'availability_status' => AvailabilityStatus::Offline,
                'current_latitude' => null,
                'current_longitude' => null,
                'last_location_updated_at' => null,
            ]
        );

        $vehicle = Vehicle::query()->updateOrCreate(
            ['plate_number' => 'JOS-123AB'],
            [
                'fleet_id' => $fleet->getKey(),
                'driver_profile_id' => $riderProfile->getKey(),
                'vehicle_type' => VehicleType::Motorcycle,
                'brand' => 'Bajaj',
                'model' => 'Boxer',
                'color' => 'Black',
                'chassis_number' => 'CHS100200300',
                'engine_number' => 'ENG100200300',
                'vehicle_status' => VehicleStatus::Active,
                'verification_status' => VerificationStatus::Verified,
            ]
        );

        $this->seedDocuments($admin, $fleet, $riderProfile, $vehicle);

        $ikeja = $this->seedZone('Ikeja', 6.6018, 3.3515, 'Mainland commercial and residential zone.');
        $yaba = $this->seedZone('Yaba', 6.5158, 3.3899, 'Technology and education corridor.');
        $lekki = $this->seedZone('Lekki', 6.4698, 3.5852, 'Island residential and business zone.');

        $this->seedZonePrice($ikeja, $ikeja, 1800);
        $this->seedZonePrice($ikeja, $yaba, 3500);
        $this->seedZonePrice($yaba, $lekki, 5200);
        $this->seedZonePrice($lekki, $ikeja, 6500);

        $requestedTrip = Trip::query()->firstOrCreate(
            [
                'customer_id' => $customer->getKey(),
                'pickup_address' => 'Jibowu Bus Terminal',
                'destination_address' => 'University of Lagos Main Gate',
            ],
            [
                'pickup_zone_id' => $yaba->getKey(),
                'destination_zone_id' => $yaba->getKey(),
                'amount' => 1800,
                'payment_method' => PaymentMethod::Cash,
                'payment_status' => PaymentStatus::Pending,
                'trip_status' => TripStatus::Requested,
                'requested_at' => now(),
            ]
        );

        Payment::query()->updateOrCreate(
            ['trip_id' => $requestedTrip->getKey()],
            [
                'user_id' => $customer->getKey(),
                'amount' => $requestedTrip->amount,
                'payment_method' => PaymentMethod::Cash,
                'payment_status' => PaymentStatus::Pending,
            ]
        );

        $completedTrip = Trip::query()->firstOrCreate(
            [
                'customer_id' => $customer->getKey(),
                'pickup_address' => 'Computer Village, Ikeja',
                'destination_address' => 'Yaba Market',
            ],
            [
                'driver_profile_id' => $riderProfile->getKey(),
                'vehicle_id' => $vehicle->getKey(),
                'pickup_zone_id' => $ikeja->getKey(),
                'destination_zone_id' => $yaba->getKey(),
                'pickup_latitude' => 6.5965,
                'pickup_longitude' => 3.3421,
                'destination_latitude' => 6.5172,
                'destination_longitude' => 3.3841,
                'amount' => 3500,
                'payment_method' => PaymentMethod::Cash,
                'payment_status' => PaymentStatus::CashCollected,
                'trip_status' => TripStatus::Completed,
                'requested_at' => now()->subHour(),
                'accepted_at' => now()->subMinutes(55),
                'started_at' => now()->subMinutes(45),
                'completed_at' => now()->subMinutes(20),
            ]
        );

        Payment::query()->updateOrCreate(
            ['trip_id' => $completedTrip->getKey()],
            [
                'user_id' => $customer->getKey(),
                'amount' => $completedTrip->amount,
                'payment_method' => PaymentMethod::Cash,
                'payment_status' => PaymentStatus::CashCollected,
                'paid_at' => $completedTrip->completed_at,
            ]
        );

        RiderCashLedger::query()->updateOrCreate(
            ['trip_id' => $completedTrip->getKey()],
            [
                'driver_profile_id' => $riderProfile->getKey(),
                'amount_collected' => 3500,
                'rider_share' => 2450,
                'company_share' => 1050,
                'amount_to_remit' => 1050,
                'amount_remitted' => 0,
                'remittance_status' => RemittanceStatus::Pending,
                'remitted_at' => null,
                'notes' => 'Sample pending cash remittance.',
            ]
        );

        $superAdmin->auditLogs()->create([
            'action' => 'seed.mvp_foundation',
            'new_values' => [
                'city' => 'Lagos',
                'admin_user_id' => $admin->getKey(),
                'fleet_id' => $fleet->getKey(),
                'rider_profile_id' => $riderProfile->getKey(),
            ],
        ]);
    }

    private function seedUser(string $email, string $name, UserRole $role, string $password, string $phone): User
    {
        return User::query()->updateOrCreate(
            ['email' => $email],
            [
                'name' => $name,
                'phone' => $phone,
                'password' => $password,
                'role' => $role,
                'status' => UserStatus::Active,
                'email_verified_at' => now(),
            ]
        );
    }

    private function seedZone(string $name, float $latitude, float $longitude, string $description): Zone
    {
        return Zone::query()->updateOrCreate(
            ['name' => $name, 'city' => 'Lagos', 'state' => 'Lagos'],
            [
                'description' => $description,
                'latitude' => $latitude,
                'longitude' => $longitude,
                'radius_km' => 7.5,
                'is_active' => true,
            ]
        );
    }

    private function seedZonePrice(Zone $pickupZone, Zone $destinationZone, float $basePrice): ZonePrice
    {
        return ZonePrice::query()->updateOrCreate(
            [
                'pickup_zone_id' => $pickupZone->getKey(),
                'destination_zone_id' => $destinationZone->getKey(),
            ],
            [
                'base_price' => $basePrice,
                'cash_allowed' => true,
                'online_payment_allowed' => true,
                'is_active' => true,
            ]
        );
    }

    private function seedDocuments(User $admin, Fleet $fleet, RiderProfile $riderProfile, Vehicle $vehicle): void
    {
        FleetDocument::query()->updateOrCreate(
            ['fleet_id' => $fleet->getKey(), 'document_type' => FleetDocumentType::BusinessRegistration->value],
            [
                'file_path' => 'kyc/fleets/business_registration/mainland-express.pdf',
                'original_file_name' => 'business_registration.pdf',
                'mime_type' => 'application/pdf',
                'file_size' => 450000,
                'verification_status' => VerificationStatus::Verified,
                'verified_by' => $admin->getKey(),
                'verified_at' => now(),
            ]
        );

        RiderDocument::query()->updateOrCreate(
            ['driver_profile_id' => $riderProfile->getKey(), 'document_type' => RiderDocumentType::DriverLicense->value],
            [
                'file_path' => 'kyc/riders/driver_license/ayo-balogun.jpg',
                'original_file_name' => 'driver_license.jpg',
                'mime_type' => 'image/jpeg',
                'file_size' => 320000,
                'verification_status' => VerificationStatus::Verified,
                'verified_by' => $admin->getKey(),
                'verified_at' => now(),
            ]
        );

        VehicleDocument::query()->updateOrCreate(
            ['vehicle_id' => $vehicle->getKey(), 'document_type' => VehicleDocumentType::VehicleLicense->value],
            [
                'file_path' => 'kyc/vehicles/vehicle_license/jos-123ab.pdf',
                'original_file_name' => 'vehicle_license.pdf',
                'mime_type' => 'application/pdf',
                'file_size' => 210000,
                'verification_status' => VerificationStatus::Verified,
                'verified_by' => $admin->getKey(),
                'verified_at' => now(),
            ]
        );
    }
}
