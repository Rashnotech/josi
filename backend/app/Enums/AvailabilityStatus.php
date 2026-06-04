<?php

namespace App\Enums;

use App\Enums\Concerns\HasValues;

enum AvailabilityStatus: string
{
    use HasValues;

    case Offline = 'offline';
    case Online = 'online';
    case Busy = 'busy';
    case Unavailable = 'unavailable';
}
