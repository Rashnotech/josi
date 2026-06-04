<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('zone_prices', function (Blueprint $table) {
            $table->id();
            $table->foreignId('pickup_zone_id')->constrained('zones')->cascadeOnDelete();
            $table->foreignId('destination_zone_id')->constrained('zones')->cascadeOnDelete();
            $table->decimal('base_price', 12, 2);
            $table->boolean('cash_allowed')->default(true)->index();
            $table->boolean('online_payment_allowed')->default(true)->index();
            $table->boolean('is_active')->default(true)->index();
            $table->timestamps();

            $table->index(['pickup_zone_id', 'destination_zone_id', 'is_active']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('zone_prices');
    }
};
