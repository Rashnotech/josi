<x-filament-panels::page>
    <div class="grid gap-4 md:grid-cols-2 xl:grid-cols-5">
        @foreach ($rows as $row)
            <div class="rounded-xl bg-white p-5 shadow-sm ring-1 ring-slate-950/5 dark:bg-slate-900 dark:ring-white/10">
                <p class="text-sm font-medium text-slate-500 dark:text-slate-400">{{ $row['label'] }}</p>
                <div class="mt-4 flex items-end justify-between gap-4">
                    <div>
                        <p class="text-xs text-slate-500 dark:text-slate-400">Riders</p>
                        <p class="text-2xl font-semibold text-slate-950 dark:text-white">{{ number_format($row['riders']) }}</p>
                    </div>
                    <div class="text-right">
                        <p class="text-xs text-slate-500 dark:text-slate-400">Pack owners</p>
                        <p class="text-2xl font-semibold text-slate-950 dark:text-white">{{ number_format($row['fleets']) }}</p>
                    </div>
                </div>
            </div>
        @endforeach
    </div>
</x-filament-panels::page>
