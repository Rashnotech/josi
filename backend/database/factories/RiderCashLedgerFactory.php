<?php

namespace Database\Factories;

use App\Enums\RemittanceStatus;
use App\Models\RiderCashLedger;
use App\Models\RiderProfile;
use App\Models\Trip;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<RiderCashLedger>
 */
class RiderCashLedgerFactory extends Factory
{
    protected $model = RiderCashLedger::class;

    public function definition(): array
    {
        $amountCollected = fake()->randomFloat(2, 2000, 15000);
        $riderShare = round($amountCollected * 0.70, 2);
        $companyShare = round($amountCollected - $riderShare, 2);

        return [
            'driver_profile_id' => RiderProfile::factory()->approved(),
            'trip_id' => Trip::factory()->completedCash(),
            'amount_collected' => $amountCollected,
            'rider_share' => $riderShare,
            'company_share' => $companyShare,
            'amount_to_remit' => $companyShare,
            'amount_remitted' => 0,
            'remittance_status' => RemittanceStatus::Pending,
            'remitted_at' => null,
            'notes' => null,
        ];
    }

    public function partiallyRemitted(): static
    {
        return $this->state(fn (array $attributes) => [
            'amount_remitted' => round(((float) $attributes['amount_to_remit']) / 2, 2),
            'remittance_status' => RemittanceStatus::PartiallyRemitted,
        ]);
    }
}
