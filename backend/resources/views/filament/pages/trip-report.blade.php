<x-filament-panels::page>
    <div class="grid gap-4 md:grid-cols-2 xl:grid-cols-3">
        @foreach ($rows as $row)
            <div class="rounded-xl bg-white p-5 shadow-sm ring-1 ring-slate-950/5 dark:bg-slate-900 dark:ring-white/10">
                <p class="text-sm font-medium text-slate-500 dark:text-slate-400">{{ $row['label'] }}</p>
                <p class="mt-2 text-3xl font-semibold text-slate-950 dark:text-white">{{ number_format($row['count']) }}</p>
                <p class="mt-3 text-sm text-slate-500 dark:text-slate-400">{{ $row['amount'] }}</p>
            </div>
        @endforeach
    </div>
</x-filament-panels::page>
