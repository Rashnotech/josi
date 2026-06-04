<?php

namespace App\Http\Requests\Api\V1\Auth;

use App\Http\Requests\Api\V1\BaseApiRequest;

class VerifyResetCodeRequest extends BaseApiRequest
{
    public function rules(): array
    {
        return [
            'identifier' => ['required', 'string', 'max:255'],
            'code' => ['required', 'digits:6'],
        ];
    }
}
