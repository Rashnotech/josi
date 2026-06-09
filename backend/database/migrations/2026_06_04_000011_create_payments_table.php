<?php

use App\Enums\PaymentMethod;
use App\Enums\PaymentStatus;
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('payments', function (Blueprint $table) {
            $table->id();
            $table->foreignId('trip_id')->unique()->constrained()->cascadeOnDelete();
            $table->foreignId('user_id')->nullable()->constrained()->nullOnDelete();
            $table->decimal('amount', 12, 2);
            $table->string('payment_method')->default(PaymentMethod::Cash->value)->index();
            $table->string('payment_status')->default(PaymentStatus::Pending->value)->index();
            $table->string('payment_reference')->nullable()->unique();
            $table->string('gateway')->nullable()->index();
            // MariaDB 10.1 on older cPanel/XAMPP targets does not support native JSON.
            // The Payment model casts this longText payload back to an array.
            $table->longText('gateway_response')->nullable();
            $table->timestamp('paid_at')->nullable();
            $table->timestamp('failed_at')->nullable();
            $table->timestamps();

            $table->index(['user_id', 'payment_status']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('payments');
    }
};
