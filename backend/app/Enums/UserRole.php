<?php

namespace App\Enums;

use App\Enums\Concerns\HasValues;

enum UserRole: string
{
    use HasValues;

    case SuperAdmin = 'super_admin';
    case Admin = 'admin';
    case PackOwner = 'pack_owner';
    case Rider = 'rider';
    case Customer = 'customer';
}
