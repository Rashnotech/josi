<?php

namespace Tests\Feature;

use App\Models\User;
use App\Notifications\EmailVerificationCodeNotification;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Notification;
use Tests\TestCase;

class EmailVerificationTest extends TestCase
{
    use RefreshDatabase;

    private function registerCustomer(string $emailSuffix = ''): array
    {
        $email = "customer{$emailSuffix}@example.test";
        $phone = '0' . str_pad((string) random_int(0, 999999999), 9, '0', STR_PAD_LEFT);

        $response = $this->postJson('/api/v1/auth/register/customer', [
            'name' => 'Test Customer',
            'first_name' => 'Test',
            'last_name' => 'Customer',
            'email' => $email,
            'phone' => $phone,
            'password' => 'Password123!',
            'password_confirmation' => 'Password123!',
        ]);

        $response->assertStatus(201);

        $token = $response->json('data.token');
        $user = User::where('email', $email)->firstOrFail();

        return [$token, $user];
    }

    public function test_registering_a_customer_sends_a_verification_code_and_leaves_email_unverified(): void
    {
        Notification::fake();

        [, $user] = $this->registerCustomer();

        $this->assertFalse($user->hasVerifiedEmail());
        $this->assertNotNull($user->email_verification_code);
        $this->assertNotNull($user->email_verification_code_expires_at);
        Notification::assertSentTo($user, EmailVerificationCodeNotification::class);
    }

    public function test_unverified_customer_can_log_in_but_is_blocked_from_primary_features(): void
    {
        [$token, $user] = $this->registerCustomer('-gate');

        // Login itself is never blocked by verification status.
        $login = $this->postJson('/api/v1/auth/login', [
            'identifier' => $user->email,
            'password' => 'Password123!',
        ]);
        $login->assertStatus(200);

        // But a primary customer feature is gated until verified.
        $profile = $this->withHeader('Authorization', "Bearer {$token}")
            ->getJson('/api/v1/customer/profile');
        $profile->assertStatus(403);
    }

    public function test_correct_code_verifies_email_and_unlocks_primary_features(): void
    {
        [$token, $user] = $this->registerCustomer('-correct');
        $code = $this->captureVerificationCode($user);

        $blocked = $this->withHeader('Authorization', "Bearer {$token}")
            ->getJson('/api/v1/customer/profile');
        $blocked->assertStatus(403);

        $verify = $this->withHeader('Authorization', "Bearer {$token}")
            ->postJson('/api/v1/auth/email/verify', ['code' => $code]);
        $verify->assertStatus(200);
        $verify->assertJsonPath('data.email_verified', true);

        $unlocked = $this->withHeader('Authorization', "Bearer {$token}")
            ->getJson('/api/v1/customer/profile');
        $unlocked->assertStatus(200);

        $user->refresh();
        $this->assertTrue($user->hasVerifiedEmail());
        $this->assertNull($user->email_verification_code);
    }

    public function test_wrong_code_is_rejected_and_increments_attempts(): void
    {
        [$token, $user] = $this->registerCustomer('-wrong');

        $response = $this->withHeader('Authorization', "Bearer {$token}")
            ->postJson('/api/v1/auth/email/verify', ['code' => '000000']);
        $response->assertStatus(422);

        $user->refresh();
        $this->assertFalse($user->hasVerifiedEmail());
        $this->assertSame(1, $user->email_verification_code_attempts);
    }

    public function test_code_is_locked_after_five_wrong_attempts_even_if_the_sixth_is_correct(): void
    {
        [$token, $user] = $this->registerCustomer('-lockout');
        $code = $this->captureVerificationCode($user);

        for ($i = 0; $i < 5; $i++) {
            $this->withHeader('Authorization', "Bearer {$token}")
                ->postJson('/api/v1/auth/email/verify', ['code' => '000000'])
                ->assertStatus(422);
        }

        $response = $this->withHeader('Authorization', "Bearer {$token}")
            ->postJson('/api/v1/auth/email/verify', ['code' => $code]);
        $response->assertStatus(422);

        $user->refresh();
        $this->assertFalse($user->hasVerifiedEmail());
    }

    public function test_expired_code_is_rejected(): void
    {
        [$token, $user] = $this->registerCustomer('-expired');
        $code = $this->captureVerificationCode($user);

        $user->forceFill([
            'email_verification_code_expires_at' => now()->subMinute(),
        ])->save();

        $response = $this->withHeader('Authorization', "Bearer {$token}")
            ->postJson('/api/v1/auth/email/verify', ['code' => $code]);
        $response->assertStatus(422);
    }

    public function test_resend_is_rejected_during_cooldown(): void
    {
        [$token] = $this->registerCustomer('-cooldown');

        $response = $this->withHeader('Authorization', "Bearer {$token}")
            ->postJson('/api/v1/auth/email/resend');
        $response->assertStatus(422);
    }

    public function test_resend_after_cooldown_issues_a_new_code_and_invalidates_the_old_one(): void
    {
        [$token, $user] = $this->registerCustomer('-resend');
        $firstCode = $this->captureVerificationCode($user);

        $user->forceFill([
            'email_verification_sent_at' => now()->subMinutes(5),
        ])->save();

        Notification::fake();
        $response = $this->withHeader('Authorization', "Bearer {$token}")
            ->postJson('/api/v1/auth/email/resend');
        $response->assertStatus(200);
        Notification::assertSentTo($user, EmailVerificationCodeNotification::class);

        // The old code no longer matches the freshly-issued hash.
        $this->withHeader('Authorization', "Bearer {$token}")
            ->postJson('/api/v1/auth/email/verify', ['code' => $firstCode])
            ->assertStatus(422);

        $secondCode = $this->captureVerificationCode($user, assertFake: false);
        $this->withHeader('Authorization', "Bearer {$token}")
            ->postJson('/api/v1/auth/email/verify', ['code' => $secondCode])
            ->assertStatus(200);
    }

    public function test_resend_after_already_verified_is_rejected(): void
    {
        [$token, $user] = $this->registerCustomer('-already-verified');
        $code = $this->captureVerificationCode($user);

        $this->withHeader('Authorization', "Bearer {$token}")
            ->postJson('/api/v1/auth/email/verify', ['code' => $code])
            ->assertStatus(200);

        $response = $this->withHeader('Authorization', "Bearer {$token}")
            ->postJson('/api/v1/auth/email/resend');
        $response->assertStatus(422);
    }

    /**
     * Registration always fires a real (hashed) code via the notification
     * pipeline; this captures the plaintext code Notification::fake() saw
     * so the test can exercise the verify endpoint like a real client would.
     */
    private function captureVerificationCode(User $user, bool $assertFake = true): string
    {
        if ($assertFake) {
            Notification::fake();

            $user->forceFill(['email_verification_sent_at' => null])->save();
            app(\App\Services\EmailVerificationService::class)->sendVerificationCode($user->refresh());
            // Outside an HTTP request/terminate cycle, defer()'d notification
            // sends never fire on their own; flush them manually here.
            app(\Illuminate\Support\Defer\DeferredCallbackCollection::class)->invoke();
        }

        $sent = null;
        Notification::sent($user, EmailVerificationCodeNotification::class, function ($notification) use (&$sent) {
            $ref = new \ReflectionProperty($notification, 'code');
            $ref->setAccessible(true);
            $sent = $ref->getValue($notification);

            return true;
        });

        $this->assertNotNull($sent, 'Expected a verification code notification to have been sent.');

        return $sent;
    }
}
