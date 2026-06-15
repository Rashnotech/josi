<x-filament-widgets::widget>
    <x-filament::section
        heading="Documents Status"
        description="Verification state for your uploaded fleet documents."
        icon="heroicon-o-document-check"
        icon-color="info"
    >
        <div style="display: grid; gap: 0.75rem; grid-template-columns: repeat(auto-fit, minmax(130px, 1fr));">
            @foreach ($items as $item)
                <x-filament::section compact secondary>
                    <x-filament::badge :color="$item['color']">{{ $item['label'] }}</x-filament::badge>
                    <div style="margin-top: 0.5rem; font-size: 1.35rem; font-weight: 700;">{{ $item['count'] }}</div>
                </x-filament::section>
            @endforeach
        </div>
    </x-filament::section>
</x-filament-widgets::widget>
