<?php

use App\Enums\RiderDocumentType;
use App\Enums\VerificationStatus;
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('rider_documents', function (Blueprint $table) {
            $table->id();
            $table->foreignId('driver_profile_id')->constrained('rider_profiles')->cascadeOnDelete();
            $table->string('document_type')->default(RiderDocumentType::Other->value)->index();
            $table->string('file_path');
            $table->string('original_file_name');
            $table->string('mime_type');
            $table->unsignedBigInteger('file_size');
            $table->string('verification_status')->default(VerificationStatus::Pending->value)->index();
            $table->foreignId('verified_by')->nullable()->constrained('users')->nullOnDelete();
            $table->timestamp('verified_at')->nullable();
            $table->text('rejection_reason')->nullable();
            $table->timestamps();

            $table->index(['driver_profile_id', 'document_type']);
            $table->index(['driver_profile_id', 'verification_status']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('rider_documents');
    }
};
