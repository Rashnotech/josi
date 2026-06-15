<?php

namespace App\Filament\Admin\Resources\UserResource\Pages;

use App\Filament\Admin\Resources\UserResource;
use App\Models\User;
use App\Services\AuditLogService;
use App\Services\RbacService;
use Filament\Actions\DeleteAction;
use Filament\Resources\Pages\EditRecord;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\Auth;

class EditUser extends EditRecord
{
    protected static string $resource = UserResource::class;

    protected function getHeaderActions(): array
    {
        return [
            DeleteAction::make(),
        ];
    }

    protected function handleRecordUpdate(Model $record, array $data): Model
    {
        $oldValues = $record->only(['name', 'email', 'phone', 'role', 'status']);

        /** @var User $record */
        $record = parent::handleRecordUpdate($record, $data);
        app(RbacService::class)->syncUserRole($record);

        app(AuditLogService::class)->log(
            'user.updated',
            Auth::user(),
            $record,
            $oldValues,
            $record->only(array_keys($oldValues))
        );

        return $record;
    }
}
