<?php

namespace App\Enums;

use App\Enums\Concerns\HasValues;

enum VehicleStatus: string
{
    use HasValues;

    case Active = 'active';
    case Inactive = 'inactive';
    case UnderMaintenance = 'under_maintenance';
    case Suspended = 'suspended';
}
