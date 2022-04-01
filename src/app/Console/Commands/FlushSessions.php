<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;
use Symfony\Component\Process\Process;
use Throwable;

class FlushSessions extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'session:flush';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Flush all user sessions';

    /**
     * Execute the console command.
     *
     * @return void
     */
    public function handle(): void
    {
        $driver = config('session.driver');
        $method = 'clean' . ucfirst($driver);
        try {
            $this->$method();
            $this->info('Session data cleaned.');
        } catch (Throwable $e) {
            $this->error($e->getMessage());
        }
    }

    protected function cleanFile(): void
    {
        $directory = config('session.files');
        $find      = new Process(['find', $directory, '-type', 'f', '-not', '-name', '.gitignore', '-print0']);
        $find->run();
        $rm = new Process(['xargs', '-0', 'rm']);
        $rm->setInput($find->getOutput());
        $rm->run();
    }

    protected function cleanDatabase(): void
    {
        $table = config('session.table');
        DB::table($table)->truncate();
    }
}
