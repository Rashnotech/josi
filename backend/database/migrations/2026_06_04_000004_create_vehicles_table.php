<?php

use App\Enums\VehicleStatus;
use App\Enums\VehicleType;
use App\Enums\VerificationStatus;
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('vehicles', function (Blueprint $table) {
            $table->id();
            $table->foreignId('fleet_id')->nullable()->constrained()->nullOnDelete();
            $table->foreignId('driver_profile_id')->nullable()->constrained('rider_profiles')->nullOnDelete();
            $table->string('vehicle_type')->default(VehicleType::Motorcycle->value)->index();
            $table->string('brand')->nullable();
            $table->string('model')->nullable();
            $table->string('color')->nullable();
            $table->string('plate_number')->unique();
            $table->string('chassis_number')->nullable()->index();
            $table->string('engine_number')->nullable()->index();
            $table->string('vehicle_status')->default(VehicleStatus::Inactive->value)->index();
            $table->string('verification_status')->default(VerificationStatus::Pending->value)->index();
            $table->timestamps();

            $table->index(['fleet_id', 'vehicle_status']);
            $table->index(['driver_profile_id', 'vehicle_status']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('vehicles');
    }
};
