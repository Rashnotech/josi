<?php

namespace Database\Seeders;

use App\Services\RbacService;
use Illuminate\Database\Seeder;

class RolesAndPermissionsSeeder extends Seeder
{
    public function run(RbacService $rbacService): void
    {
        $rbacService->ensureRolesAndPermissionsExist();
    }
}
