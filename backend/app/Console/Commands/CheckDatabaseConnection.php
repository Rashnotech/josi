<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;
use Throwable;

class CheckDatabaseConnection extends Command
{
    protected $signature = 'josi:check-db';

    protected $description = 'Check the configured Josi database connection.';

    public function handle(): int
    {
        try {
            $connection = DB::connection();
            $connection->getPdo();

            $this->info('Database connection successful.');
            $this->line('Connection: '.$connection->getDriverName());
            $this->line('Database: '.$connection->getDatabaseName());

            return self::SUCCESS;
        } catch (Throwable $exception) {
            $this->error('Database connection failed.');
            $this->line('Connection: '.config('database.default'));
            $this->line('Error: '.$exception->getMessage());

            return self::FAILURE;
        }
    }
}
