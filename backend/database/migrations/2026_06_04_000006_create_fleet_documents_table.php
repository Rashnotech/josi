<?php

use App\Enums\FleetDocumentType;
use App\Enums\VerificationStatus;
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('fleet_documents', function (Blueprint $table) {
            $table->id();
            $table->foreignId('fleet_id')->constrained()->cascadeOnDelete();
            $table->string('document_type')->default(FleetDocumentType::Other->value)->index();
            $table->string('file_path');
            $table->string('original_file_name');
            $table->string('mime_type');
            $table->unsignedBigInteger('file_size');
            $table->string('verification_status')->default(VerificationStatus::Pending->value)->index();
            $table->foreignId('verified_by')->nullable()->constrained('users')->nullOnDelete();
            $table->timestamp('verified_at')->nullable();
            $table->text('rejection_reason')->nullable();
            $table->timestamps();

            $table->index(['fleet_id', 'document_type']);
            $table->index(['fleet_id', 'verification_status']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('fleet_documents');
    }
};
