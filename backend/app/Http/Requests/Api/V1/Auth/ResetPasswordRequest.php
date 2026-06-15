<?php

namespace App\Http\Requests\Api\V1\Auth;

use App\Http\Requests\Api\V1\BaseApiRequest;
use Illuminate\Validation\Rules\Password;

class ResetPasswordRequest extends BaseApiRequest
{
    protected function prepareForValidation(): void
    {
        if (! $this->filled('identifier') && $this->filled('email_or_phone')) {
            $this->merge([
                'identifier' => $this->input('email_or_phone'),
            ]);
        }
    }

    public function rules(): array
    {
        return [
            'identifier' => ['required', 'string', 'max:255'],
            'email_or_phone' => ['nullable', 'string', 'max:255'],
            'code' => ['required_without:reset_token', 'digits:6'],
            'reset_token' => ['required_without:code', 'string', 'max:255'],
            'password' => ['required', 'confirmed', Password::min(8)],
        ];
    }
}
