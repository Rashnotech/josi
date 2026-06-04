<?php

namespace App\Enums;

use App\Enums\Concerns\HasValues;

enum RiderDocumentType: string
{
    use HasValues;

    case ProfilePhoto = 'profile_photo';
    case DriverLicense = 'driver_license';
    case NationalId = 'national_id';
    case UtilityBill = 'utility_bill';
    case GuarantorForm = 'guarantor_form';
    case Other = 'other';
}
