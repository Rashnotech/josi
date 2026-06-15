<x-filament-widgets::widget>
    <x-filament::section
        heading="Josi operations command"
        description="Run onboarding, fleet readiness, trips, payments, and cash remittance from one controlled dashboard."
        icon="heroicon-o-command-line"
        icon-color="danger"
    >
        <div style="display: grid; gap: 0.75rem; grid-template-columns: repeat(auto-fit, minmax(140px, 1fr));">
            <x-filament::section compact secondary>
                <x-filament::badge color="warning">Pending apps</x-filament::badge>
                <div style="margin-top: 0.5rem; font-size: 1.35rem; font-weight: 700;">{{ $pendingApplications }}</div>
            </x-filament::section>
            <x-filament::section compact secondary>
                <x-filament::badge color="gray">Active vehicles</x-filament::badge>
                <div style="margin-top: 0.5rem; font-size: 1.35rem; font-weight: 700;">{{ $activeVehicles }}</div>
            </x-filament::section>
            <x-filament::section compact secondary>
                <x-filament::badge color="info">Today trips</x-filament::badge>
                <div style="margin-top: 0.5rem; font-size: 1.35rem; font-weight: 700;">{{ $todayTrips }}</div>
            </x-filament::section>
            <x-filament::section compact secondary>
                <x-filament::badge color="success">Completed</x-filament::badge>
                <div style="margin-top: 0.5rem; font-size: 1.35rem; font-weight: 700;">{{ $completedTrips }}</div>
            </x-filament::section>
            <x-filament::section compact secondary>
                <x-filament::badge color="warning">Cash</x-filament::badge>
                <div style="margin-top: 0.5rem; font-size: 1.05rem; font-weight: 700;">{{ $cashCollected }}</div>
            </x-filament::section>
        </div>
    </x-filament::section>
</x-filament-widgets::widget>
