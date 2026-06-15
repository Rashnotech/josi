<x-filament-widgets::widget>
    <x-filament::section
        heading="Cash Remittance Summary"
        description="Admin-controlled cash collection and rider remittance position."
        icon="heroicon-o-banknotes"
        icon-color="warning"
    >
        <div style="display: grid; gap: 0.75rem; grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));">
            <x-filament::section compact secondary>
                <x-filament::badge color="warning">Pending</x-filament::badge>
                <div style="margin-top: 0.5rem; font-size: 1.1rem; font-weight: 700;">{{ $pending }}</div>
            </x-filament::section>
            <x-filament::section compact secondary>
                <x-filament::badge color="info">Partial</x-filament::badge>
                <div style="margin-top: 0.5rem; font-size: 1.1rem; font-weight: 700;">{{ $partial }}</div>
            </x-filament::section>
            <x-filament::section compact secondary>
                <x-filament::badge color="success">Remitted</x-filament::badge>
                <div style="margin-top: 0.5rem; font-size: 1.1rem; font-weight: 700;">{{ $remitted }}</div>
            </x-filament::section>
            <x-filament::section compact secondary>
                <x-filament::badge color="danger">Disputed</x-filament::badge>
                <div style="margin-top: 0.5rem; font-size: 1.1rem; font-weight: 700;">{{ $disputed }}</div>
            </x-filament::section>
        </div>
    </x-filament::section>
</x-filament-widgets::widget>
