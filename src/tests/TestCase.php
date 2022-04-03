<?php

namespace Tests;

use RuntimeException;
use Illuminate\Foundation\Testing\TestCase as BaseTestCase;
use Illuminate\Support\Facades\File;

abstract class TestCase extends BaseTestCase
{
    use CreatesApplication;

    protected function setUp(): void
    {
        parent::setUp();
        if (!File::exists(dirname(__DIR__) . DIRECTORY_SEPARATOR . '.env.testing') ||
            !app()->environment('testing')
        ) {
            throw new RuntimeException('file .env.testing not exists');
        }

        $this->setLaravelStart();
        $this->createDatabaseFile();
    }

    /**
     * @return void
     */
    protected function setLaravelStart(): void
    {
        if (!defined('LARAVEL_START')) {
            define('LARAVEL_START', microtime(true));
        }
    }

    /**
     * @return void
     */
    protected function createDatabaseFile(): void
    {
        if (!File::exists(base_path('database/database.sqlite'))) {
            File::put(base_path('database/database.sqlite'), '');
        }
    }
}
