<?php

namespace App\Http\Requests\Api\V1\Auth;

use App\Http\Requests\Api\V1\BaseApiRequest;
use Illuminate\Validation\Rules\Password;

class ResetPasswordRequest extends BaseApiRequest
{
    public function rules(): array
    {
        return [
            'identifier' => ['required', 'string', 'max:255'],
            'reset_token' => ['required', 'string', 'max:255'],
            'password' => ['required', 'confirmed', Password::min(8)],
        ];
    }
}
