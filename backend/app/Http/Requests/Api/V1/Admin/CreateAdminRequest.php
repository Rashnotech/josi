<?php

namespace App\Http\Requests\Api\V1\Admin;

use App\Http\Requests\Api\V1\BaseApiRequest;
use Illuminate\Validation\Rules\Password;

class CreateAdminRequest extends BaseApiRequest
{
    public function rules(): array
    {
        return [
            'name' => ['required', 'string', 'max:150'],
            'email' => ['required', 'email', 'max:255', 'unique:users,email'],
            'phone' => ['required', 'string', 'max:30', 'unique:users,phone'],
            'password' => ['required', 'confirmed', Password::min(8)],
        ];
    }
}
