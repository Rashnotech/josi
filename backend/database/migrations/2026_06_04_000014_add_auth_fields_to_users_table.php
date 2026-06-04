<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            if (! Schema::hasColumn('users', 'phone_verified_at')) {
                $table->timestamp('phone_verified_at')->nullable()->after('email_verified_at');
            }

            if (! Schema::hasColumn('users', 'last_login_at')) {
                $table->timestamp('last_login_at')->nullable()->index()->after('status');
            }

            if (! Schema::hasColumn('users', 'password_reset_code')) {
                $table->string('password_reset_code')->nullable()->after('last_login_at');
            }

            if (! Schema::hasColumn('users', 'password_reset_code_expires_at')) {
                $table->timestamp('password_reset_code_expires_at')->nullable()->after('password_reset_code');
            }

            if (! Schema::hasColumn('users', 'password_reset_verified_at')) {
                $table->timestamp('password_reset_verified_at')->nullable()->after('password_reset_code_expires_at');
            }

            if (! Schema::hasColumn('users', 'password_reset_token')) {
                $table->string('password_reset_token')->nullable()->index()->after('password_reset_verified_at');
            }

            if (! Schema::hasColumn('users', 'password_reset_code_attempts')) {
                $table->unsignedTinyInteger('password_reset_code_attempts')->default(0)->after('password_reset_token');
            }

            if (! Schema::hasColumn('users', 'password_reset_sent_at')) {
                $table->timestamp('password_reset_sent_at')->nullable()->after('password_reset_code_attempts');
            }
        });
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            foreach ([
                'phone_verified_at',
                'last_login_at',
                'password_reset_code',
                'password_reset_code_expires_at',
                'password_reset_verified_at',
                'password_reset_token',
                'password_reset_code_attempts',
                'password_reset_sent_at',
            ] as $column) {
                if (Schema::hasColumn('users', $column)) {
                    $table->dropColumn($column);
                }
            }
        });
    }
};
