<?php

namespace App\Enums;

use App\Enums\Concerns\HasValues;

enum VehicleType: string
{
    use HasValues;

    case Bike = 'bike';
    case Motorcycle = 'motorcycle';
    case Tricycle = 'tricycle';
    case Car = 'car';
    case Van = 'van';
}
