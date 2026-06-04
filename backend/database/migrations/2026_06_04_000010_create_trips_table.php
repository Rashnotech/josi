<?php

use App\Enums\PaymentMethod;
use App\Enums\PaymentStatus;
use App\Enums\TripStatus;
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('trips', function (Blueprint $table) {
            $table->id();
            $table->foreignId('customer_id')->nullable()->constrained('users')->nullOnDelete();
            $table->foreignId('driver_profile_id')->nullable()->constrained('rider_profiles')->nullOnDelete();
            $table->foreignId('vehicle_id')->nullable()->constrained()->nullOnDelete();
            $table->foreignId('pickup_zone_id')->constrained('zones')->restrictOnDelete();
            $table->foreignId('destination_zone_id')->constrained('zones')->restrictOnDelete();
            $table->text('pickup_address');
            $table->decimal('pickup_latitude', 11, 8)->nullable();
            $table->decimal('pickup_longitude', 11, 8)->nullable();
            $table->text('destination_address');
            $table->decimal('destination_latitude', 11, 8)->nullable();
            $table->decimal('destination_longitude', 11, 8)->nullable();
            $table->decimal('amount', 12, 2);
            $table->string('payment_method')->default(PaymentMethod::Cash->value)->index();
            $table->string('payment_status')->default(PaymentStatus::Pending->value)->index();
            $table->string('trip_status')->default(TripStatus::Requested->value)->index();
            $table->timestamp('requested_at')->useCurrent()->index();
            $table->timestamp('accepted_at')->nullable();
            $table->timestamp('started_at')->nullable();
            $table->timestamp('completed_at')->nullable();
            $table->timestamp('cancelled_at')->nullable();
            $table->text('cancellation_reason')->nullable();
            $table->timestamps();

            $table->index(['customer_id', 'trip_status']);
            $table->index(['driver_profile_id', 'trip_status']);
            $table->index(['pickup_zone_id', 'destination_zone_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('trips');
    }
};
