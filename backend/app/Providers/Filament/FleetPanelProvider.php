<?php

namespace App\Providers\Filament;

use App\Filament\Fleet\Pages\FleetDashboard;
use App\Filament\Fleet\Widgets\FleetBusinessSummary;
use App\Filament\Fleet\Widgets\FleetDocumentsStatus;
use App\Filament\Fleet\Widgets\FleetOverviewStats;
use App\Filament\Fleet\Widgets\FleetRecentActivity;
use App\Support\Filament\DashboardAccess;
use Filament\Http\Middleware\Authenticate;
use Filament\Http\Middleware\AuthenticateSession;
use Filament\Http\Middleware\DisableBladeIconComponents;
use Filament\Http\Middleware\DispatchServingFilamentEvent;
use Filament\Navigation\NavigationGroup;
use Filament\Panel;
use Filament\PanelProvider;
use Filament\Support\Colors\Color;
use Filament\Support\Enums\Width;
use Filament\View\PanelsRenderHook;
use Illuminate\Cookie\Middleware\AddQueuedCookiesToResponse;
use Illuminate\Cookie\Middleware\EncryptCookies;
use Illuminate\Foundation\Http\Middleware\VerifyCsrfToken;
use Illuminate\Routing\Middleware\SubstituteBindings;
use Illuminate\Session\Middleware\StartSession;
use Illuminate\View\Middleware\ShareErrorsFromSession;

class FleetPanelProvider extends PanelProvider
{
    public function register(): void
    {
        if ($this->isApiRequest()) {
            return;
        }

        parent::register();
    }

    public function panel(Panel $panel): Panel
    {
        return $panel
            ->id(DashboardAccess::FLEET_PANEL)
            ->path('dashboard')
            ->login()
            ->brandName('Josi Fleet')
            ->brandLogo(asset('images/josi-logo.png'))
            ->brandLogoHeight('2.25rem')
            ->favicon(asset('images/josi-logo.png'))
            ->font('Inter')
            ->colors([
                'primary' => Color::Red,
                'gray' => Color::Slate,
                'success' => Color::Green,
                'warning' => Color::Amber,
                'danger' => Color::Red,
                'info' => Color::Blue,
            ])
            ->maxContentWidth(Width::Full)
            ->sidebarCollapsibleOnDesktop()
            ->unsavedChangesAlerts()
            ->profile()
            ->renderHook(
                PanelsRenderHook::BODY_START,
                fn () => view('filament.partials.panel-loader')->render(),
            )
            ->navigationGroups([
                NavigationGroup::make('Dashboard'),
                NavigationGroup::make('Business'),
                NavigationGroup::make('Fleet'),
                NavigationGroup::make('Operations'),
                NavigationGroup::make('Finance'),
                NavigationGroup::make('Settings'),
            ])
            ->discoverResources(in: app_path('Filament/Fleet/Resources'), for: 'App\\Filament\\Fleet\\Resources')
            ->discoverPages(in: app_path('Filament/Fleet/Pages'), for: 'App\\Filament\\Fleet\\Pages')
            ->pages([
                FleetDashboard::class,
            ])
            ->discoverWidgets(in: app_path('Filament/Fleet/Widgets'), for: 'App\\Filament\\Fleet\\Widgets')
            ->widgets([
                FleetBusinessSummary::class,
                FleetOverviewStats::class,
                FleetDocumentsStatus::class,
                FleetRecentActivity::class,
            ])
            ->middleware([
                EncryptCookies::class,
                AddQueuedCookiesToResponse::class,
                StartSession::class,
                AuthenticateSession::class,
                ShareErrorsFromSession::class,
                VerifyCsrfToken::class,
                SubstituteBindings::class,
                DisableBladeIconComponents::class,
                DispatchServingFilamentEvent::class,
            ])
            ->authMiddleware([
                Authenticate::class,
            ]);
    }

    private function isApiRequest(): bool
    {
        if (! $this->app->bound('request')) {
            return false;
        }

        return $this->app['request']->is('api/*');
    }
}
