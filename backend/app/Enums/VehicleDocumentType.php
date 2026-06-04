<?php

namespace App\Enums;

use App\Enums\Concerns\HasValues;

enum VehicleDocumentType: string
{
    use HasValues;

    case VehicleLicense = 'vehicle_license';
    case Insurance = 'insurance';
    case RoadWorthiness = 'road_worthiness';
    case OwnershipProof = 'ownership_proof';
    case Other = 'other';
}
