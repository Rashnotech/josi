<?php

namespace App\Enums;

use App\Enums\Concerns\HasValues;

enum VerificationStatus: string
{
    use HasValues;

    case Pending = 'pending';
    case Verified = 'verified';
    case Rejected = 'rejected';
}
