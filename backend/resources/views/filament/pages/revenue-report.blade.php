<x-filament-panels::page>
    <div class="grid gap-4 md:grid-cols-2 xl:grid-cols-4">
        <div class="rounded-xl bg-white p-5 shadow-sm ring-1 ring-slate-950/5 dark:bg-slate-900 dark:ring-white/10">
            <p class="text-sm text-slate-500 dark:text-slate-400">Paid revenue</p>
            <p class="mt-2 text-2xl font-semibold text-slate-950 dark:text-white">{{ $paidRevenue }}</p>
        </div>
        <div class="rounded-xl bg-white p-5 shadow-sm ring-1 ring-slate-950/5 dark:bg-slate-900 dark:ring-white/10">
            <p class="text-sm text-slate-500 dark:text-slate-400">Cash collected</p>
            <p class="mt-2 text-2xl font-semibold text-slate-950 dark:text-white">{{ $cashCollected }}</p>
        </div>
        <div class="rounded-xl bg-white p-5 shadow-sm ring-1 ring-slate-950/5 dark:bg-slate-900 dark:ring-white/10">
            <p class="text-sm text-slate-500 dark:text-slate-400">Company share</p>
            <p class="mt-2 text-2xl font-semibold text-slate-950 dark:text-white">{{ $companyShare }}</p>
        </div>
        <div class="rounded-xl bg-white p-5 shadow-sm ring-1 ring-slate-950/5 dark:bg-slate-900 dark:ring-white/10">
            <p class="text-sm text-slate-500 dark:text-slate-400">Remitted</p>
            <p class="mt-2 text-2xl font-semibold text-slate-950 dark:text-white">{{ $remitted }}</p>
        </div>
    </div>
</x-filament-panels::page>
