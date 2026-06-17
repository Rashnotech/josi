<?php

putenv('LOG_CHANNEL=stderr');
putenv('CACHE_DRIVER=array');

require dirname(__DIR__, 2).'/vendor/autoload.php';

$start = microtime(true);
$app = require dirname(__DIR__, 2).'/bootstrap/app.php';

$kernel = $app->make(Illuminate\Contracts\Http\Kernel::class);
$request = Illuminate\Http\Request::create(
    '/api/v1/auth/login',
    'POST',
    [],
    [],
    [],
    ['HTTP_ACCEPT' => 'application/json']
);

$response = $kernel->handle($request);
$elapsedMs = (int) round((microtime(true) - $start) * 1000);

echo json_encode([
    'status' => $response->getStatusCode(),
    'elapsed_ms' => $elapsedMs,
], JSON_THROW_ON_ERROR).PHP_EOL;

$kernel->terminate($request, $response);
