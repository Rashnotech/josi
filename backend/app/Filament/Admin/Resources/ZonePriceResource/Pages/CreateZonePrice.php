<?php

namespace App\Filament\Admin\Resources\ZonePriceResource\Pages;

use App\Filament\Admin\Resources\ZonePriceResource;
use App\Models\ZonePrice;
use Filament\Resources\Pages\CreateRecord;
use Illuminate\Validation\ValidationException;

class CreateZonePrice extends CreateRecord
{
    protected static string $resource = ZonePriceResource::class;

    protected function mutateFormDataBeforeCreate(array $data): array
    {
        $this->ensureNoDuplicateActiveRoute($data);

        return $data;
    }

    private function ensureNoDuplicateActiveRoute(array $data): void
    {
        if (! ($data['is_active'] ?? false)) {
            return;
        }

        $exists = ZonePrice::query()
            ->where('pickup_zone_id', $data['pickup_zone_id'] ?? null)
            ->where('destination_zone_id', $data['destination_zone_id'] ?? null)
            ->where('is_active', true)
            ->exists();

        if ($exists) {
            throw ValidationException::withMessages([
                'data.destination_zone_id' => 'An active price already exists for this pickup and destination pair.',
            ]);
        }
    }
}
