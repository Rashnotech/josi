<?php

use App\Enums\ApplicationStatus;
use App\Enums\AvailabilityStatus;
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('rider_profiles', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->unique()->constrained()->cascadeOnDelete();
            $table->foreignId('fleet_id')->nullable()->constrained()->nullOnDelete();
            $table->string('first_name');
            $table->string('last_name');
            $table->string('phone')->index();
            $table->string('gender')->nullable();
            $table->date('date_of_birth')->nullable();
            $table->text('address');
            $table->string('city')->index();
            $table->string('state')->index();
            $table->string('profile_photo')->nullable();
            $table->string('license_number')->nullable()->index();
            $table->string('application_status')->default(ApplicationStatus::Pending->value)->index();
            $table->timestamp('approved_at')->nullable();
            $table->timestamp('rejected_at')->nullable();
            $table->text('rejection_reason')->nullable();
            $table->string('availability_status')->default(AvailabilityStatus::Offline->value)->index();
            $table->decimal('current_latitude', 11, 8)->nullable();
            $table->decimal('current_longitude', 11, 8)->nullable();
            $table->timestamp('last_location_updated_at')->nullable()->index();
            $table->timestamps();

            $table->index(['fleet_id', 'application_status']);
            $table->index(['city', 'state']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('rider_profiles');
    }
};
