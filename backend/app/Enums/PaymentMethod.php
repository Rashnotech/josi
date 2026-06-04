<?php

namespace App\Enums;

use App\Enums\Concerns\HasValues;

enum PaymentMethod: string
{
    use HasValues;

    case Cash = 'cash';
    case Card = 'card';
    case Transfer = 'transfer';
    case Wallet = 'wallet';
}
