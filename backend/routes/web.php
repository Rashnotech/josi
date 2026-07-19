<?php

use Illuminate\Support\Facades\Route;

Route::redirect('/', config('app.web_login_url', '/login'))->name('home');
