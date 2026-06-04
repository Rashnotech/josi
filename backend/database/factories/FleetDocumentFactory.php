<?php

namespace Database\Factories;

use App\Enums\FleetDocumentType;
use App\Enums\VerificationStatus;
use App\Models\Fleet;
use App\Models\FleetDocument;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<FleetDocument>
 */
class FleetDocumentFactory extends Factory
{
    protected $model = FleetDocument::class;

    public function definition(): array
    {
        $type = fake()->randomElement(FleetDocumentType::cases());

        return [
            'fleet_id' => Fleet::factory(),
            'document_type' => $type,
            'file_path' => "kyc/fleets/{$type->value}/".fake()->uuid().'.pdf',
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
