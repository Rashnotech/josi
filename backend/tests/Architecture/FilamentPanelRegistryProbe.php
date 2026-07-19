<?php

putenv('LOG_CHANNEL=stderr');
putenv('CACHE_STORE=array');

require dirname(__DIR__, 2).'/vendor/autoload.php';

$app = require dirname(__DIR__, 2).'/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

/** @var Filament\PanelRegistry $registry */
$registry = $app->make(Filament\PanelRegistry::class);

echo json_encode([
    'default' => $registry->getDefault()->getId(),
    'panels' => array_keys($registry->all()),
], JSON_THROW_ON_ERROR).PHP_EOL;
