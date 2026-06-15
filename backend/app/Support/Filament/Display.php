<?php

namespace App\Support\Filament;

use BackedEnum;
use Illuminate\Support\Str;

class Display
{
    /**
     * @param  array<int, BackedEnum|string>  $values
     * @return array<string, string>
     */
    public static function options(array $values): array
    {
        $options = [];

        foreach ($values as $value) {
            $key = $value instanceof BackedEnum ? (string) $value->value : (string) $value;
            $options[$key] = self::label($key);
        }

        return $options;
    }

    public static function label(BackedEnum|string|null $value): string
    {
        $value = $value instanceof BackedEnum ? (string) $value->value : (string) $value;

        return Str::headline(str_replace('_', ' ', $value));
    }

    public static function statusColor(BackedEnum|string|null $value): string
    {
        $value = $value instanceof BackedEnum ? (string) $value->value : (string) $value;

        return match ($value) {
            'active', 'approved', 'verified', 'paid', 'completed', 'remitted' => 'success',
            'pending', 'under_review', 'assigned', 'accepted', 'ongoing', 'cash_collected', 'partially_remitted' => 'warning',
            'rejected', 'failed', 'cancelled', 'suspended', 'disputed' => 'danger',
            'online', 'wallet', 'card', 'transfer' => 'info',
            default => 'gray',
        };
    }

    public static function money(int|float|string|null $amount): string
    {
        return 'NGN '.number_format((float) ($amount ?? 0), 2);
    }

    public static function fileSize(int|float|string|null $bytes): string
    {
        $bytes = (float) ($bytes ?? 0);

        if ($bytes >= 1048576) {
            return number_format($bytes / 1048576, 1).' MB';
        }

        if ($bytes >= 1024) {
            return number_format($bytes / 1024, 1).' KB';
        }

        return number_format($bytes).' B';
    }
}
