<?php

namespace App\Http\Requests\Api\V1\Auth;

use App\Http\Requests\Api\V1\BaseApiRequest;

class VerifyEmailCodeRequest extends BaseApiRequest
{
    public function rules(): array
    {
        return [
            'code' => ['required', 'digits:6'],
        ];
    }
}
