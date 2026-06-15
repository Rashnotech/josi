<?php

namespace App\Filament\Admin\Resources\ZonePriceResource\Pages;

use App\Filament\Admin\Resources\ZonePriceResource;
use App\Models\ZonePrice;
use Filament\Actions\DeleteAction;
use Filament\Resources\Pages\EditRecord;
use Illuminate\Validation\ValidationException;

class EditZonePrice extends EditRecord
{
    protected static string $resource = ZonePriceResource::class;

    protected function getHeaderActions(): array
    {
        return [
            DeleteAction::make(),
        ];
    }

    protected function mutateFormDataBeforeSave(array $data): array
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
            ->whereKeyNot($this->getRecord()->getKey())
            ->exists();

        if ($exists) {
            throw ValidationException::withMessages([
                'data.destination_zone_id' => 'An active price already exists for this pickup and destination pair.',
            ]);
        }
    }
}
