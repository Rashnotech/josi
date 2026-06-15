@php
    $logoUrl = asset('images/josi-logo.png');
@endphp

<style>
    .josi-panel-loader {
        align-items: center;
        background:
            radial-gradient(circle at 50% 34%, rgba(236, 17, 26, 0.24), transparent 24rem),
            linear-gradient(180deg, #ffffff 0%, #f8fafc 42%, #050505 100%);
        color: #ffffff;
        display: grid;
        gap: 1rem;
        inset: 0;
        justify-items: center;
        min-height: 100vh;
        opacity: 1;
        pointer-events: auto;
        position: fixed;
        transition: opacity 240ms ease, visibility 240ms ease;
        visibility: visible;
        z-index: 2147483647;
    }

    html.josi-panel-ready:not(.josi-panel-loading) .josi-panel-loader {
        opacity: 0;
        pointer-events: none;
        visibility: hidden;
    }

    html.josi-panel-loading .josi-panel-loader {
        opacity: 1;
        pointer-events: auto;
        visibility: visible;
    }

    .josi-panel-loader__card {
        align-items: center;
        display: grid;
        gap: 1.1rem;
        justify-items: center;
        transform: translateY(-0.5rem);
    }

    .josi-panel-loader__logo {
        background: rgba(255, 255, 255, 0.96);
        border-radius: 1rem;
        box-shadow: 0 24px 80px rgba(0, 0, 0, 0.24);
        height: 5rem;
        object-fit: contain;
        padding: 0.65rem;
        width: 5rem;
    }

    .josi-panel-loader__ring {
        animation: josi-panel-loader-spin 780ms linear infinite;
        border: 3px solid rgba(255, 255, 255, 0.22);
        border-radius: 999px;
        border-top-color: #ec111a;
        height: 3rem;
        position: relative;
        width: 3rem;
    }

    .josi-panel-loader__ring::after {
        animation: josi-panel-loader-pulse 1.4s ease-in-out infinite;
        border: 1px solid rgba(236, 17, 26, 0.42);
        border-radius: inherit;
        content: "";
        inset: -0.65rem;
        position: absolute;
    }

    .josi-panel-loader__label {
        color: rgba(255, 255, 255, 0.8);
        font-family: Inter, ui-sans-serif, system-ui, sans-serif;
        font-size: 0.875rem;
        font-weight: 700;
        letter-spacing: 0;
    }

    @keyframes josi-panel-loader-spin {
        to {
            transform: rotate(360deg);
        }
    }

    @keyframes josi-panel-loader-pulse {
        0%,
        100% {
            opacity: 0;
            transform: scale(0.88);
        }

        45% {
            opacity: 1;
            transform: scale(1.08);
        }
    }

    @media (prefers-reduced-motion: reduce) {
        .josi-panel-loader,
        .josi-panel-loader__ring,
        .josi-panel-loader__ring::after {
            animation: none;
            transition-duration: 0.001ms;
        }
    }
</style>

<div class="josi-panel-loader" role="status" aria-live="polite" aria-label="Loading Josi dashboard">
    <div class="josi-panel-loader__card">
        <img class="josi-panel-loader__logo" src="{{ $logoUrl }}" alt="Josi">
        <div class="josi-panel-loader__ring" aria-hidden="true"></div>
        <div class="josi-panel-loader__label">Loading Josi dashboard</div>
    </div>
</div>

<script>
    (() => {
        const root = document.documentElement;
        const show = () => {
            root.classList.remove('josi-panel-ready');
            root.classList.add('josi-panel-loading');
        };
        const hide = () => {
            root.classList.add('josi-panel-ready');
            root.classList.remove('josi-panel-loading');
        };
        const hideSoon = () => window.setTimeout(hide, 160);
        const hideLater = () => window.setTimeout(hide, 8000);

        if (document.readyState === 'complete') {
            hideSoon();
        } else {
            window.addEventListener('load', hideSoon, { once: true });
            document.addEventListener('DOMContentLoaded', hideSoon, { once: true });
        }

        window.addEventListener('beforeunload', show);
        window.addEventListener('pageshow', hideSoon);

        document.addEventListener('livewire:navigate', show);
        document.addEventListener('livewire:navigating', show);
        document.addEventListener('livewire:navigated', hideSoon);

        document.addEventListener('submit', (event) => {
            if (!event.defaultPrevented) {
                show();
                hideLater();
            }
        }, true);

        document.addEventListener('click', (event) => {
            const link = event.target.closest('a[href]');

            if (!link || event.defaultPrevented || link.target || link.hasAttribute('download')) {
                return;
            }

            const url = new URL(link.href, window.location.href);

            if (url.origin !== window.location.origin) {
                return;
            }

            if (
                url.pathname === window.location.pathname &&
                url.search === window.location.search &&
                url.hash
            ) {
                return;
            }

            show();
            hideLater();
        }, true);

        window.setTimeout(hide, 12000);
    })();
</script>
