<?php

namespace App\Enums;

use App\Enums\Concerns\HasValues;

enum TripStatus: string
{
    use HasValues;

    case Requested = 'requested';
    case Assigned = 'assigned';
    case Accepted = 'accepted';
    case Ongoing = 'ongoing';
    case Completed = 'completed';
    case Cancelled = 'cancelled';
}
