<?php

namespace Database\Factories;

use App\Enums\VehicleDocumentType;
use App\Enums\VerificationStatus;
use App\Models\Vehicle;
use App\Models\VehicleDocument;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<VehicleDocument>
 */
class VehicleDocumentFactory extends Factory
{
    protected $model = VehicleDocument::class;

    public function definition(): array
    {
        $type = fake()->randomElement(VehicleDocumentType::cases());

        return [
            'vehicle_id' => Vehicle::factory(),
            'document_type' => $type,
            'file_path' => "kyc/vehicles/{$type->value}/".fake()->uuid().'.pdf',
            'original_file_name' => "{$type->value}.pdf",
            'mime_type' => 'application/pdf',
            'file_size' => fake()->numberBetween(120000, 5000000),
            'verification_status' => VerificationStatus::Pending,
            'verified_by' => null,
            'verified_at' => null,
            'rejection_reason' => null,
        ];
    }
}
