<?php

namespace App\Http\Requests\Api\V1\Auth;

use App\Enums\UserRole;
use App\Http\Requests\Api\V1\BaseApiRequest;
use Illuminate\Validation\Rule;
use Illuminate\Validation\Rules\Password;

class RegisterRequest extends BaseApiRequest
{
    protected function prepareForValidation(): void
    {
        $firstName = trim((string) $this->input('first_name'));
        $lastName = trim((string) $this->input('last_name'));

        if (! $this->filled('name') && ($firstName !== '' || $lastName !== '')) {
            $this->merge([
                'name' => trim($firstName.' '.$lastName),
            ]);
        }
    }

    public function rules(): array
    {
        return [
            'first_name' => ['required', 'string', 'max:100'],
            'last_name' => ['required', 'string', 'max:100'],
            'name' => ['required', 'string', 'max:150'],
            'email' => ['required', 'email', 'max:255', 'unique:users,email'],
            'phone' => ['required', 'string', 'max:30', 'unique:users,phone'],
            'password' => ['required', 'confirmed', Password::min(8)],
            'role' => ['required', 'string', Rule::in(UserRole::publicRegistrationValues())],
            'address' => ['nullable', 'string', 'max:1000'],
            'city' => ['nullable', 'string', 'max:100'],
            'state' => ['nullable', 'string', 'max:100'],
            'business_name' => ['nullable', 'string', 'max:255'],
            'business_email' => ['nullable', 'email', 'max:255'],
            'business_phone' => ['nullable', 'string', 'max:30'],
            'business_address' => ['nullable', 'string', 'max:1000'],
            'vehicle_count' => ['required_if:role,'.UserRole::PackOwner->value, 'integer', 'min:1', 'max:10000'],
            'registration_number' => ['nullable', 'string', 'max:100'],
        ];
    }
}
