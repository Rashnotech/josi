<?php

namespace Database\Seeders;

use App\Services\RbacService;
use Illuminate\Database\Seeder;

class RbacSeeder extends Seeder
{
    public function run(RbacService $rbacService): void
    {
        $rbacService->ensureRolesAndPermissionsExist();
    }
}
