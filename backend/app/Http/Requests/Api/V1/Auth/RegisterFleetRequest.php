<?php

namespace App\Http\Requests\Api\V1\Auth;

use App\Http\Requests\Api\V1\BaseApiRequest;
use Illuminate\Validation\Rules\Password;

class RegisterFleetRequest extends BaseApiRequest
{
    public function rules(): array
    {
        return [
            'name' => ['required', 'string', 'max:150'],
            'email' => ['required', 'email', 'max:255', 'unique:users,email'],
            'phone' => ['required', 'string', 'max:30', 'unique:users,phone'],
            'password' => ['required', 'confirmed', Password::min(8)],
            'business_name' => ['required', 'string', 'max:255'],
            'business_phone' => ['required', 'string', 'max:30'],
            'business_email' => ['nullable', 'email', 'max:255'],
            'business_address' => ['required', 'string', 'max:1000'],
            'city' => ['required', 'string', 'max:100'],
            'state' => ['required', 'string', 'max:100'],
            'registration_number' => ['nullable', 'string', 'max:100'],
        ];
    }
}
