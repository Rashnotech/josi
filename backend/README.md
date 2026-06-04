# Josi Backend Foundation

Laravel-compatible MVP backend foundation for Josi rider, fleet, customer, trip, pricing, cash payment, and admin approval operations.

This folder contains backend-only code. No Flutter, React, Filament resources, live tracking, WebSockets, push notifications, or automatic rider matching are implemented here.

## Models

`User`

- Fields: `name`, `email`, `phone`, `password`, `role`, `status`, `email_verified_at`, `remember_token`.
- Relationships: has one `riderProfile`, has one `fleet`, has many `trips` as customer, has many `auditLogs`.

`RiderProfile`

- Fields: `user_id`, `fleet_id`, names, phone, gender, DOB, address, city/state, profile photo path, license number, application approval/rejection fields, availability, current coordinates, location timestamp.
- Relationships: belongs to `user`, belongs to nullable `fleet`, has many `vehicles`, has many `riderDocuments`/`driverDocuments`, has many `trips`, has many `riderCashLedgers`.
- Note: the model is `RiderProfile`; foreign key columns that the product spec called driver-owned use `driver_profile_id`.

`Fleet`

- Fields: `user_id`, business contact/profile fields, registration number, application approval/rejection fields.
- Relationships: belongs to `user`, has many `riderProfiles`/`driverProfiles`, has many `vehicles`, has many `fleetDocuments`.

`Vehicle`

- Fields: `fleet_id`, `driver_profile_id`, type, brand/model/color, plate, chassis, engine, vehicle status, verification status.
- Relationships: belongs to nullable `fleet`, belongs to nullable `riderProfile`/`driverProfile`, has many `vehicleDocuments`, has many `trips`.

`RiderDocument`, `FleetDocument`, `VehicleDocument`

- Fields: owner FK, `document_type`, `file_path`, original file metadata, verification status, verifier, verification timestamp, rejection reason.
- Relationships: belongs to owner model, belongs to nullable verifier user.

`Zone` and `ZonePrice`

- `Zone` fields: name, city/state, description, center coordinates, radius, active flag.
- `ZonePrice` fields: pickup/destination zones, base price, cash/online flags, active flag.
- Relationships: zones expose pickup and destination prices; prices belong to pickup and destination zones.

`Trip`

- Fields: nullable customer/rider/vehicle, pickup/destination zones and addresses, coordinates, amount, payment method/status, trip status, lifecycle timestamps, cancellation reason.
- Relationships: belongs to nullable customer, nullable rider profile, nullable vehicle, pickup zone, destination zone; has one payment; has one rider cash ledger.

`Payment`

- Fields: trip, nullable user, amount, method/status, reference, gateway, JSON gateway response, paid/failed timestamps.
- Relationships: belongs to trip and nullable user.

`RiderCashLedger`

- Fields: driver profile, trip, collected amount, rider share, company share, amount to remit, amount remitted, remittance status, remitted timestamp, notes.
- Relationships: belongs to rider profile/driver profile and trip.

`AuditLog`

- Fields: nullable actor, action, nullable morph target, JSON old/new values, IP, user agent.
- Relationships: belongs to nullable user, morphs to auditable model.

## Enums

Required enums live in `app/Enums`:

- `UserRole`, `UserStatus`
- `ApplicationStatus`, `AvailabilityStatus`, `VerificationStatus`
- `VehicleType`, `VehicleStatus`
- `PaymentMethod`, `PaymentStatus`, `TripStatus`, `RemittanceStatus`

Document type enums are also included: `RiderDocumentType`, `FleetDocumentType`, `VehicleDocumentType`.

## Services

Business logic skeletons live in `app/Services`:

- `DriverApprovalService`
- `FleetApprovalService`
- `DocumentVerificationService`
- `PricingService`
- `TripService`
- `PaymentService`
- `CashLedgerService`
- `AuditLogService`

Controllers and API endpoints should call these services later. Do not move approval, pricing, payment verification, or cash ledger mutation logic into controllers.

## Business Rules

- Riders do not control pricing. Admin-controlled `zone_prices` determine trip amount.
- Same-zone and cross-zone prices are separate records.
- `PricingService::quote()` throws `ActiveZonePriceNotFoundException` when no active price exists.
- Frontend payment status is not trusted.
- Online payments are marked paid only through `PaymentService::markVerifiedPaid()` after backend verification.
- Cash payments are marked collected only from completed cash trips.
- Completed cash trips create a `rider_cash_ledgers` row through `CashLedgerService`.
- Rider cash ledger rows are admin-operated; riders should not be allowed to edit them.
- KYC files store paths and metadata only. Raw files belong in private storage.
- Sensitive admin actions should create `audit_logs` rows.

## Seed Data

`database/seeders/JosiMvpSeeder.php` creates:

- One super admin: `superadmin@josi.test`
- One admin: `admin@josi.test`
- One pack owner: `fleet.owner@josi.test`
- One rider: `rider@josi.test`
- One customer: `customer@josi.test`
- One approved fleet, rider profile, verified vehicle, KYC documents, Lagos zones, zone prices, sample trips, payment records, and a sample rider cash ledger.

The seed password defaults to `password`; set `JOSI_SEED_PASSWORD` before seeding in any shared environment.

## Suggested Implementation Order

1. Install or scaffold the full Laravel app runtime around this backend folder if it is not present yet.
2. Run migrations and seed `JosiMvpSeeder`.
3. Add Form Requests for rider, fleet, document, trip, payment, and remittance commands.
4. Add policies for ownership and admin-only actions.
5. Add REST controllers that call the service classes.
6. Add Filament resources using the models and enums.
7. Add payment gateway adapters behind `PaymentService`.
8. Add periodic evals for onboarding approval, pricing, payment reconciliation, and cash remittance flows.

## Local Validation

PHP and Composer were not available on this machine when this foundation was created. The current gate and eval scripts are deterministic static checks:

```powershell
powershell -ExecutionPolicy Bypass -File tests\Architecture\CoreBackendFoundationTest.ps1
powershell -ExecutionPolicy Bypass -File evals\CoreBackendBusinessRulesEval.ps1
```

After PHP/Composer are installed and a full Laravel runtime exists, add PHPUnit or Pest tests for migrations, model relationships, service transitions, pricing failures, and cash ledger creation.

## Auth API

The authentication and API access layer is documented in `docs/auth-api.md`.

## Database Setup

MySQL/MariaDB setup, cPanel deployment notes, migration commands, seeders, and the database health check are documented in `docs/database-setup.md`.
