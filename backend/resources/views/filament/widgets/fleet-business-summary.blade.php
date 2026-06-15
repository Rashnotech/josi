<x-filament-widgets::widget>
    <x-filament::section
        :heading="$fleet?->business_name ?? 'Business profile'"
        :description="$fleet?->business_address ?? 'Complete your business profile and documents to keep onboarding moving.'"
        icon="heroicon-o-building-office-2"
        icon-color="danger"
    >
        <div style="display: grid; gap: 0.75rem; grid-template-columns: repeat(auto-fit, minmax(130px, 1fr));">
            <x-filament::section compact secondary>
                <x-filament::badge color="warning">Application</x-filament::badge>
                <div style="margin-top: 0.5rem; font-weight: 700;">{{ $statusLabel }}</div>
            </x-filament::section>
            <x-filament::section compact secondary>
                <x-filament::badge color="gray">Vehicles</x-filament::badge>
                <div style="margin-top: 0.5rem; font-size: 1.25rem; font-weight: 700;">{{ $vehicles }}</div>
            </x-filament::section>
            <x-filament::section compact secondary>
                <x-filament::badge color="info">Drivers</x-filament::badge>
                <div style="margin-top: 0.5rem; font-size: 1.25rem; font-weight: 700;">{{ $drivers }}</div>
            </x-filament::section>
            <x-filament::section compact secondary>
                <x-filament::badge color="success">Documents</x-filament::badge>
                <div style="margin-top: 0.5rem; font-size: 1.25rem; font-weight: 700;">{{ $documents }}</div>
            </x-filament::section>
        </div>
    </x-filament::section>
</x-filament-widgets::widget>
