<?php

use App\Enums\RemittanceStatus;
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('rider_cash_ledgers', function (Blueprint $table) {
            $table->id();
            $table->foreignId('driver_profile_id')->constrained('rider_profiles')->restrictOnDelete();
            $table->foreignId('trip_id')->unique()->constrained()->restrictOnDelete();
            $table->decimal('amount_collected', 12, 2);
            $table->decimal('rider_share', 12, 2);
            $table->decimal('company_share', 12, 2);
            $table->decimal('amount_to_remit', 12, 2);
            $table->decimal('amount_remitted', 12, 2)->default(0);
            $table->string('remittance_status')->default(RemittanceStatus::Pending->value)->index();
            $table->timestamp('remitted_at')->nullable();
            $table->text('notes')->nullable();
            $table->timestamps();

            $table->index(['driver_profile_id', 'remittance_status']);
            $table->index('trip_id');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('rider_cash_ledgers');
    }
};
