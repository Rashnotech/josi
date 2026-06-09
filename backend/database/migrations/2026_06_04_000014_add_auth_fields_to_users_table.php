<?php

use Illuminate\Database\Migrations\Migration;
return new class extends Migration
{
    public function up(): void
    {
        // Auth fields are defined in the initial users migration.
        // Keep this historical migration as a no-op so fresh installs avoid
        // column introspection that old MariaDB 10.1 servers cannot answer.
    }

    public function down(): void
    {
        //
    }
};
