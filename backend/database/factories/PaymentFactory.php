<?php

namespace Database\Factories;

use App\Enums\PaymentMethod;
use App\Enums\PaymentStatus;
use App\Models\Payment;
use App\Models\Trip;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<Payment>
 */
class PaymentFactory extends Factory
{
    protected $model = Payment::class;

    public function definition(): array
    {
        return [
            'trip_id' => Trip::factory(),
            'user_id' => User::factory()->customer(),
            'amount' => fake()->randomFloat(2, 1500, 12000),
            'payment_method' => PaymentMethod::Cash,
            'payment_status' => PaymentStatus::Pending,
            'payment_reference' => null,
            'gateway' => null,
            'gateway_response' => null,
            'paid_at' => null,
            'failed_at' => null,
        ];
    }

    public function cashCollected(): static
    {
        return $this->state(fn () => [
            'payment_method' => PaymentMethod::Cash,
            'payment_status' => PaymentStatus::CashCollected,
            'paid_at' => now(),
        ]);
    }

    public function paidOnline(): static
    {
        return $this->state(fn () => [
            'payment_method' => fake()->randomElement([PaymentMethod::Card, PaymentMethod::Transfer, PaymentMethod::Wallet]),
            'payment_status' => PaymentStatus::Paid,
            'payment_reference' => strtoupper(fake()->unique()->bothify('PAY-########')),
            'gateway' => 'manual_test_gateway',
            'gateway_response' => ['verified' => true],
            'paid_at' => now(),
        ]);
    }
}
