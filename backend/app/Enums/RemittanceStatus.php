<?php

namespace App\Enums;

use App\Enums\Concerns\HasValues;

enum RemittanceStatus: string
{
    use HasValues;

    case Pending = 'pending';
    case PartiallyRemitted = 'partially_remitted';
    case Remitted = 'remitted';
    case Disputed = 'disputed';
    case Waived = 'waived';
}
