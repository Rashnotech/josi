<?php

namespace App\Filament\Admin\Resources\UserResource\Pages;

use App\Enums\UserRole;
use App\Filament\Admin\Resources\UserResource;
use App\Models\User;
use App\Services\AuditLogService;
use App\Services\RbacService;
use Filament\Resources\Pages\CreateRecord;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\Auth;

class CreateUser extends CreateRecord
{
    protected static string $resource = UserResource::class;

    protected function handleRecordCreation(array $data): Model
    {
        /** @var User $record */
        $record = parent::handleRecordCreation($data);

        app(RbacService::class)->syncUserRole($record);

        if ($record->role === UserRole::Admin) {
            app(AuditLogService::class)->log(
                'user.admin_created',
                Auth::user(),
                $record,
                [],
                $record->only(['name', 'email', 'phone', 'role', 'status'])
            );
        }

        return $record;
    }
}
