<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class CustomerProfileTest extends TestCase
{
    use RefreshDatabase;

    private function registerVerifiedCustomer(): array
    {
        $email = 'profile-customer@example.test';
        $phone = '0' . str_pad((string) random_int(0, 999999999), 9, '0', STR_PAD_LEFT);

        $response = $this->postJson('/api/v1/auth/register/customer', [
            'name' => 'Profile Customer',
            'email' => $email,
            'phone' => $phone,
            'password' => 'Password123!',
            'password_confirmation' => 'Password123!',
        ]);
        $response->assertStatus(201);

        $token = $response->json('data.token');
        $user = User::where('email', $email)->firstOrFail();
        $user->forceFill(['email_verified_at' => now()])->save();

        return [$token, $user];
    }

    public function test_email_in_the_update_payload_is_ignored(): void
    {
        [$token, $user] = $this->registerVerifiedCustomer();
        $originalEmail = $user->email;

        $response = $this->withHeader('Authorization', "Bearer {$token}")
            ->putJson('/api/v1/customer/profile', [
                'name' => 'Profile Customer',
                'email' => 'attacker-controlled@example.test',
            ]);

        $response->assertStatus(200);
        $response->assertJsonPath('data.user.email', $originalEmail);

        $user->refresh();
        $this->assertSame($originalEmail, $user->email);
    }

    public function test_name_and_phone_still_update_normally(): void
    {
        [$token, $user] = $this->registerVerifiedCustomer();
        $newPhone = '0' . str_pad((string) random_int(0, 999999999), 9, '0', STR_PAD_LEFT);

        $response = $this->withHeader('Authorization', "Bearer {$token}")
            ->putJson('/api/v1/customer/profile', [
                'name' => 'Updated Name',
                'phone' => $newPhone,
            ]);

        $response->assertStatus(200);
        $response->assertJsonPath('data.user.name', 'Updated Name');
        $response->assertJsonPath('data.user.phone', $newPhone);

        $user->refresh();
        $this->assertSame('Updated Name', $user->name);
        $this->assertSame($newPhone, $user->phone);
    }
}
