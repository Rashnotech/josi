<?php

namespace App\Enums;

use App\Enums\Concerns\HasValues;

enum ApplicationStatus: string
{
    use HasValues;

    case Pending = 'pending';
    case UnderReview = 'under_review';
    case Approved = 'approved';
    case Rejected = 'rejected';
    case Suspended = 'suspended';
}
