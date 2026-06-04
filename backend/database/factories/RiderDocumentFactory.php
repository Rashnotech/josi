<?php

namespace Database\Factories;

use App\Enums\RiderDocumentType;
use App\Enums\VerificationStatus;
use App\Models\RiderDocument;
use App\Models\RiderProfile;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<RiderDocument>
 */
class RiderDocumentFactory extends Factory
{
    protected $model = RiderDocument::class;

    public function definition(): array
    {
        $type = fake()->randomElement(RiderDocumentType::cases());

        return [
            'driver_profile_id' => RiderProfile::factory(),
            'document_type' => $type,
            'file_path' => "kyc/riders/{$type->value}/".fake()->uuid().'.jpg',
            'original_file_name' => "{$type->value}.jpg",
            'mime_type' => 'image/jpeg',
            'file_size' => fake()->numberBetween(120000, 2500000),
            'verification_status' => VerificationStatus::Pending,
            'verified_by' => null,
            'verified_at' => null,
            'rejection_reason' => null,
        ];
    }
}
