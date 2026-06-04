<?php

namespace App\Enums;

use App\Enums\Concerns\HasValues;

enum FleetDocumentType: string
{
    use HasValues;

    case BusinessRegistration = 'business_registration';
    case TaxDocument = 'tax_document';
    case OwnerId = 'owner_id';
    case CompanyProfile = 'company_profile';
    case Other = 'other';
}
