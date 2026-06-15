<?php

namespace App\Filament\Admin\Resources\RoleResource\Pages;

use App\Filament\Admin\Resources\RoleResource;
use App\Services\AuditLogService;
use Filament\Resources\Pages\EditRecord;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\Auth;

class EditRole extends EditRecord
{
    protected static string $resource = RoleResource::class;

    protected function handleRecordUpdate(Model $record, array $data): Model
    {
        $oldValues = $record->load('permissions')->only(['name', 'display_name']);

        $record = parent::handleRecordUpdate($record, $data);

        app(AuditLogService::class)->log(
            'role.updated',
            Auth::user(),
            $record,
            $oldValues,
            $record->load('permissions')->only(['name', 'display_name'])
        );

        return $record;
    }
}
